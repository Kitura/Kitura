/*
 * Copyright IBM Corporation 2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import KituraNet
import LoggerAPI
import Foundation
import KituraTemplateEngine

// MARK Router

/// `Router` provides the external interface for routing requests to
/// the appropriate code to handle them. This includes:
///
///   - Routing requests to closures of type `RouterHandler`
///   - Routing requests to the handle function of classes that implement the
///    `RouterMiddleware` protocol.
///   - Routing requests to a `TemplateEngine` to generate the appropriate output.
///   - Serving the landing page when someone makes an HTTP request with a path of slash (/).
///

public class Router {

    /// Contains the list of routing elements
    var elements: [RouterElement] = []

    /// Map from file extensions to Template Engines
    private var templateEngines = [String: TemplateEngine]()

    /// Default template engine extension
    private var defaultEngineFileExtension: String?

    /// The root directory where template files should be placed in order to be automatically handed
    /// over to an appropriate templating engine for content generation. The directory should sit at the
    /// same level as the project's "Sources" directory. Defaults to "./Views/".
    /// ### Usage Example: ###
    /// The example below changes the directory where template files should be placed to be "./myViews/"
    /// ```swift
    /// let router = Router()
    /// router.viewsPath = "./myViews/"
    /// ```
    public var viewsPath = "./Views/" {
        didSet {
            for (_, templateEngine) in templateEngines {
                setRootPaths(forTemplateEngine: templateEngine)
            }
        }
    }

    /// Prefix for special page resources
    fileprivate let kituraResourcePrefix = "/@@Kitura-router@@/"

    /// Helper for serving file resources
    fileprivate let fileResourceServer = FileResourceServer()

    /// Flag to enable/disable access to parent router's params
    private let mergeParameters: Bool

    /// Collection of `RouterParameterHandler` for specified parameter name
    /// that will be passed to `RouterElementWalker` when server receives client request
    /// and used to handle request's url parameters.
    fileprivate var parameterHandlers = [String : [RouterParameterHandler]]()

    /// Contains the structures needed for swagger document generation
    var swagger: SwaggerDocument

    /// Returns the current in-memory representation of Codable routes as a
    /// Swagger document in JSON format, or nil if the document cannot be
    /// generated.
    public var swaggerJSON: String? {
        do {
            return try self.swagger.serializeAPI(format: .json)
        } catch {
            return nil
        }
    }

    /// Initialize a `Router` instance.
    /// ### Usage Example: ###
    /// ```swift
    ///  let router = Router()
    /// ```
    /// #### Using `mergeParameters`: ####
    /// When initialising a `Router`, `mergeParameters` allows you to control whether
    /// the router will be able to access parameters matched in its parent router. For instance, in the example below
    /// if `mergeParameters` is set to `true`, `GET /Hello/Alex` will return "Hello Alex", but if set to `false`
    /// the `greeting` parameter will not be accessible and it will return just " Alex".
    /// ```swift
    /// let router = Router()
    /// let userRouter = Router(mergeParameters: true)
    ///
    /// router.get("/:greeting") { request, response, _ in
    ///   let greeting = request.parameters["greeting"] ?? ""
    ///   try response.send("\(greeting)").end()
    /// }
    ///
    /// userRouter.get("/:user") { request, response, _ in
    ///   let user = request.parameters["user"] ?? ""
    ///   let greeting = request.parameters["greeting"] ?? ""
    ///   try response.send("\(greeting) \(user)").end()
    /// }
    ///
    /// router.all("/:greeting", middleware: userRouter)
    /// ```
    /// - Parameter mergeParameters: Optional parameter to specify if the router should be able to access parameters
    ///                                 from its parent router. Defaults to `false` if not specified.
    public init(mergeParameters: Bool = false) {
        self.swagger = SwaggerDocument()
        self.mergeParameters = mergeParameters

        Log.verbose("Router initialized")
    }

    func routingHelper(_ method: RouterMethod, pattern: String?, handler: [RouterHandler]) -> Router {
        elements.append(RouterElement(method: method,
                                      pattern: pattern,
                                      handler: handler,
                                      mergeParameters: mergeParameters))
        return self
    }

    func routingHelper(_ method: RouterMethod, pattern: String?, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        elements.append(RouterElement(method: method,
                                      pattern: pattern,
                                      middleware: middleware,
                                      allowPartialMatch: allowPartialMatch,
                                      mergeParameters: mergeParameters))
        return self
    }

    // MARK: Template Engine

    /// Register a template engine to a given router instance.
    /// A template engine allows rendering of documents using static templates.
    ///
    /// By default the templating engine will handle files in the `./Views` directory
    /// that match the file extension it supports. You can change this default location using the `viewsPath` property.
    /// ### Usage Example: ###
    /// ```swift
    /// let router = Router()
    /// router.add(templateEngine: MyTemplateEngine())
    /// router.add(templateEngine: MyOtherTemplateEngine(), forFileExtensions: ["html"], useDefaultFileExtension: false)
    /// ```
    /// If multiple different template engines are registered for the same extension, the template engine
    /// that is registered last will be the one that attempts to render all template files with the chosen extension.
    /// - Parameter templateEngine: The templating engine to register.
    /// - Parameter forFileExtensions: The extensions of the files to apply the template engine on.
    /// - Parameter useDefaultFileExtension: The flag to specify if the default file extension of the
    ///   template engine should be used. Defaults to `true` if not specified.
    public func add(templateEngine: TemplateEngine, forFileExtensions fileExtensions: [String] = [],
                    useDefaultFileExtension: Bool = true) {
        if useDefaultFileExtension {
            templateEngines[templateEngine.fileExtension] = templateEngine
        }
        for fileExtension in fileExtensions {
            templateEngines[fileExtension] = templateEngine
        }
        setRootPaths(forTemplateEngine: templateEngine)
    }
    
    /// Sets the default templating engine to be used when the extension of a file in the
    /// `viewsPath` doesn't match the extension of one of the registered templating engines.
    /// ### Usage Example: ###
    /// ```swift
    /// let router = Router()
    /// router.setDefault(templateEngine: MyTemplateEngine())
    /// ```
    /// If the template engine doesn't provide a default extension you can provide one using
    /// `add(templateEngine:forFileExtensions:useDefaultFileExtension:)`. If a router instance doesn't
    /// have a template engine registered that can render the given template file a
    /// "No template engine defined for extension" `TemplatingError` is thrown.
    /// - Parameter templateEngine: The templating engine to set as default.
    public func setDefault(templateEngine: TemplateEngine?) {
        if let templateEngine = templateEngine {
            defaultEngineFileExtension = templateEngine.fileExtension
            add(templateEngine: templateEngine)
            return
        }
        defaultEngineFileExtension = nil
    }

    private func setRootPaths(forTemplateEngine templateEngine: TemplateEngine) {
        let absoluteViewsPath = StaticFileServer.ResourcePathHandler.getAbsolutePath(for: viewsPath)
        templateEngine.setRootPaths(rootPaths: [absoluteViewsPath])
    }

    /// Render a template using a context
    /// - Parameter template: The path to the template file to be rendered.
    /// - Parameter context: A Dictionary of variables to be used by the
    ///                     template engine while rendering the template.
    /// - Parameter options: rendering options, specific per template engine
    ///
    /// - Returns: The content generated by rendering the template.
    /// - Throws: Any error thrown by the Templating Engine when it fails to
    ///          render the template.
    internal func render(template: String, context: [String: Any],
                         options: RenderingOptions = NullRenderingOptions()) throws -> String {
        let (optionalFileExtension, resourceWithExtension) = calculateExtension(template: template)
        
        let templateEngine = try getTemplateEngineForTemplate(template: template, optionalExtension: optionalFileExtension)
        let absoluteFilePath = buildAbsoluteFilePath(with: resourceWithExtension)
        
        return try templateEngine.render(filePath: absoluteFilePath, context: context, options: options,
                                         templateName: resourceWithExtension)
    }
    
    /// Render a template using an Encodable type. 
    /// - Parameter template: The path to the template file to be rendered.
    /// - Parameter value: A value which conforms to Encodable to be used by the
    ///                     template engine while rendering the template.
    /// - Parameter forKey: A value used to match the Encodable value to the correct variable in a template file.
    ///                                 The `forKey` value should match the desired variable in the template file.
    /// - Parameter options: rendering options, specific per template engine
    ///
    /// - Returns: The content generated by rendering the template.
    /// - Throws: Any error thrown by the Templating  Engine when it fails to
    ///          render the template.
    internal func render<T: Encodable>(template: String, with value: T, forKey key: String?,
                         options: RenderingOptions = NullRenderingOptions()) throws -> String {
        let (optionalFileExtension, resourceWithExtension) = calculateExtension(template: template)
        
        let templateEngine = try getTemplateEngineForTemplate(template: template, optionalExtension: optionalFileExtension)
        let absoluteFilePath = buildAbsoluteFilePath(with: resourceWithExtension)
        
        return try templateEngine.render(filePath: absoluteFilePath, with: value, forKey: key, options: options, templateName: resourceWithExtension)
    }
    
    private func getTemplateEngineForTemplate(template: String, optionalExtension: String?) throws -> TemplateEngine {
        // extension is nil (not the empty string), this should not happen
        guard let fileExtension = optionalExtension else {
            throw TemplatingError.noTemplateEngineForExtension(extension: "")
        }
        
        guard let templateEngine = getTemplateEngine(template: template) else {
            if fileExtension.isEmpty {
                throw TemplatingError.noDefaultTemplateEngineAndNoExtensionSpecified
            }
            
            throw TemplatingError.noTemplateEngineForExtension(extension: fileExtension)
        }
        return templateEngine
    }
    
    private func buildAbsoluteFilePath(with resourceWithExtension: String) -> String {
        let filePath: String
        if let decodedResourceExtension = resourceWithExtension.removingPercentEncoding {
            filePath = viewsPath + decodedResourceExtension
        } else {
            Log.warning("Unable to decode url \(resourceWithExtension)")
            filePath = viewsPath + resourceWithExtension
        }
        
        return StaticFileServer.ResourcePathHandler.getAbsolutePath(for: filePath)
    }

    func getTemplateEngine(template: String) -> TemplateEngine? {
        let (optionalFileExtension, _) = calculateExtension(template: template)

        guard let fileExtension = optionalFileExtension, !fileExtension.isEmpty else {
            return nil
        }

        return templateEngines[fileExtension]
    }

    // calculate file extension, consider default template engine extension
    private func calculateExtension(template: String) -> (fileExtension: String?, resourceWithExtension: String) {
        let fileExtension: String
        let resourceWithExtension: String

        guard let url = URL(string: template) else {
            return (fileExtension: nil, resourceWithExtension: template)
        }

        if url.pathExtension.isEmpty {
            fileExtension = defaultEngineFileExtension ?? ""
            
            resourceWithExtension = url.appendingPathExtension(fileExtension).absoluteString
        } else {
            fileExtension = url.pathExtension
            resourceWithExtension = template
        }

        return (fileExtension: fileExtension, resourceWithExtension: resourceWithExtension)
    }
    // MARK: Sub router
    
    /// Set up a "sub router" to handle requests. Chaining a route handler onto another router can make it easier to
    /// build a server that serves a large set of paths. Each sub router handles all of the path mappings below its
    /// parent's route path.
    /// ### Usage Example: ###
    /// The example below shows how the route `/parent/child' can be defined using a sub router.
    /// ```swift
    /// let router = Router()
    /// let parent = router.route("/parent")
    /// parent.get("/child") { request, response, next in
    ///     // If allowPartialMatch was set to false, this would not be called.
    /// }
    /// ```
    /// - Parameter route: The path to bind the sub router to.
    /// - Parameter mergeParameters: Specify if this router should have access to path parameters
    /// matched in its parent router. Defaults to `false` if not specified.
    /// - Parameter allowPartialMatch: Specify if the sub router allows a match when additional paths are added. In the example above, the `GET` request to `/parent/child` would only succeed if `allowPartialMatch` is set to `true`. Defaults to `true` if not specified.
    /// - Returns: The sub router which has been created.
    public func route(_ route: String, mergeParameters: Bool = false, allowPartialMatch: Bool = true) -> Router {
        let subrouter = Router(mergeParameters: mergeParameters)
        subrouter.parameterHandlers = self.parameterHandlers
        self.all(route, allowPartialMatch: allowPartialMatch, middleware: subrouter)
        return subrouter
    }

    // MARK: Parameter handling

    /// Set up handlers for a named request parameter. This can make it easier to handle
    /// multiple routes requiring the same parameter which needs to be handled in a certain way.
    /// ### Usage Example: ###
    /// ```swift
    /// let router = Router()
    /// router.parameter("id") { request, response, param, next in
    ///     if let _ = Int(param) {
    ///         // Id is an integer, continue
    ///         next()
    ///     }
    ///     else {
    ///         // Id is not an integer, error
    ///         try response.status(.badRequest).send("ID is not an integer").end()
    ///     }
    /// }
    ///
    /// router.get("/item/:id") { request, response, _ in
    ///     // This will only be reached if the id parameter is an integer
    /// }
    /// router.get("/user/:id") { request, response, _ in
    ///     // This will only be reached if the id parameter is an integer
    /// }
    /// ```
    ///
    /// - Parameter name: The single parameter name to be handled.
    /// - Parameter handler: The comma delimited set of `RouterParameterHandler` instances that will be
    ///                     invoked when request parses a parameter with the specified name.
    /// - Returns: The current router instance.
    @discardableResult
    public func parameter(_ name: String, handler: RouterParameterHandler...) -> Router {
        return self.parameter([name], handlers: handler)
    }

    /// Set up handlers for a number of named request parameters. This can make it easier to handle
    /// multiple routes requiring similar parameters which need to be handled in a certain way.
    /// ### Usage Example: ###
    /// ```swift
    /// let router = Router()
    /// router.parameter(["id", "num"]) { request, response, param, next in
    ///     if let _ = Int(param) {
    ///         // Parameter is an integer, continue
    ///         next()
    ///     }
    ///     else {
    ///         // Parameter is not an integer, error
    ///         try response.status(.badRequest).send("\(param) is not an integer").end()
    ///     }
    /// }
    ///
    /// router.get("/item/:id/:num") { request, response, _ in
    ///     // This will only be reached if the id and num parameters are integers.
    /// }
    /// ```
    ///
    /// - Parameter names: The array of parameter names to be handled.
    /// - Parameter handler: The comma delimited set of `RouterParameterHandler` instances that will be
    ///                     invoked when request parses a parameter with the specified name.
    /// - Returns: The current router instance.
    @discardableResult
    public func parameter(_ names: [String], handler: RouterParameterHandler...) -> Router {
        return self.parameter(names, handlers: handler)
    }

    /// Set up handlers for a number of named request parameters. This can make it easier to handle
    /// multiple routes requiring similar parameters which need to be handled in a certain way.
    /// ### Usage Example: ###
    /// ```swift
    /// let router = Router()
    /// func handleInt(request: RouterRequest, response: RouterResponse, param: String, next: @escaping () -> Void) throws -> Void {
    ///     if let _ = Int(param) {
    ///         // Parameter is an integer, continue
    ///     }
    ///     else {
    ///         // Parameter is not an integer, error
    ///         try response.status(.badRequest).send("\(param) is not an integer").end()
    ///     }
    ///     next()
    /// }
    ///
    /// func handleItem(request: RouterRequest, response: RouterResponse, param: String, next: @escaping () -> Void) throws -> Void {
    ///     let itemId = Int(param) //This will only be reached if id is an integer
    ///     ...
    /// }
    ///
    /// router.parameter(["id"], handlers: [handleInt, handleItem])
    ///
    /// router.get("/item/:id/") { request, response, _ in
    ///     ...
    /// }
    /// ```
    ///
    /// - Parameter names: The array of parameter names to be handled.
    /// - Parameter handlers: The array of `RouterParameterHandler` instances that will be
    ///                     invoked when request parses a parameter with the specified name.
    ///                     The handlers are executed in the order they are supplied.
    /// - Returns: The current router instance.
    @discardableResult
    public func parameter(_ names: [String], handlers: [RouterParameterHandler]) -> Router {
        for name in names {
            if self.parameterHandlers[name] == nil {
                self.parameterHandlers[name] = handlers
            } else {
                self.parameterHandlers[name]?.append(contentsOf: handlers)
            }
        }
        return self
    }
}


extension Router : RouterMiddleware {

    // MARK: RouterMiddleware extensions
    
    /// Handle an HTTP request as a middleware. Used internally in `Router` to allow for sub routing.
    ///
    /// - Parameter request: The `RouterRequest` object used to work with the incoming
    ///                     HTTP request.
    /// - Parameter response: The `RouterResponse` object used to respond to the
    ///                     HTTP request.
    /// - Parameter next: The closure called to invoke the next handler or middleware
    ///                     associated with the request.
    /// - Throws: Any `ErrorType`. If an error is thrown, processing of the request
    ///          is stopped, the error handlers, if any are defined, will be invoked,
    ///          and the user will get a response with a status code of 500.
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let urlPath = request.parsedURLPath.path else {
            Log.error("request.parsedURLPath.path is nil. Failed to handle request")
            next()
            return
        }

        if request.allowPartialMatch {
            let mountpath = request.matchedPath

            /// Note: Since regex always start with ^, the beginning of line character,
            /// matched ranges always start at location 0, so it's OK to check via `hasPrefix`.
            /// Note: `hasPrefix("")` is `true` on macOS but `false` on Linux
            guard mountpath == "" || urlPath.hasPrefix(mountpath) else {
                Log.error("Failed to find matches in url")
                next()
                return
            }

            let index = urlPath.index(urlPath.startIndex, offsetBy: mountpath.count)
            request.parsedURLPath.path = String(urlPath[index...])
        }

        response.push(router: self)
        process(request: request, response: response) {
            request.parsedURLPath.path = urlPath
            response.popRouter()
            next()
        }
    }
}



extension Router : ServerDelegate {
    // MARK: HTTPServerDelegate extensions

    /// Handle new incoming requests to the server.
    ///
    /// - Parameter request: The `ServerRequest` object used to work with the incoming
    ///                     HTTP request at the [Kitura-net](http://ibm-swift.github.io/Kitura-net/) API level.
    /// - Parameter response: The `ServerResponse` object used to send responses to the
    ///                      HTTP request at the [Kitura-net](http://ibm-swift.github.io/Kitura-net/) API level.
    public func handle(request: ServerRequest, response: ServerResponse) {
        let routeReq = RouterRequest(request: request)
        //TODO fix the stack
        var routerStack = Stack<Router>()
        routerStack.push(self)
        let routeResp = RouterResponse(response: response, routerStack: routerStack, request: routeReq)

        process(request: routeReq, response: routeResp) { [weak self, weak routeReq, weak routeResp] () in
            guard let strongSelf = self else {
                Log.error("Found nil self at \(#file) \(#line)")
                return
            }
            guard let routeReq = routeReq else {
                Log.error("Found nil routeReq at \(#file) \(#line)")
                return
            }
            guard let routeResp = routeResp else {
                Log.error("Found nil routeResp at \(#file) \(#line)")
                return
            }
            do {
                if  !routeResp.state.invokedEnd {
                    if  routeResp.statusCode == .unknown  && !routeResp.state.invokedSend {
                        strongSelf.sendDefaultResponse(request: routeReq, response: routeResp)
                    }
                    if  !routeResp.state.invokedEnd {
                        try routeResp.end()
                    }
                }
            } catch {
                // Not much to do here
                Log.error("Failed to send response to the client")
            }
        }
    }

    /// Processes the request
    ///
    /// - Parameter request: The `RouterRequest` object used to work with the incoming
    ///                     HTTP request.
    /// - Parameter response: The `RouterResponse` object used to respond to the
    ///                     HTTP request.
    /// - Parameter next: The closure called to invoke the next handler or middleware
    ///                     associated with the request.
    fileprivate func process(request: RouterRequest, response: RouterResponse, callback: @escaping () -> Void) {
        guard let urlPath = request.parsedURLPath.path else {
            Log.error("request.parsedURLPath.path is nil. Failed to process request")
            callback()
            return
        }

        if  urlPath.hasPrefix(kituraResourcePrefix) {
            let resource = String(urlPath[kituraResourcePrefix.endIndex...])
            fileResourceServer.sendIfFound(resource: resource, usingResponse: response)
        } else {
            let looper = RouterElementWalker(elements: self.elements,
                                             parameterHandlers: self.parameterHandlers,
                                             request: request,
                                             response: response,
                                             callback: callback)

            looper.next()
        }
    }

    /// Send default index.html file and its resources if appropriate, otherwise send
    /// default 404 message.
    ///
    /// - Parameter request: The `RouterRequest` object used to work with the incoming
    ///                     HTTP request.
    /// - Parameter response: The `RouterResponse` object used to respond to the
    ///                     HTTP request.
    private func sendDefaultResponse(request: RouterRequest, response: RouterResponse) {
        if request.parsedURLPath.path == "/" {
            fileResourceServer.sendIfFound(resource: "index.html", usingResponse: response)
        } else {
            do {
                let errorMessage = "Cannot \(request.method) \(request.parsedURLPath.path ?? "")."
                try response.status(.notFound).send(errorMessage).end()
            } catch {
                Log.error("Error sending default not found message: \(error)")
            }
        }
    }
}
