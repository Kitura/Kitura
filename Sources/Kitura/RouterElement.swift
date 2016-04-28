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
import LoggerAPI

import Foundation

// MARK: RouterElement

class RouterElement {

    ///
    /// The regular expression matcher
    ///
    static var keyRegex: NSRegularExpression? = nil

    ///
    /// The regular expression matcher
    ///
    static var nonKeyRegex: NSRegularExpression? = nil

    ///
    /// Status of regex initialization
    ///
    private static var regexInit: Int = 0

    ///
    /// The routing method (get, post, put, delete)
    ///
    let method: RouterMethod

    ///
    /// The regular expression pattern
    ///
    private let pattern: String?

    ///
    /// The regular expression
    ///
    private var regex: NSRegularExpression?

    ///
    /// The list of keys
    ///
    private var keys: [String]?

    ///
    /// The middleware to use
    ///
    private let middlewares: [RouterMiddleware]

    ///
    /// initializes a RouterElement
    ///
    /// - Parameter method: the RouterMethod
    /// - Parameter pattern: the String pattern to use
    /// - Parameter middleware: the RouterMiddleware used to handle
    ///
    /// - Returns: a RouterElement instance
    ///
    init(method: RouterMethod, pattern: String?, middleware: [RouterMiddleware], allowPartialMatch: Bool = true) {

        self.method = method
        self.pattern = pattern
        self.regex = nil
        self.keys = nil
        self.middlewares = middleware

        (regex, keys) = RouteRegex.sharedInstance.buildRegexFromPattern(pattern, allowPartialMatch: allowPartialMatch)

    }

    ///
    /// Convenience initializer
    ///
    convenience init(method: RouterMethod, pattern: String?, handler: [RouterHandler]) {

        self.init(method: method, pattern: pattern, middleware: handler.map {RouterMiddlewareGenerator(handler: $0)}, allowPartialMatch: false)
    }

    ///
    /// Process
    ///
    /// - Parameter httpMethod: the method
    /// - Parameter urlPath: the path
    /// - Parameter request: the request
    /// - Parameter response: the response
    ///
    func process(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        let urlPath = request.parsedUrl.path!

        if response.error == nil || method == .Error {
            if response.error != nil || method == .All || method == request.method {
                // Either response error exists and method is error, or method matches
                if  let regex = regex {
#if os(Linux)
                    let tempMatch = regex.firstMatchInString(urlPath, options: [], range: NSMakeRange(0, urlPath.characters.count))
#else
                    let tempMatch = regex.firstMatch(in: urlPath, options: [], range: NSMakeRange(0, urlPath.characters.count))
#endif
                    if  let match = tempMatch  {
#if os(Linux)
                    request.matchedPath = urlPath.bridge().substringWithRange(match.range)
#else
                    request.matchedPath = urlPath.bridge().substring(with: match.range)
#endif
                        request.route = pattern
                        updateRequestParams(urlPath, match: match, request: request)
                        processHelper(request, response: response, next: next)
                    } else {
                        next()
                    }
                } else {
                    request.route = pattern
                    request.params = [:]
                    processHelper(request, response: response, next: next)
                }
            } else {
                next()
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
        var middlewareCount = -1

        // Extra variable since closures cannot be used in their own initalizer
        var nextCallbackPlaceholder: (()->Void)? = nil

        let nextCallback = {
            middlewareCount += 1
            if middlewareCount < self.middlewares.count && (response.error == nil || self.method == .Error) {
                self.middlewares[middlewareCount].handle(request, response: response, next: nextCallbackPlaceholder!)
            } else {
                request.params = [:]
                next()
            }
        }
        nextCallbackPlaceholder = nextCallback
        nextCallback()
    }

    ///
    /// Update the update request parameters
    ///
    /// - Parameter match: the regular expression result
    /// - Parameter request:
    ///
    private func updateRequestParams(urlPath: String, match: NSTextCheckingResult, request: RouterRequest) {

        if  let keys = keys {
            var params: [String:String] = [:]
            for index in 0..<keys.count {
#if os(Linux)
                let matchRange = match.rangeAtIndex(index+1)
#else
                let matchRange = match.range(at: index+1)
#endif
                if  matchRange.location != NSNotFound  &&  matchRange.location != -1  {
#if os(Linux)
                    params[keys[index]] = urlPath.bridge().substringWithRange(matchRange)
#else
                    params[keys[index]] = urlPath.bridge().substring(with: matchRange)
#endif
                }
            }
            request.params = params
        }

    }
}

///
/// Values for Router methods (Get, Post, Put, Delete, etc)
///
public enum RouterMethod: Int {

    case All, Get, Post, Put, Head, Delete, Options, Trace, Copy, Lock, MkCol, Move, Purge, PropFind, PropPatch, Unlock, Report, MkActivity, Checkout, Merge, MSearch, Notify, Subscribe, Unsubscribe, Patch, Search, Connect, Error, Unknown

    init(string: String) {
        switch string.lowercased() {
            case "all":
                self = .All
            case "get":
                self = .Get
            case "post":
                self = .Post
            case "put":
                self = .Put
            case "head":
                self = .Head
            case "delete":
                self = .Delete
            case "options":
                self = .Options
            case "trace":
                self = .Trace
            case "copy":
                self = .Copy
            case "lock":
                self = .Lock
            case "mkcol":
                self = .MkCol
            case "move":
                self = .Move
            case "purge":
                self = .Purge
            case "propfind":
                self = .PropFind
            case "proppatch":
                self = .PropPatch
            case "unlock":
                self = .Unlock
            case "report":
                self = .Report
            case "mkactivity":
                self = .MkActivity
            case "checkout":
                self = .Checkout
            case "merge":
                self = .Merge
            case "m-search":
                self = .MSearch
            case "notify":
                self = .Notify
            case "subscribe":
                self = .Subscribe
            case "unsubscribe":
                self = .Unsubscribe
            case "patch":
                self = .Patch
            case "search":
                self = .Search
            case "connect":
                self = .Connect
            case "error":
                self = .Error
            default:
                self = .Unknown
        }
    }
}

///
/// RouterHandler is a closure
///
public typealias RouterHandler = (request: RouterRequest, response: RouterResponse, next: ()->Void) -> Void
