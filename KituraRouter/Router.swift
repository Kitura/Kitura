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

// MARK Router 

public class Router {
    
    ///
    /// Contains the list of routing elements
    ///
    private var routeElems: [RouterElement] = []
    
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
    public func all(handler: RouterHandler) -> Router {
        return routingHelper(.All, pattern: nil, handler: handler)
    }
    
    public func all(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.All, pattern: path, handler: handler)
    }
    
    // MARK: Get
    public func get(handler: RouterHandler) -> Router {
        return routingHelper(.Get, pattern: nil, handler: handler)
    }
    
    public func get(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Get, pattern: path, handler: handler)
    }
    
    // MARK: Post
    public func post(handler: RouterHandler) -> Router {
        return routingHelper(.Post, pattern: nil, handler: handler)
    }
    
    public func post(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Post, pattern: path, handler: handler)
    }
    
    // MARK: Put
    public func put(handler: RouterHandler) -> Router {
        return routingHelper(.Put, pattern: nil, handler: handler)
    }
    
    public func put(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Put, pattern: path, handler: handler)
    }
    
    // MARK: Delete
    public func delete(handler: RouterHandler) -> Router {
        return routingHelper(.Delete, pattern: nil, handler: handler)
    }
    
    public func delete(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Delete, pattern: path, handler: handler)
    }
    
    // MARK: Options
    public func options(handler: RouterHandler) -> Router {
        return routingHelper(.Options, pattern: nil, handler: handler)
    }
    
    public func options(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Options, pattern: path, handler: handler)
    }
    
    // MARK: Trace
    public func trace(handler: RouterHandler) -> Router {
        return routingHelper(.Trace, pattern: nil, handler: handler)
    }
    
    public func trace(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Trace, pattern: path, handler: handler)
    }
    
    // MARK: Copy
    public func copy(handler: RouterHandler) -> Router {
        return routingHelper(.Copy, pattern: nil, handler: handler)
    }
    
    public func copy(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Copy, pattern: path, handler: handler)
    }
    
    // MARK: Lock
    public func lock(handler: RouterHandler) -> Router {
        return routingHelper(.Lock, pattern: nil, handler: handler)
    }
    
    public func lock(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Lock, pattern: path, handler: handler)
    }
    
    // MARK: MkCol
    public func mkCol(handler: RouterHandler) -> Router {
        return routingHelper(.MkCol, pattern: nil, handler: handler)
    }
    
    public func mkCol(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.MkCol, pattern: path, handler: handler)
    }
    
    // MARK: Move
    public func move(handler: RouterHandler) -> Router {
        return routingHelper(.Move, pattern: nil, handler: handler)
    }
    
    public func move(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Move, pattern: path, handler: handler)
    }
    
    // MARK: Purge
    public func purge(handler: RouterHandler) -> Router {
        return routingHelper(.Purge, pattern: nil, handler: handler)
    }
    
    public func purge(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Purge, pattern: path, handler: handler)
    }
    
    // MARK: Propfind
    public func propFind(handler: RouterHandler) -> Router {
        return routingHelper(.PropFind, pattern: nil, handler: handler)
    }
    
    public func propFind(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.PropFind, pattern: path, handler: handler)
    }
    
    // MARK: PropPatch
    public func propPatch(handler: RouterHandler) -> Router {
        return routingHelper(.PropPatch, pattern: nil, handler: handler)
    }
    
    public func propPatch(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.PropPatch, pattern: path, handler: handler)
    }
    
    // MARK: Unlock
    public func unlock(handler: RouterHandler) -> Router {
        return routingHelper(.Unlock, pattern: nil, handler: handler)
    }
    
    public func unlock(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Unlock, pattern: path, handler: handler)
    }
    
    // MARK: Report
    public func report(handler: RouterHandler) -> Router {
        return routingHelper(.Report, pattern: nil, handler: handler)
    }
    
    public func report(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Report, pattern: path, handler: handler)
    }
    
    // MARK: MkActivity
    public func mkActivity(handler: RouterHandler) -> Router {
        return routingHelper(.MkActivity, pattern: nil, handler: handler)
    }
    
    public func mkActivity(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.MkActivity, pattern: path, handler: handler)
    }
    
    // MARK: Checkout
    public func checkout(handler: RouterHandler) -> Router {
        return routingHelper(.Checkout, pattern: nil, handler: handler)
    }
    
    public func checkout(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Checkout, pattern: path, handler: handler)
    }
    
    // MARK: Merge
    public func merge(handler: RouterHandler) -> Router {
        return routingHelper(.Merge, pattern: nil, handler: handler)
    }
    
    public func merge(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Merge, pattern: path, handler: handler)
    }
    
    // MARK: MSearch
    public func mSearch(handler: RouterHandler) -> Router {
        return routingHelper(.MSearch, pattern: nil, handler: handler)
    }
    
    public func mSearch(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.MSearch, pattern: path, handler: handler)
    }
    
    // MARK: Notify
    public func notify(handler: RouterHandler) -> Router {
        return routingHelper(.Notify, pattern: nil, handler: handler)
    }
    
    public func notify(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Notify, pattern: path, handler: handler)
    }
    
    // MARK: Subscribe
    public func subscribe(handler: RouterHandler) -> Router {
        return routingHelper(.Subscribe, pattern: nil, handler: handler)
    }
    
    public func subscribe(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Subscribe, pattern: path, handler: handler)
    }
    
    // MARK: Unsubscribe
    public func unsubscribe(handler: RouterHandler) -> Router {
        return routingHelper(.Unsubscribe, pattern: nil, handler: handler)
    }
    
    public func unsubscribe(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Unsubscribe, pattern: path, handler: handler)
    }
    
    // MARK: Patch
    public func patch(handler: RouterHandler) -> Router {
        return routingHelper(.Patch, pattern: nil, handler: handler)
    }
    
    public func patch(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Patch, pattern: path, handler: handler)
    }
    
    // MARK: Search
    public func search(handler: RouterHandler) -> Router {
        return routingHelper(.Search, pattern: nil, handler: handler)
    }
    
    public func search(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Search, pattern: path, handler: handler)
    }
    
    // MARK: Connect
    public func connect(handler: RouterHandler) -> Router {
        return routingHelper(.Connect, pattern: nil, handler: handler)
    }
    
    public func connect(path: String, handler: RouterHandler) -> Router {
        return routingHelper(.Connect, pattern: path, handler: handler)
    }

    // MARK: Use
    public func use(middleware: RouterMiddleware) -> Router {
        routeElems.append(RouterElement(method: .All, pattern: nil, middleware: middleware))
        return self
    }
    
    public func use(path: String, middleware: RouterMiddleware) -> Router {
        routeElems.append(RouterElement(method: .All, pattern: path, middleware: middleware))
        return self
    }

    private func routingHelper(method: RouterMethod, pattern: String?, handler: RouterHandler) -> Router {
        routeElems.append(RouterElement(method: method, pattern: pattern, handler: handler))
        return self
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
        let routeResp = RouterResponse(response: response)
        let method = RouterMethod(string: request.method)
        
        let urlPath = StringUtils.toUtf8String(routeReq.parsedUrl.path!)
        if  urlPath != nil  {
            var elemIndex = -1
        
            // Extra variable to get around use of variable in its own initializer
            var callback: (()->Void)? = nil
        
            let callbackHandler = {[unowned routeReq, unowned routeResp] () -> Void in
                elemIndex+=1
                if  elemIndex < self.routeElems.count  &&  routeResp.error == nil {
                    self.routeElems[elemIndex].process(method, urlPath: urlPath!, request: routeReq, response: routeResp, next: callback!)
                }
                else {
                    do {
                        if  routeResp.error != nil  {
                            let message = "Server error: \(routeResp.error!.localizedDescription)"
                            Log.error(message)
                            try routeResp.status(.INTERNAL_SERVER_ERROR).end(message)
                        }
                        else if  !routeResp.invokedEnd {
                            if  response.statusCode == HttpStatusCode.NOT_FOUND  {
                                self.sendDefaultIndexHtml(routeReq, routeResp: routeResp)
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
            callback = callbackHandler

            callbackHandler()
        }
    }

    ///
    /// Send default index.html file and it's resources if appropriate
    ///
    private func sendDefaultIndexHtml(routeReq: RouterRequest, routeResp: RouterResponse) {
         if  routeReq.parsedUrl.path! == "/"  {
              sendResourceIfExisting(routeResp, resource: "index.html")
         }
         else if routeReq.parsedUrl.path! == "/@@Kitura-router@@/kitura.svg"  {
              sendResourceIfExisting(routeResp, resource: "kitura.svg")
         }
    }

    ///
    /// Get the directory we were compiled from
    ///
    private func sendResourceIfExisting(routeResp: RouterResponse, resource: String)  {
        let fileName = NSString(string: __FILE__)
        let jsonFilePrefixRange: NSRange
        let lastSlash = fileName.rangeOfString("/", options: NSStringCompareOptions.BackwardsSearch)
        if  lastSlash.location != NSNotFound  {
            jsonFilePrefixRange = NSMakeRange(0, lastSlash.location+1)
        }
        else {
            jsonFilePrefixRange = NSMakeRange(0, fileName.length)
        }
        let resourceFileName = fileName.substringWithRange(jsonFilePrefixRange) + "resources/" + resource

        do {
            try routeResp.sendFile(resourceFileName)
            routeResp.status(HttpStatusCode.OK)
        }
        catch {
            // Fail silently
        }
    }
}
