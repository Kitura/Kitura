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

/// The `Router` class provides the external intreface for the routing of requestes to
/// the appropriate code for handling. This includes:
///
///   - Routing requests to closures with the signature of `RouterHandler`
///   - Routing requests to the handle function of classes that implement the
///    `RouterMiddleware` protocol.
///   - Routing the request to a template engine to generate the appropriate output.
///   - Serving the landing page when someone makes an HTTP request with a path of slash (/).
public class Router {

    /// Contains the list of routing elements
    fileprivate var elements: [RouterElement] = []

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

    /// Initializes a Router
    ///
    /// - Returns: a Router instance
    public init() {
        Log.verbose("Router initialized")
    }

    func routingHelper(_ method: RouterMethod, pattern: String?, handler: [RouterHandler]) -> Router {
        elements.append(RouterElement(method: method, pattern: pattern, handler: handler))
        return self
    }

    func routingHelper(_ method: RouterMethod, pattern: String?, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        elements.append(RouterElement(method: method,
            pattern: pattern,
            middleware: middleware,
            allowPartialMatch: allowPartialMatch))
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
    /// - Parameter templateEngine: The templating engineto register.
    public func add(templateEngine: TemplateEngine) {
        templateEngines[templateEngine.fileExtension] = templateEngine
    }

    /// Render a template using a context
    ///
    /// - Parameter template:
    internal func render(template: String, context: [String: Any]) throws -> String {
        guard let resourceExtension = URL(string: template)?.pathExtension else {
            throw TemplatingError.noTemplateEngineForExtension(extension: "")
        }
        
        let fileExtension: String
        let resourceWithExtension: String

        if resourceExtension.isEmpty {
            fileExtension = defaultEngineFileExtension ?? ""
            //TODO use stringByAppendingPathExtension once issue https://bugs.swift.org/browse/SR-999 is resolved
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

        let filePath =  viewsPath + resourceWithExtension
        return try templateEngine.render(filePath: filePath, context: context)
    }
    
    // MARK: Sub router
    
    /// Setup a "sub router" to handle requests. This can make it easier to
    /// build a server that server a large set of paths, by breaking it up
    /// in to "sub router" where each sub router is mapped to it's own root
    /// path and handles all of the mappings of paths below that.
    ///
    /// - Parameter route: The path to bind the sub router to.
    ///
    /// - Returns: The created sub router.
    public func route(_ route: String) -> Router {
        let subrouter = Router()
        self.all(route, middleware: subrouter)
        return subrouter
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
        guard let urlPath = request.parsedURL.path else {
            Log.error("Failed to handle request")
            return
        }

        let mountpath = request.matchedPath
        guard let prefixRange = urlPath.range(of: mountpath) else {
            Log.error("Failed to find matches in url")
            return
        }
        request.parsedURL.path?.removeSubrange(prefixRange)

        if request.parsedURL.path == "" {
            request.parsedURL.path = "/"
        }

        process(request: request, response: response) {
            request.parsedURL.path = urlPath
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

        process(request: routeReq, response: routeResp) { [unowned self] () in
            do {
                if  !routeResp.state.invokedEnd {
                    if  routeResp.statusCode == .unknown  && !routeResp.state.invokedSend {
                        self.sendDefaultResponse(request: routeReq, response: routeResp)
                    }
                    try routeResp.end()
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
        guard let urlPath = request.parsedURL.path else {
            Log.error("Failed to process request")
            return
        }

        let lengthIndex = kituraResourcePrefix.endIndex
        if  urlPath.characters.count > kituraResourcePrefix.characters.count && urlPath.substring(to: lengthIndex) == kituraResourcePrefix {
            let resource = urlPath.substring(from: lengthIndex)
            fileResourceServer.sendIfFound(resource: resource, usingResponse: response)
        } else {
            let looper = RouterElementWalker(elements: self.elements, request: request, response: response, callback: callback)
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
        if request.parsedURL.path == "/" {
            fileResourceServer.sendIfFound(resource: "index.html", usingResponse: response)
        } else {
            do {
                let errorMessage = "Cannot \(request.method) \(request.parsedURL.path ?? "")."
                try response.status(.notFound).send(errorMessage).end()
            } catch {
                Log.error("Error sending default not found message: \(error)")
            }
        }
    }
}
