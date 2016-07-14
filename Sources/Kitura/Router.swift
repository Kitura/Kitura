/**
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
 **/

import KituraNet
import LoggerAPI
import Foundation
import KituraTemplateEngine

// MARK Router

public class Router {

    ///
    /// Contains the list of routing elements
    ///
    private var elements: [RouterElement] = []

    ///
    /// Map from file extensions to Template Engines
    ///
    private var templateEngines = [String: TemplateEngine]()

    ///
    /// Default template engine extension
    ///
    private var defaultEngineFileExtension: String?

    ///
    /// Views directory path
    ///
    public var viewsPath = "./Views/"

    ///
    /// Prefix for special page resources
    ///
    private let kituraResourcePrefix = "/@@Kitura-router@@/"

    /// helper for serving file resources
    private let fileResourceServer = FileResourceServer()

    ///
    /// Initializes a Router
    ///
    /// - Returns: a Router instance
    ///
    public init() {
        Log.verbose("Router initialized")
    }

    func routingHelper(_ method: RouterMethod, pattern: String?, handler: [RouterHandler]) -> Router {
        elements.append(RouterElement(method: method, pattern: pattern, handler: handler))
        return self
    }

    func routingHelper(_ method: RouterMethod, pattern: String?, middleware: [RouterMiddleware]) -> Router {
        elements.append(RouterElement(method: method, pattern: pattern, middleware: middleware))
        return self
    }

    // MARK: Template Engine
    public func setDefault(templateEngine: TemplateEngine?) {
        if let templateEngine = templateEngine {
            defaultEngineFileExtension = templateEngine.fileExtension
            add(templateEngine: templateEngine)
            return
        }
        defaultEngineFileExtension = nil
    }

    public func add(templateEngine: TemplateEngine) {
        templateEngines[templateEngine.fileExtension] = templateEngine
    }

    internal func render(template: String, context: [String: Any]) throws -> String {
        let resourceExtension = template.bridge().pathExtension
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

    public func route(_ route: String) -> Router {
        let subrouter = Router()
        self.all(route, middleware: subrouter)
        return subrouter
    }
}

///
/// RouterMiddleware extensions
///
extension Router : RouterMiddleware {

    ///
    /// Handle the request as a middleware. Used for subrouting.
    ///
    /// - Parameter request: the router request
    /// - Parameter response: the router response
    ///
    public func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
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


///
/// HTTPServerDelegate extensions
///
extension Router : ServerDelegate {

    ///
    /// Handle the request
    ///
    /// - Parameter request: the server request
    /// - Parameter response: the server response
    ///
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

    ///
    /// Processes the request
    ///
    /// - Parameter request: the server request
    /// - Parameter response: the server response
    ///
    private func process(request: RouterRequest, response: RouterResponse, callback: () -> Void) {

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

    ///
    /// Send default index.html file and it's resources if appropriate, otherwise send default 404 message
    ///
    private func sendDefaultResponse(request: RouterRequest, response: RouterResponse) {
        if request.parsedURL.path == "/" {
            fileResourceServer.sendIfFound(resource: "index.html", usingResponse: response)
        } else {
            do {
                let errorMessage = "Cannot \(String(request.method).uppercased()) \(request.parsedURL.path ?? "")."
                try response.status(.notFound).send(errorMessage).end()
            } catch {
                Log.error("Error sending default not found message: \(error)")
            }
        }
    }
}
