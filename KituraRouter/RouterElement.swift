/**
 * Copyright IBM Corporation 2016
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


import KituraSys

import Foundation

// MARK: RouterElement

class RouterElement {

    ///
    /// The regular expression matcher
    ///
    static let keyRegex = Regex()
    
    ///
    /// The regular expression matcher
    ///
    static let nonKeyRegex = Regex()
    
    ///
    /// Status of regex initialization
    ///
    static var regexInit: Int = 0
    
    ///
    /// The routing method (get, post, put, delete)
    ///
    private let method: RouterMethod
    
    ///
    /// The regular expression pattern
    ///
    private let pattern: String?
    
    ///
    /// The regular expression
    ///
    private var regex: Regex?
    
    ///
    /// The list of keys
    ///
    private var keys:[String]?
    
    ///
    /// The handler
    ///
    private var handler: RouterHandler?
    
    ///
    /// The middleware to use
    ///
    private var middleware: RouterMiddleware?
    
    /// 
    /// initializes a RouterElement
    ///
    /// - Parameter method: the RouterMethod
    /// - Parameter pattern: the String pattern to use
    ///
    /// - Returns: a RouterElement instance
    ///
    private init(method: RouterMethod, pattern: String?) {
        
        self.method = method
        self.pattern = pattern
        self.regex = nil
        self.keys = nil
        self.handler = nil
        self.middleware = nil
        
        SysUtils.doOnce(&RouterElement.regexInit) {
            RouterElement.keyRegex.compile("(.*)?(?:\\:(\\w+)(?:\\(((?:\\\\.|[^()])+)\\))?(?:([+*?])?))")
            RouterElement.nonKeyRegex.compile("(.*)?(?:(?:\\(((?:\\\\.|[^()])+)\\))(?:([+*?])?))")
        }
        
        // Needs to be after the initialization of the static Regex's
        (regex, keys) = buildRegexFromPattern(pattern)
        
    }
    
    ///
    /// Convenience initializer
    ///
    convenience init(method: RouterMethod, pattern: String? , handler: RouterHandler) {
        
        self.init(method: method, pattern: pattern)
        
        self.handler = handler
        
    }
    
    ///
    /// Convenience initializer 
    ///
    convenience init(method: RouterMethod, pattern: String?, middleware: RouterMiddleware) {
        
        self.init(method: method, pattern: pattern)
        
        self.middleware = middleware
        
    }
    
    ///
    /// Process 
    ///
    /// - Parameter httpMethod: the method 
    /// - Parameter urlPath: the path 
    /// - Parameter request: the request
    /// - Parameter response: the response
    ///
    func process(httpMethod: RouterMethod, urlPath: NSData, request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        if  method == .All  ||  method == httpMethod {
            if  let r = regex  {
                let matcher = r.matcher!
                if  matcher.match(urlPath) {
                    request.route = pattern
                    updateRequestParams(matcher, request: request)
                    processHelper(request, response: response, next: next)
                } else {
                    next()
                }
            }
            else {
                request.route = pattern
                request.params = [:]
                processHelper(request, response: response, next: next)
            }
        } else {
            next()
        }
    }
    
    ///
    /// Process the helper
    ///
    /// - Parameter request: the request
    /// - Parameter response: the router response 
    /// - Parameter next: the closure for the next execution block
    ///
    private func processHelper(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        if  let handler = handler  {
            handler(request: request, response: response) { () in
                request.params = [:]
                next()
            }
        }
        else if  let middleware = middleware  {
            middleware.handle(request, response: response) { () in
                request.params = [:]
                next()
            }
        }

    }
    
    ///
    /// Builds a regular expression from a String pattern 
    ///
    /// - Parameter pattern: Optional string
    ///
    /// - Returns:
    ///
    private func buildRegexFromPattern(pattern: String?) -> (Regex?, [String]?) {
        
        if  let p = pattern  {
            let keyMatcher = RouterElement.keyRegex.matcher!
            let nonKeyMatcher = RouterElement.nonKeyRegex.matcher!
            
            var regexStr = "^"
            var keys: [String] = []
            var nonKeyIndex = 0
            
            let paths = p.bridge().componentsSeparatedByString("/")
            
            // Special case where only back slashes are specified
            if paths.filter({$0 != ""}).count == 0 {
                regexStr.appendContentsOf("/")
            }
            
            for path in paths {
                // If there was a leading slash, there will be an empty component in the split
                if  path.characters.count > 0  {
                    var matched = false
                    var prefix: String = ""
                    var matchExp: String?
                    
                    if  path == "*"  {
                        // Handle a path element of * specially
                        matchExp = ".*"
                        matched = true
                    }
                    else {
                        //var plusQuestStar: String?
                        if  keyMatcher.match(path)  {
                            // We found a path element with a named/key capture
                            if  let pathPrefix = keyMatcher.getMatchedElement(1)  {
                                prefix = pathPrefix
                            }
                            matchExp = keyMatcher.getMatchedElement(3)
                            if  matchExp?.characters.count == 0  {
                                matchExp = "[^/]+?"
                            }
                            //plusQuestStar = keyMatcher.getMatchedElement(4)!
                            keys.append(keyMatcher.getMatchedElement(2)!)
                            matched = true
                        }
                        else if  nonKeyMatcher.match(path) {
                            // We found a path element with an unnamed capture
                            if  let pathPrefix = nonKeyMatcher.getMatchedElement(1)  {
                                prefix = pathPrefix
                            }
                            matchExp = nonKeyMatcher.getMatchedElement(2)!
                            //plusQuestStar = nonKeyMatcher.getMatchedElement(3)!
                            keys.append(String(nonKeyIndex))
                            nonKeyIndex+=1
                            matched = true
                        }
                    }
                
                    if  matched  {
                        // We have some kind of capture for this path element
                        regexStr.appendContentsOf("/")
                        regexStr.appendContentsOf(prefix)
                        
                        regexStr.appendContentsOf("(?:(")
                        regexStr.appendContentsOf(matchExp!)
                        regexStr.appendContentsOf("))")
                    }
                    else {
                        // A path element with no capture
                        regexStr.appendContentsOf("/")
                        regexStr.appendContentsOf(path)
                    }
                }
            }
            regexStr.appendContentsOf("?(?:/)?$")
            
            var regex: Regex? = Regex()
            if  !regex!.compile(regexStr) {
                regex = nil
            }
            
            return (regex, keys)
        }
        else {
            return (nil, nil)
        }
    }
    
    ///
    /// Update the update request parameters
    ///
    /// - Parameter matcher: the regular expression matcher
    /// - Parameter request:
    ///
    private func updateRequestParams(matcher: RegexMatcher, request: RouterRequest) {
        
        if  let k = keys {
            var params: [String:String] = [:]
            for index in 0..<k.count {
                params[k[index]] = matcher.getMatchedElement(index+1)
            }
            request.params = params
        }
        
    }
}

///
/// Values for Router methods (Get, Post, Put, Delete, etc)
///
enum RouterMethod :Int {
    
    case All, Get, Post, Put, Head, Delete, Options, Trace, Copy, Lock, MkCol, Move, Purge, PropFind, PropPatch, Unlock, Report, MkActivity, Checkout, Merge, MSearch, Notify, Subscribe, Unsubscribe, Patch, Search, Connect, Error, Unknown
    
    
    init(string: String) {
        switch string.lowercaseString {
            case "all":
                self = .All
                break
            case "get":
                self = .Get
                break
            case "post":
                self = .Post
                break
            case "put":
                self = .Put
                break
            case "head":
                self = .Head
                break
            case "delete":
                self = .Delete
                break
            case "options":
                self = .Options
                break
            case "trace":
                self = .Trace
                break
            case "copy":
                self = .Copy
                break
            case "lock":
                self = .Lock
                break
            case "mkcol":
                self = .MkCol
                break
            case "move":
                self = .Move
                break
            case "purge":
                self = .Purge
                break
            case "propfind":
                self = .PropFind
                break
            case "proppatch":
                self = .PropPatch
                break
            case "unlock":
                self = .Unlock
                break
            case "report":
                self = .Report
                break
            case "mkactivity":
                self = .MkActivity
                break
            case "checkout":
                self = .Checkout
                break
            case "merge":
                self = .Merge
                break
            case "m-search":
                self = .MSearch
                break
            case "notify":
                self = .Notify
                break
            case "subscribe":
                self = .Subscribe
                break
            case "unsubscribe":
                self = .Unsubscribe
                break
            case "patch":
                self = .Patch
                break
            case "search":
                self = .Search
                break
            case "connect":
                self = .Connect
                break
            case "error":
                self = .Error
                break
            default:
                self = .Unknown
        }
    }
}

///
/// RouterHandler is a closure
///
public typealias RouterHandler = (request: RouterRequest, response: RouterResponse, next: ()->Void) -> Void
