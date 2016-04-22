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
import KituraTemplateEngine

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
    private var viewsPath: String { return "./Views/" }

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
    public func all(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.All, pattern: path, handler: handler)
    }

    public func all(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.All, pattern: path, handler: handler)
    }

    public func all(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.All, pattern: path, middleware: middleware)
    }

    public func all(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.All, pattern: path, middleware: middleware)
    }

    // MARK: Get
    public func get(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Get, pattern: path, handler: handler)
    }

    public func get(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Get, pattern: path, handler: handler)
    }

    public func get(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Get, pattern: path, middleware: middleware)
    }

    public func get(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Get, pattern: path, middleware: middleware)
    }

    // MARK: Head
    public func head(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Head, pattern: path, handler: handler)
    }

    public func head(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Head, pattern: path, handler: handler)
    }

    public func head(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Head, pattern: path, middleware: middleware)
    }

    public func head(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Head, pattern: path, middleware: middleware)
    }

    // MARK: Post
    public func post(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Post, pattern: path, handler: handler)
    }

    public func post(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Post, pattern: path, handler: handler)
    }

    public func post(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Post, pattern: path, middleware: middleware)
    }

    public func post(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Post, pattern: path, middleware: middleware)
    }

    // MARK: Put
    public func put(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Put, pattern: path, handler: handler)
    }

    public func put(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Put, pattern: path, handler: handler)
    }

    public func put(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Put, pattern: path, middleware: middleware)
    }

    public func put(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Put, pattern: path, middleware: middleware)
    }

    // MARK: Delete
    public func delete(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Delete, pattern: path, handler: handler)
    }

    public func delete(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Delete, pattern: path, handler: handler)
    }

    public func delete(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Delete, pattern: path, middleware: middleware)
    }

    public func delete(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Delete, pattern: path, middleware: middleware)
    }

    // MARK: Options
    public func options(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Options, pattern: path, handler: handler)
    }

    public func options(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Options, pattern: path, handler: handler)
    }

    public func options(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Options, pattern: path, middleware: middleware)
    }

    public func options(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Options, pattern: path, middleware: middleware)
    }

    // MARK: Trace
    public func trace(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Trace, pattern: path, handler: handler)
    }

    public func trace(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Trace, pattern: path, handler: handler)
    }

    public func trace(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Trace, pattern: path, middleware: middleware)
    }

    public func trace(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Trace, pattern: path, middleware: middleware)
    }

    // MARK: Copy
    public func copy(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Copy, pattern: path, handler: handler)
    }

    public func copy(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Copy, pattern: path, handler: handler)
    }

    public func copy(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Copy, pattern: path, middleware: middleware)
    }

    public func copy(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Copy, pattern: path, middleware: middleware)
    }

    // MARK: Lock
    public func lock(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Lock, pattern: path, handler: handler)
    }

    public func lock(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Lock, pattern: path, handler: handler)
    }

    public func lock(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Lock, pattern: path, middleware: middleware)
    }

    public func lock(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Lock, pattern: path, middleware: middleware)
    }

    // MARK: MkCol
    public func mkCol(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.MkCol, pattern: path, handler: handler)
    }

    public func mkCol(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.MkCol, pattern: path, handler: handler)
    }

    public func mkCol(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.MkCol, pattern: path, middleware: middleware)
    }

    public func mkCol(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.MkCol, pattern: path, middleware: middleware)
    }

    // MARK: Move
    public func move(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Move, pattern: path, handler: handler)
    }

    public func move(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Move, pattern: path, handler: handler)
    }

    public func move(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Move, pattern: path, middleware: middleware)
    }

    public func move(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Move, pattern: path, middleware: middleware)
    }

    // MARK: Purge
    public func purge(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Purge, pattern: path, handler: handler)
    }

    public func purge(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Purge, pattern: path, handler: handler)
    }

    public func purge(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Purge, pattern: path, middleware: middleware)
    }

    public func purge(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Purge, pattern: path, middleware: middleware)
    }

    // MARK: PropFind
    public func propFind(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.PropFind, pattern: path, handler: handler)
    }

    public func propFind(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.PropFind, pattern: path, handler: handler)
    }

    public func propFind(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.PropFind, pattern: path, middleware: middleware)
    }

    public func propFind(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.PropFind, pattern: path, middleware: middleware)
    }

    // MARK: PropPatch
    public func propPatch(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.PropPatch, pattern: path, handler: handler)
    }

    public func propPatch(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.PropPatch, pattern: path, handler: handler)
    }

    public func propPatch(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.PropPatch, pattern: path, middleware: middleware)
    }

    public func propPatch(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.PropPatch, pattern: path, middleware: middleware)
    }

    // MARK: Unlock
    public func unlock(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Unlock, pattern: path, handler: handler)
    }

    public func unlock(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Unlock, pattern: path, handler: handler)
    }

    public func unlock(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Unlock, pattern: path, middleware: middleware)
    }

    public func unlock(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Unlock, pattern: path, middleware: middleware)
    }

    // MARK: Report
    public func report(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Report, pattern: path, handler: handler)
    }

    public func report(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Report, pattern: path, handler: handler)
    }

    public func report(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Report, pattern: path, middleware: middleware)
    }

    public func report(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Report, pattern: path, middleware: middleware)
    }

    // MARK: MkActivity
    public func mkActivity(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.MkActivity, pattern: path, handler: handler)
    }

    public func mkActivity(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.MkActivity, pattern: path, handler: handler)
    }

    public func mkActivity(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.MkActivity, pattern: path, middleware: middleware)
    }

    public func mkActivity(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.MkActivity, pattern: path, middleware: middleware)
    }

    // MARK: Checkout
    public func checkout(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Checkout, pattern: path, handler: handler)
    }

    public func checkout(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Checkout, pattern: path, handler: handler)
    }

    public func checkout(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Checkout, pattern: path, middleware: middleware)
    }

    public func checkout(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Checkout, pattern: path, middleware: middleware)
    }

    // MARK: Merge
    public func merge(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Merge, pattern: path, handler: handler)
    }

    public func merge(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Merge, pattern: path, handler: handler)
    }

    public func merge(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Merge, pattern: path, middleware: middleware)
    }

    public func merge(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Merge, pattern: path, middleware: middleware)
    }

    // MARK: MSearch
    public func mSearch(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.MSearch, pattern: path, handler: handler)
    }

    public func mSearch(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.MSearch, pattern: path, handler: handler)
    }

    public func mSearch(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.MSearch, pattern: path, middleware: middleware)
    }

    public func mSearch(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.MSearch, pattern: path, middleware: middleware)
    }

    // MARK: Notify
    public func notify(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Notify, pattern: path, handler: handler)
    }

    public func notify(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Notify, pattern: path, handler: handler)
    }

    public func notify(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Notify, pattern: path, middleware: middleware)
    }

    public func notify(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Notify, pattern: path, middleware: middleware)
    }

    // MARK: Subscribe
    public func subscribe(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Subscribe, pattern: path, handler: handler)
    }

    public func subscribe(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Subscribe, pattern: path, handler: handler)
    }

    public func subscribe(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Subscribe, pattern: path, middleware: middleware)
    }

    public func subscribe(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Subscribe, pattern: path, middleware: middleware)
    }

    // MARK: Unsubscribe
    public func unsubscribe(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Unsubscribe, pattern: path, handler: handler)
    }

    public func unsubscribe(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Unsubscribe, pattern: path, handler: handler)
    }

    public func unsubscribe(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Unsubscribe, pattern: path, middleware: middleware)
    }

    public func unsubscribe(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Unsubscribe, pattern: path, middleware: middleware)
    }

    // MARK: Patch
    public func patch(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Patch, pattern: path, handler: handler)
    }

    public func patch(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Patch, pattern: path, handler: handler)
    }

    public func patch(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Patch, pattern: path, middleware: middleware)
    }

    public func patch(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Patch, pattern: path, middleware: middleware)
    }

    // MARK: Search
    public func search(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Search, pattern: path, handler: handler)
    }

    public func search(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Search, pattern: path, handler: handler)
    }

    public func search(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Search, pattern: path, middleware: middleware)
    }

    public func search(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Search, pattern: path, middleware: middleware)
    }

    // MARK: Connect
    public func connect(path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.Connect, pattern: path, handler: handler)
    }

    public func connect(path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.Connect, pattern: path, handler: handler)
    }

    public func connect(path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Connect, pattern: path, middleware: middleware)
    }

    public func connect(path: String?=nil, middleware: [RouterMiddleware]) -> Router {
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
    public func error(handler: RouterHandler...) -> Router {
        return routingHelper(.Error, pattern: nil, handler: handler)
    }

    public func error(handler: [RouterHandler]) -> Router {
        return routingHelper(.Error, pattern: nil, handler: handler)
    }

    public func error(middleware: RouterMiddleware...) -> Router {
        return routingHelper(.Error, pattern: nil, middleware: middleware)
    }

    public func error(middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.Error, pattern: nil, middleware: middleware)
    }

    private func routingHelper(method: RouterMethod, pattern: String?, handler: [RouterHandler]) -> Router {
        routeElems.append(RouterElement(method: method, pattern: pattern, handler: handler))
        return self
    }

    private func routingHelper(method: RouterMethod, pattern: String?, middleware: [RouterMiddleware]) -> Router {
        routeElems.append(RouterElement(method: method, pattern: pattern, middleware: middleware))
        return self
    }

    // MARK: Template Engine
    public func setDefaultTemplateEngine(templateEngine: TemplateEngine?) {
        if let templateEngine = templateEngine {
            defaultEngineFileExtension = templateEngine.fileExtension
            addTemplateEngine(templateEngine)
            return
        }
        defaultEngineFileExtension = nil
    }

    public func addTemplateEngine(templateEngine: TemplateEngine) {
        templateEngines[templateEngine.fileExtension] = templateEngine
    }

    internal func render(resource: String, context: [String: Any]) throws -> String {
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
        return try templateEngine.render(filePath, context: context)
    }

    public func route(route: String) -> Router {
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
#if os(Linux)
        let prefixRange = urlPath.rangeOfString(mountpath)
#else
        let prefixRange = urlPath.range(of: mountpath)
#endif
        request.parsedUrl.path?.removeSubrange(prefixRange!)
        if request.parsedUrl.path == "" {
            request.parsedUrl.path = "/"
        }

        processRequest(request, response: response) {
            request.parsedUrl.path = urlPath
            next()
        }
    }
}


///
/// HttpServerDelegate extensions
///
extension Router : HttpServerDelegate {

    ///
    /// Handle the request
    ///
    /// - Parameter request: the server request
    /// - Parameter response: the server response
    ///
    public func handleRequest(request: ServerRequest, response: ServerResponse) {

        let routeReq = RouterRequest(request: request)
        let routeResp = RouterResponse(response: response, router: self, request: routeReq)
        processRequest(routeReq, response: routeResp) { [unowned self] () in
            do {
                if  !routeResp.invokedEnd {
                    if  routeResp.response.statusCode == HttpStatusCode.NOT_FOUND  {
                        self.sendDefaultResponse(routeReq, routeResp: routeResp)
                    }
                    try routeResp.end()
                }
            }
            catch {
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
    private func processRequest(request: RouterRequest, response: RouterResponse, callback: () -> Void) {

        guard let urlPath = request.parsedUrl.path else {
            Log.error("Failed to process request")
            return
        }

#if os(Linux)
        let shouldContinue = urlPath.characters.count > kituraResourcePrefix.characters.count && urlPath.bridge().substringToIndex(kituraResourcePrefix.characters.count) == kituraResourcePrefix
#else
        let lengthIndex = kituraResourcePrefix.startIndex.advanced(by: kituraResourcePrefix.characters.count)
        let shouldContinue = urlPath.characters.count > kituraResourcePrefix.characters.count && urlPath.substring(to: lengthIndex) == kituraResourcePrefix
#endif
        if  shouldContinue {
#if os(Linux)
            let resource = urlPath.bridge().substringFromIndex(kituraResourcePrefix.characters.count)
#else
            let resource = urlPath.substring(from: lengthIndex)
#endif
            sendResourceIfExisting(response, resource: resource)
        }
        else {
            var elemIndex = -1

            // Extra variable to get around use of variable in its own initializer
            var nextElemCallback: (()->Void)? = nil

            let nextElemCallbackHandler = {[unowned request, unowned response, unowned self] () -> Void in
                elemIndex+=1
                if  elemIndex < self.routeElems.count {
                    guard let nextElemCallback = nextElemCallback else {
                        return
                    }
                    self.routeElems[elemIndex].process(request, response: response, next: nextElemCallback)
                }
                else {
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
    private func sendDefaultResponse(routeReq: RouterRequest, routeResp: RouterResponse) {
        if  routeReq.parsedUrl.path == "/"  {
            sendResourceIfExisting(routeResp, resource: "index.html")
        }
        else {
            do {
                try routeResp.status(HttpStatusCode.NOT_FOUND).send("Cannot \(String(routeReq.method).uppercased()) \(routeReq.parsedUrl.path ?? "").").end()
            }
            catch {}
        }
    }

    private func getResourceFilePath(resource: String) -> String {
        let fileName = NSString(string: #file)
        let resourceFilePrefixRange: NSRange
#if os(Linux)
        let lastSlash = fileName.rangeOfString("/", options: NSStringCompareOptions.BackwardsSearch)
#else
        let lastSlash = fileName.range(of: "/", options: NSStringCompareOptions.backwardsSearch)
#endif
        if  lastSlash.location != NSNotFound  {
            resourceFilePrefixRange = NSMakeRange(0, lastSlash.location+1)
        }
        else {
            resourceFilePrefixRange = NSMakeRange(0, fileName.length)
        }
#if os(Linux)
        return fileName.substringWithRange(resourceFilePrefixRange) + "resources/" + resource
#else
        return fileName.substring(with: resourceFilePrefixRange) + "resources/" + resource
#endif
    }


    ///
    /// Get the directory we were compiled from
    ///
    private func sendResourceIfExisting(routeResp: RouterResponse, resource: String)  {
        let resourceFileName = getResourceFilePath(resource)

        do {
            try routeResp.sendFile(resourceFileName)
            routeResp.status(HttpStatusCode.OK)
            try routeResp.end()
        }
        catch {
            // Fail silently
        }
    }
}
