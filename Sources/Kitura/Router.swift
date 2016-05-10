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
import KituraSys
import LoggerAPI
import Foundation
import Kitura_TemplateEngine

// MARK Router

public class Router {

    ///
    /// Contains the list of routing elements
    ///
    private var routeElems: [RouterElement] = []

    ///
    /// Map from file extensiont to Template Engines
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

    ///
    /// Initializes a Router
    ///
    /// - Returns: a Router instance
    ///
    public init() {

        Log.verbose("Router initialized")
    }

    // MARK: All
    public func all(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.All, pattern: path, handler: handler)
    }

    public func all(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.All, pattern: path, handler: handler)
    }

    public func all(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.All, pattern: path, middleware: middleware)
    }

    public func all(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.All, pattern: path, middleware: middleware)
    }

    // MARK: Get
    public func get(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Get, pattern: path, handler: handler)
    }

    public func get(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Get, pattern: path, handler: handler)
    }

    public func get(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Get, pattern: path, middleware: middleware)
    }

    public func get(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Get, pattern: path, middleware: middleware)
    }

    // MARK: Head
    public func head(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Head, pattern: path, handler: handler)
    }

    public func head(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Head, pattern: path, handler: handler)
    }

    public func head(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Head, pattern: path, middleware: middleware)
    }

    public func head(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Head, pattern: path, middleware: middleware)
    }

    // MARK: Post
    public func post(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Post, pattern: path, handler: handler)
    }

    public func post(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Post, pattern: path, handler: handler)
    }

    public func post(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Post, pattern: path, middleware: middleware)
    }

    public func post(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Post, pattern: path, middleware: middleware)
    }

    // MARK: Put
    public func put(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Put, pattern: path, handler: handler)
    }

    public func put(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Put, pattern: path, handler: handler)
    }

    public func put(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Put, pattern: path, middleware: middleware)
    }

    public func put(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Put, pattern: path, middleware: middleware)
    }

    // MARK: Delete
    public func delete(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Delete, pattern: path, handler: handler)
    }

    public func delete(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Delete, pattern: path, handler: handler)
    }

    public func delete(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Delete, pattern: path, middleware: middleware)
    }

    public func delete(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Delete, pattern: path, middleware: middleware)
    }

    // MARK: Options
    public func options(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Options, pattern: path, handler: handler)
    }

    public func options(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Options, pattern: path, handler: handler)
    }

    public func options(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Options, pattern: path, middleware: middleware)
    }

    public func options(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Options, pattern: path, middleware: middleware)
    }

    // MARK: Trace
    public func trace(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Trace, pattern: path, handler: handler)
    }

    public func trace(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Trace, pattern: path, handler: handler)
    }

    public func trace(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Trace, pattern: path, middleware: middleware)
    }

    public func trace(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Trace, pattern: path, middleware: middleware)
    }

    // MARK: Copy
    public func copy(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Copy, pattern: path, handler: handler)
    }

    public func copy(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Copy, pattern: path, handler: handler)
    }

    public func copy(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Copy, pattern: path, middleware: middleware)
    }

    public func copy(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Copy, pattern: path, middleware: middleware)
    }

    // MARK: Lock
    public func lock(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Lock, pattern: path, handler: handler)
    }

    public func lock(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Lock, pattern: path, handler: handler)
    }

    public func lock(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Lock, pattern: path, middleware: middleware)
    }

    public func lock(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Lock, pattern: path, middleware: middleware)
    }

    // MARK: MkCol
    public func mkCol(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.MkCol, pattern: path, handler: handler)
    }

    public func mkCol(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.MkCol, pattern: path, handler: handler)
    }

    public func mkCol(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.MkCol, pattern: path, middleware: middleware)
    }

    public func mkCol(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.MkCol, pattern: path, middleware: middleware)
    }

    // MARK: Move
    public func move(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Move, pattern: path, handler: handler)
    }

    public func move(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Move, pattern: path, handler: handler)
    }

    public func move(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Move, pattern: path, middleware: middleware)
    }

    public func move(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Move, pattern: path, middleware: middleware)
    }

    // MARK: Purge
    public func purge(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Purge, pattern: path, handler: handler)
    }

    public func purge(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Purge, pattern: path, handler: handler)
    }

    public func purge(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Purge, pattern: path, middleware: middleware)
    }

    public func purge(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Purge, pattern: path, middleware: middleware)
    }

    // MARK: PropFind
    public func propFind(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.PropFind, pattern: path, handler: handler)
    }

    public func propFind(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.PropFind, pattern: path, handler: handler)
    }

    public func propFind(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.PropFind, pattern: path, middleware: middleware)
    }

    public func propFind(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.PropFind, pattern: path, middleware: middleware)
    }

    // MARK: PropPatch
    public func propPatch(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.PropPatch, pattern: path, handler: handler)
    }

    public func propPatch(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.PropPatch, pattern: path, handler: handler)
    }

    public func propPatch(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.PropPatch, pattern: path, middleware: middleware)
    }

    public func propPatch(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.PropPatch, pattern: path, middleware: middleware)
    }

    // MARK: Unlock
    public func unlock(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Unlock, pattern: path, handler: handler)
    }

    public func unlock(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Unlock, pattern: path, handler: handler)
    }

    public func unlock(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Unlock, pattern: path, middleware: middleware)
    }

    public func unlock(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Unlock, pattern: path, middleware: middleware)
    }

    // MARK: Report
    public func report(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Report, pattern: path, handler: handler)
    }

    public func report(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Report, pattern: path, handler: handler)
    }

    public func report(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Report, pattern: path, middleware: middleware)
    }

    public func report(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Report, pattern: path, middleware: middleware)
    }

    // MARK: MkActivity
    public func mkActivity(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.MkActivity, pattern: path, handler: handler)
    }

    public func mkActivity(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.MkActivity, pattern: path, handler: handler)
    }

    public func mkActivity(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.MkActivity, pattern: path, middleware: middleware)
    }

    public func mkActivity(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.MkActivity, pattern: path, middleware: middleware)
    }

    // MARK: Checkout
    public func checkout(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Checkout, pattern: path, handler: handler)
    }

    public func checkout(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Checkout, pattern: path, handler: handler)
    }

    public func checkout(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Checkout, pattern: path, middleware: middleware)
    }

    public func checkout(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Checkout, pattern: path, middleware: middleware)
    }

    // MARK: Merge
    public func merge(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Merge, pattern: path, handler: handler)
    }

    public func merge(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Merge, pattern: path, handler: handler)
    }

    public func merge(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Merge, pattern: path, middleware: middleware)
    }

    public func merge(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Merge, pattern: path, middleware: middleware)
    }

    // MARK: MSearch
    public func mSearch(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.MSearch, pattern: path, handler: handler)
    }

    public func mSearch(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.MSearch, pattern: path, handler: handler)
    }

    public func mSearch(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.MSearch, pattern: path, middleware: middleware)
    }

    public func mSearch(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.MSearch, pattern: path, middleware: middleware)
    }

    // MARK: Notify
    public func notify(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Notify, pattern: path, handler: handler)
    }

    public func notify(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Notify, pattern: path, handler: handler)
    }

    public func notify(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Notify, pattern: path, middleware: middleware)
    }

    public func notify(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Notify, pattern: path, middleware: middleware)
    }

    // MARK: Subscribe
    public func subscribe(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Subscribe, pattern: path, handler: handler)
    }

    public func subscribe(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Subscribe, pattern: path, handler: handler)
    }

    public func subscribe(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Subscribe, pattern: path, middleware: middleware)
    }

    public func subscribe(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Subscribe, pattern: path, middleware: middleware)
    }

    // MARK: Unsubscribe
    public func unsubscribe(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Unsubscribe, pattern: path, handler: handler)
    }

    public func unsubscribe(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Unsubscribe, pattern: path, handler: handler)
    }

    public func unsubscribe(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Unsubscribe, pattern: path, middleware: middleware)
    }

    public func unsubscribe(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Unsubscribe, pattern: path, middleware: middleware)
    }

    // MARK: Patch
    public func patch(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Patch, pattern: path, handler: handler)
    }

    public func patch(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Patch, pattern: path, handler: handler)
    }

    public func patch(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Patch, pattern: path, middleware: middleware)
    }

    public func patch(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Patch, pattern: path, middleware: middleware)
    }

    // MARK: Search
    public func search(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Search, pattern: path, handler: handler)
    }

    public func search(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Search, pattern: path, handler: handler)
    }

    public func search(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Search, pattern: path, middleware: middleware)
    }

    public func search(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Search, pattern: path, middleware: middleware)
    }

    // MARK: Connect
    public func connect(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Connect, pattern: path, handler: handler)
    }

    public func connect(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Connect, pattern: path, handler: handler)
    }

    public func connect(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Connect, pattern: path, middleware: middleware)
    }

    public func connect(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Connect, pattern: path, middleware: middleware)
    }

    // MARK: Use
    @available(*, deprecated, message:"Use Router.all instead")
    public func use(middleware: RouterMiddleware...) -> Router {
        routeElems.append(RouterElement(method: .All, pattern: nil, middleware: middleware))
        return self
    }

    @available(*, deprecated, message:"Use Router.all instead")
    public func use(path: String, middleware: RouterMiddleware...) -> Router {
        routeElems.append(RouterElement(method: .All, pattern: path, middleware: middleware))
        return self
    }

    // MARK: error
    public func error(_ handler: RouterHandler...) -> Router {
        return routingHelper(.Error, pattern: nil, handler: handler)
    }

    public func error(_ handler: [RouterHandler]) -> Router {
        return routingHelper(.Error, pattern: nil, handler: handler)
    }

    public func error(_ middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Error, pattern: nil, middleware: middleware)
    }

    public func error(_ middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Error, pattern: nil, middleware: middleware)
    }

    private func routingHelper(_ method: RouterMethod, pattern: String?, handler: [RouterHandler]) -> Router {
        routeElems.append(RouterElement(method: method, pattern: pattern, handler: handler))
        return self
    }

    private func routingHelper(_ method: RouterMethod, pattern: String?, middleware: [RouterMiddleware]) -> Router {
        routeElems.append(RouterElement(method: method, pattern: pattern, middleware: middleware))
        return self
    }

    // MARK: Template Engine
    public func setDefaultTemplateEngine(templateEngine: TemplateEngine?) {
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

    internal func render(_ resource: String, context: [String: Any]) throws -> String {
        let resourceExtension = resource.bridge().pathExtension
        let fileExtension: String
        let resourceWithExtension: String

        if resourceExtension.isEmpty {
            fileExtension = defaultEngineFileExtension ?? ""
            //TODO use stringByAppendingPathExtension once issue https://bugs.swift.org/browse/SR-999 is resolved
            resourceWithExtension = resource + "." + fileExtension
        } else {
            fileExtension = resourceExtension
            resourceWithExtension = resource
        }

        if fileExtension.isEmpty {
            throw TemplatingError.NoDefaultTemplateEngineAndNoExtensionSpecified
        }

        guard let templateEngine = templateEngines[fileExtension] else {
            throw TemplatingError.NoTemplateEngineForExtension(extension: fileExtension)
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
    public func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let urlPath = request.parsedUrl.path else {
            Log.error("Failed to handle request")
            return
        }

        let mountpath = request.matchedPath
        guard let prefixRange = urlPath.range(of: mountpath) else {
            Log.error("Failed to find matches in url")
            return
        }
        request.parsedUrl.path?.removeSubrange(prefixRange)
        
        if request.parsedUrl.path == "" {
            request.parsedUrl.path = "/"
        }

        process(request: request, response: response) {
            request.parsedUrl.path = urlPath
            next()
        }
    }
}


///
/// HTTPServerDelegate extensions
///
extension Router : HTTPServerDelegate {

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
                if  !routeResp.invokedEnd {
                    if  routeResp.response.statusCode == .NotFound {
                        self.sendDefaultResponse(routeReq, routeResp: routeResp)
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

        guard let urlPath = request.parsedUrl.path else {
            Log.error("Failed to process request")
            return
        }

        let lengthIndex = kituraResourcePrefix.endIndex
        if  urlPath.characters.count > kituraResourcePrefix.characters.count && urlPath.substring(to: lengthIndex) == kituraResourcePrefix {
            let resource = urlPath.substring(from: lengthIndex)
            sendResourceIfExisting(response, resource: resource)
        } else {
            var elemIndex = -1

            // Extra variable to get around use of variable in its own initializer
            var nextElemCallback: (()->Void)?

            let nextElemCallbackHandler = {[unowned request, unowned response, unowned self] () -> Void in
                elemIndex+=1
                if  elemIndex < self.routeElems.count {
                    guard let nextElemCallback = nextElemCallback else { return }
                    self.routeElems[elemIndex].process(request: request, response: response, next: nextElemCallback)
                } else {
                    callback()
                }
            }
            nextElemCallback = nextElemCallbackHandler

            nextElemCallbackHandler()
        }
    }

    ///
    /// Send default index.html file and it's resources if appropriate, otherwise send default 404 message
    ///
    private func sendDefaultResponse(_ routeReq: RouterRequest, routeResp: RouterResponse) {
        if routeReq.parsedUrl.path == "/" {
            sendResourceIfExisting(routeResp, resource: "index.html")
        } else {
            do {
                let errorMessage = "Cannot \(String(routeReq.method).uppercased()) \(routeReq.parsedUrl.path ?? "")."
                try routeResp.status(.NotFound).send(errorMessage).end()
            } catch {
                Log.error("Error sending default not found message: \(error)")
            }
        }
    }

    private func getResourceFilePath(_ resource: String) -> String? {
#if os(Linux)
        let fileManager = NSFileManager.defaultManager()
#else
        let fileManager = NSFileManager.default()
#endif
        let potentialResource = constructResourcePathFromSourceLocation(resource)

        let fileExists = fileManager.fileExists(atPath: potentialResource)
        if fileExists {
            return potentialResource
        }
        else {
            return constructResourcePathFromCurrentDirectory(resource, fileManager: fileManager)
        }
    }

    private func constructResourcePathFromSourceLocation(_ resource: String) -> String {
        let fileName = NSString(string: #file)
        let resourceFilePrefixRange: NSRange
        let lastSlash = fileName.range(of: "/", options: NSStringCompareOptions.backwardsSearch)
        if  lastSlash.location != NSNotFound  {
            resourceFilePrefixRange = NSMakeRange(0, lastSlash.location+1)
        } else {
            resourceFilePrefixRange = NSMakeRange(0, fileName.length)
        }
        return fileName.substring(with: resourceFilePrefixRange) + "resources/" + resource
    }

    private func constructResourcePathFromCurrentDirectory(_ resource: String, fileManager: NSFileManager) -> String? {
        do {
            let packagePath = fileManager.currentDirectoryPath + "/Packages"
            let packages = try fileManager.contentsOfDirectory(atPath: packagePath)
            for package in packages {
                let potentalResource = "\(packagePath)/\(package)/Sources/Kitura/resources/\(resource)"
                let resourceExists = fileManager.fileExists(atPath: potentalResource)
                if resourceExists {
                    return potentalResource
                }
            }
        }
        catch {
            return nil
        }
        return nil
    }


    ///
    /// Get the directory we were compiled from
    ///
    private func sendResourceIfExisting(_ routeResp: RouterResponse, resource: String)  {
        guard let resourceFileName = getResourceFilePath(resource) else {
            return
        }

        do {
            try routeResp.send(fileName: resourceFileName)
            routeResp.status(.OK)
            try routeResp.end()
        } catch {
            // Fail silently
        }
    }
}
