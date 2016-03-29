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

    internal var templateEngine: TemplateEngine? = nil

    ///
    /// Views directory path
    ///
    public var viewsPath: String { return "./Views/" }

    ///
    /// Prefix for special page resources
    ///
    private let kituraResourcePrefix = "/@@Kitura-router@@/"

    internal (set) var prefix: String?

    ///
    /// Initializes a Router
    ///
    /// - Returns: a Router instance
    ///
    public init() {

        // Read the MIME types
        ContentType.initialize()

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
    @available(*, deprecated, message="Use Router.all instead")
    public func use(middleware: RouterMiddleware...) -> Router {
        routeElems.append(RouterElement(method: .All, pattern: nil, middleware: middleware))
        return self
    }

    @available(*, deprecated, message="Use Router.all instead")
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
        for mid in middleware {
            if let subrouter = mid as? Router {
                subrouter.prefix = pattern
            }
        }
        let path = pattern ??  ""
        routeElems.append(RouterElement(method: method, pattern: path, middleware: middleware))
        return self
    }

    // MARK: Template Engine
    public func setTemplateEngine(templateEngine: TemplateEngine?) {
        self.templateEngine = templateEngine
    }
}

extension Router : RouterMiddleware {
    public func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        processRequest(request, response: response)
        next()
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
        processRequest(routeReq, response: routeResp)
    }

    private func processRequest(request: RouterRequest, response: RouterResponse) {

        let urlPath = request.parsedUrl.path!

        if  urlPath.characters.count > kituraResourcePrefix.characters.count  &&  urlPath.bridge().substringToIndex(kituraResourcePrefix.characters.count) == kituraResourcePrefix  {
            let resource = urlPath.bridge().substringFromIndex(kituraResourcePrefix.characters.count)
            sendResourceIfExisting(response, resource: resource)
        }
        else {
            var elemIndex = -1

            // Extra variable to get around use of variable in its own initializer
            var callback: (()->Void)? = nil

            let callbackHandler = {[unowned request, unowned response, unowned self] () -> Void in
                elemIndex+=1
                if  elemIndex < self.routeElems.count {
                    self.routeElems[elemIndex].process(self.prefix, urlPath: urlPath, request: request, response: response, next: callback!)
                }
                else {
                    do {
                        if  !response.invokedEnd {
                            if  response.response.statusCode == HttpStatusCode.NOT_FOUND  {
                                self.sendDefaultResponse(request, routeResp: response)
                            }
                            try response.end()
                        }
                    }
                    catch {
                        // Not much to do here
                        Log.error("Failed to send response to the client")
                    }
                }
            }
            callback = callbackHandler

            callbackHandler()
        }
    }

    ///
    /// Send default index.html file and it's resources if appropriate, otherwise send default 404 message
    ///
    private func sendDefaultResponse(routeReq: RouterRequest, routeResp: RouterResponse) {
        if  routeReq.parsedUrl.path! == "/"  {
            sendResourceIfExisting(routeResp, resource: "index.html")
        }
        else {
            do {
                try routeResp.status(HttpStatusCode.NOT_FOUND).send("Cannot \(String(routeReq.method).uppercaseString) \(routeReq.parsedUrl.path!).").end()
            }
            catch {}
        }
    }

    private func getResourceFilePath(resource: String) -> String {
        let fileName = NSString(string: #file)
        let resourceFilePrefixRange: NSRange
        let lastSlash = fileName.rangeOfString("/", options: NSStringCompareOptions.BackwardsSearch)
        if  lastSlash.location != NSNotFound  {
            resourceFilePrefixRange = NSMakeRange(0, lastSlash.location+1)
        }
        else {
            resourceFilePrefixRange = NSMakeRange(0, fileName.length)
        }
        return fileName.substringWithRange(resourceFilePrefixRange) + "resources/" + resource
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
