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

/// The `Router` class provides the external interface for the routing of requests to
/// the appropriate code for handling. This includes:
///
///   - Routing requests to closures with the signature of `RouterHandler`
///   - Routing requests to the handle function of classes that implement the
///    `RouterMiddleware` protocol.
///   - Routing the request to a template engine to generate the appropriate output.
///   - Serving the landing page when someone makes an HTTP request with a path of slash (/).
public class Router {

    /// Contains the list of routing elements
    var elements: [RouterElement] = []

    /// Map from file extensions to Template Engines
    private var templateEngines = [String: TemplateEngine]()

    /// Default template engine extension
    private var defaultEngineFileExtension: String?

    /// The root directory for templates that will be automatically handed over to an
    /// appropriate templating engine for content generation.
    public var viewsPath = "./Views/"

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

    /// Initialize a `Router` instance
    ///
    /// - Parameter mergeParameters: Specify if this router should have access to path parameters
    /// matched in its parent router. Defaults to `false`.
    public init(mergeParameters: Bool = false) {
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

    /// Sets the default templating engine to be used when the extension of a file in the
    /// `viewsPath` doesn't match the extension of one of the registered templating engines.
    ///
    /// - Parameter templateEngine: The new default templating engine
    public func setDefault(templateEngine: TemplateEngine?) {
        if let templateEngine = templateEngine {
            defaultEngineFileExtension = templateEngine.fileExtension
            add(templateEngine: templateEngine)
            return
        }
        defaultEngineFileExtension = nil
    }

    /// Register a templating engine. The templating engine will handle files in the `viewsPath`
    /// that match the extension it supports.
    ///
    /// - Parameter templateEngine: The templating engine to register.
    /// - Parameter forFileExtensions: The extensions of the files to apply the template engine on.
    /// - Parameter useDefaultFileExtension: flag to specify if the default file extension of the
    ///   template engine should be used
    public func add(templateEngine: TemplateEngine, forFileExtensions fileExtensions: [String] = [],
                    useDefaultFileExtension: Bool = true) {
        if useDefaultFileExtension {
            templateEngines[templateEngine.fileExtension] = templateEngine
        }
        for fileExtension in fileExtensions {
            templateEngines[fileExtension] = templateEngine
        }
    }

    /// Render a template using a context
    ///
    /// - Parameter template: The path to the template file to be rendered.
    /// - Parameter context: A Dictionary of variables to be used by the
    ///                     template engine while rendering the template.
    /// - Parameter options: rendering options, specific per template engine
    ///
    /// - Returns: The content generated by rendering the template.
    /// - Throws: Any error thrown by the Templating Engine when it fails to
    ///          render the template.
    internal func render(template: String, context: [String: Any], options: RenderingOptions = NullRenderingOptions()) throws -> String {
        guard let resourceExtension = URL(string: template)?.pathExtension else {
            throw TemplatingError.noTemplateEngineForExtension(extension: "")
        }

        let fileExtension: String
        let resourceWithExtension: String

        if resourceExtension.isEmpty {
            fileExtension = defaultEngineFileExtension ?? ""
            // swiftlint:disable todo
            //TODO: Use stringByAppendingPathExtension once issue https://bugs.swift.org/browse/SR-999 is resolved
            // swiftlint:enable todo
            resourceWithExtension = template + "." + fileExtension
        } else {
            fileExtension = resourceExtension
            resourceWithExtension = template
        }

        if fileExtension.isEmpty {
            throw TemplatingError.noDefaultTemplateEngineAndNoExtensionSpecified
        }

        guard let templateEngine = templateEngines[fileExtension] else {
            throw TemplatingError.noTemplateEngineForExtension(extension: fileExtension)
        }

        let filePath: String
        if let decodedResourceExtension = resourceWithExtension.removingPercentEncoding {
            filePath = viewsPath + decodedResourceExtension
        } else {
            Log.warning("Unable to decode url \(resourceWithExtension)")
            filePath = viewsPath + resourceWithExtension
        }

        let absoluteFilePath = StaticFileServer.ResourcePathHandler.getAbsolutePath(for: filePath)
        return try templateEngine.render(filePath: absoluteFilePath, context: context)
    }

    // MARK: Sub router

    /// Setup a "sub router" to handle requests. This can make it easier to
    /// build a server that serves a large set of paths, by breaking it up
    /// in to "sub router" where each sub router is mapped to it's own root
    /// path and handles all of the mappings of paths below that.
    ///
    /// - Parameter route: The path to bind the sub router to.
    /// - Parameter mergeParameters: Specify if this router should have access to path parameters
    /// matched in its parent router. Defaults to `false`.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    /// the path by the pattern is sufficient.
    /// - Returns: The created sub router.
    public func route(_ route: String, mergeParameters: Bool = false, allowPartialMatch: Bool = true) -> Router {
        let subrouter = Router(mergeParameters: mergeParameters)
        subrouter.parameterHandlers = self.parameterHandlers
        self.all(route, allowPartialMatch: allowPartialMatch, middleware: subrouter)
        return subrouter
    }

    // MARK: Parameter handling

    /// Setup a  handler for specific name of request parameters.
    /// This can make it easier to handle values of provided parameter name.
    ///
    /// - Parameter name: A single parameter name to be handled
    /// - Parameter handler: A comma delimited set of `RouterParameterHandler`s that will be
    ///                     invoked when request parses a parameter with specified name.
    /// - Returns: Current router instance
    @discardableResult
    public func parameter(_ name: String, handler: @escaping RouterParameterHandler...) -> Router {
        return self.parameter([name], handlers: handler)
    }

    /// Setup a  handler for specific name of request parameters.
    /// This can make it easier to handle values of provided parameter name.
    ///
    /// - Parameter names: The array of parameter names that will be used to invoke handlers
    /// - Parameter handler: A comma delimited set of `RouterParameterHandler`s that will be
    ///                     invoked when request parses a parameter with specified name.
    /// - Returns: Current router instance
    @discardableResult
    public func parameter(_ names: [String], handler: @escaping RouterParameterHandler...) -> Router {
        return self.parameter(names, handlers: handler)
    }

    /// Setup a  handler for specific name of request parameters.
    /// This can make it easier to handle values of provided parameter name.
    ///
    /// - Parameter names: The array of parameter names that will be used to invoke handlers
    /// - Parameter handlers: The array of `RouterParameterHandler`s that will be
    ///                     invoked when request parses a parameter with specified name.
    /// - Returns: Current router instance
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

// MARK: RouterMiddleware extensions
extension Router : RouterMiddleware {

    /// Handle an HTTP request as a middleware. Used for sub routing.
    ///
    /// - Parameter request: The `RouterRequest` object that is used to work with
    ///                     the incoming request.
    /// - Parameter response: The `RouterResponse` object used to send responses
    ///                      to the HTTP request.
    /// - Parameter next: The closure to invoke to cause the router to inspect the
    ///                  path in the list of paths.
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let urlPath = request.parsedURLPath.path else {
            Log.error("request.parsedURLPath.path is nil. Failed to handle request")
            return
        }

        if request.allowPartialMatch {
            let mountpath = request.matchedPath

            /// Note: Since regex always start with ^, the beginning of line character,
            /// matched ranges always start at location 0, so it's OK to check via `hasPrefix`.
            /// Note: `hasPrefix("")` is `true` on macOS but `false` on Linux
            guard mountpath == "" || urlPath.hasPrefix(mountpath) else {
                Log.error("Failed to find matches in url")
                return
            }

            let index = urlPath.index(urlPath.startIndex, offsetBy: mountpath.characters.count)

            request.parsedURLPath.path = urlPath.substring(from: index)
        }

        process(request: request, response: response) {
            request.parsedURLPath.path = urlPath
            next()
        }
    }
}

// MARK: HTTPServerDelegate extensions
extension Router : ServerDelegate {

    /// Handle the HTTP request
    ///
    /// - Parameter request: The `ServerRequest` object used to work with the incoming
    ///                     HTTP request at the Kitura-net API level.
    /// - Parameter response: The `ServerResponse` object used to send responses to the
    ///                      HTTP request at the Kitura-net API level.
    public func handle(request: ServerRequest, response: ServerResponse) {
        let routeReq = RouterRequest(request: request)
        let routeResp = RouterResponse(response: response, router: self, request: routeReq)

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
    /// - Parameter request: The `RouterRequest` object that is used to work with
    ///                     the incoming request.
    /// - Parameter response: The `RouterResponse` object used to send responses
    ///                      to the HTTP request.
    /// - Parameter callback: The closure to invoke to cause the router to inspect the
    ///                  path in the list of paths.
    fileprivate func process(request: RouterRequest, response: RouterResponse, callback: @escaping () -> Void) {
        guard let urlPath = request.parsedURLPath.path else {
            Log.error("request.parsedURLPath.path is nil. Failed to process request")
            return
        }

        if  urlPath.hasPrefix(kituraResourcePrefix) {
            let resource = urlPath.substring(from: kituraResourcePrefix.endIndex)
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
    /// - Parameter request: The `RouterRequest` object that is used to work with
    ///                     the incoming request.
    /// - Parameter response: The `RouterResponse` object used to send responses
    ///                      to the HTTP request.
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
