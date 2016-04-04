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
    private var keys:[String]?

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

        SysUtils.doOnce(&RouterElement.regexInit) {
            do {
                RouterElement.keyRegex = try NSRegularExpression(pattern: "(.*)?(?:\\:(\\w+)(?:\\(((?:\\\\.|[^()])+)\\))?(?:([+*?])?))", options: [])
                RouterElement.nonKeyRegex = try NSRegularExpression(pattern: "(.*)?(?:(?:\\(((?:\\\\.|[^()])+)\\))(?:([+*?])?))", options: [])
            }
            catch {
                Log.error("Failed to create regular expressions used to parse Route patterns")
            }
        }

        // Needs to be after the initialization of the static Regex's
        (regex, keys) = buildRegexFromPattern(pattern, allowPartialMatch: allowPartialMatch)

    }

    ///
    /// Convenience initializer
    ///
    convenience init(method: RouterMethod, pattern: String? , handler: [RouterHandler]) {

        self.init(method: method, pattern: pattern, middleware: handler.map{RouterMiddlewareGenerator(handler: $0)}, allowPartialMatch: false)
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
                if  let regex = regex  {
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
                }
                else {
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
            }
            else {
                request.params = [:]
                next()
            }
        }
        nextCallbackPlaceholder = nextCallback
        nextCallback()
    }

    ///
    /// Builds a regular expression from a String pattern
    ///
    /// - Parameter pattern: Optional string
    ///
    /// - Returns:
    ///
    private func buildRegexFromPattern(pattern: String?, allowPartialMatch: Bool = false) -> (NSRegularExpression?, [String]?) {

        if  let pattern = pattern  {
            var regexStr = "^"
            var keys: [String] = []
            var nonKeyIndex = 0

#if os(Linux)  
            let paths = pattern.bridge().componentsSeparatedByString("/")  
#else
            let paths = pattern.bridge().componentsSeparated(by: "/")
#endif

            // Special case where only back slashes are specified
            if paths.filter({$0 != ""}).count == 0 {
                regexStr.append("/")
            }

            for path in paths {
                // If there was a leading slash, there will be an empty component in the split
                if  path.characters.count > 0  {
                    var matched = false
                    var prefix = ""
                    var matchExp = "[^/]+?"
                    var plusQuestStar = ""

                    if  path == "*"  {
                        // Handle a path element of * specially
                        matchExp = ".*"
                        matched = true
                    }
                    else {
                        let range = NSMakeRange(0, path.characters.count)
#if os(Linux)  
                        if  let keyMatch = RouterElement.keyRegex!.firstMatchInString(path, options: [], range: range)  {
                            // We found a path element with a named/key capture
                            let prefixRange = keyMatch.rangeAtIndex(1)
                            if  prefixRange.location != NSNotFound  &&  prefixRange.location != -1  {
                                prefix = path.bridge().substringWithRange(prefixRange)
                            }
                            let matchExpRange = keyMatch.rangeAtIndex(3)
                            if  matchExpRange.location != NSNotFound  &&  matchExpRange.location != -1  {
                                matchExp = path.bridge().substringWithRange(matchExpRange)
                            }
                            let pqsRange = keyMatch.rangeAtIndex(4)
                            if  pqsRange.location != NSNotFound  &&  pqsRange.location != -1  {
                                plusQuestStar = path.bridge().substringWithRange(pqsRange)
                            }
                            keys.append(path.bridge().substringWithRange(keyMatch.rangeAtIndex(2)))
                            matched = true
                        }
                        else if  let nonKeyMatch = RouterElement.nonKeyRegex!.firstMatchInString(path, options: [], range: range) {
                            // We found a path element with an unnamed capture
                            let prefixRange = nonKeyMatch.rangeAtIndex(1)
                            if  prefixRange.location != NSNotFound  &&  prefixRange.location != -1  {
                                prefix = path.bridge().substringWithRange(prefixRange)
                            }
                            let matchExpRange = nonKeyMatch.rangeAtIndex(2)
                            if  matchExpRange.location != NSNotFound  &&  matchExpRange.location != -1  {
                                matchExp = path.bridge().substringWithRange(matchExpRange)
                            }
                            let pqsRange = nonKeyMatch.rangeAtIndex(3)
                            if  pqsRange.location != NSNotFound  &&  pqsRange.location != -1  {
                                plusQuestStar = path.bridge().substringWithRange(pqsRange)
                            }
                            keys.append(String(nonKeyIndex))
                            nonKeyIndex+=1
                            matched = true
                        }
#else
                        if  let keyMatch = RouterElement.keyRegex!.firstMatch(in: path, options: [], range: range)  {
                            // We found a path element with a named/key capture
                            let prefixRange = keyMatch.range(at: 1)
                            if  prefixRange.location != NSNotFound  &&  prefixRange.location != -1  {
                                prefix = path.bridge().substring(with: prefixRange)
                            }
                            let matchExpRange = keyMatch.range(at: 3)
                            if  matchExpRange.location != NSNotFound  &&  matchExpRange.location != -1  {
                                matchExp = path.bridge().substring(with: matchExpRange)
                            }
                            let pqsRange = keyMatch.range(at: 4)
                            if  pqsRange.location != NSNotFound  &&  pqsRange.location != -1  {
                                plusQuestStar = path.bridge().substring(with: pqsRange)
                            }
                            keys.append(path.bridge().substring(with: keyMatch.range(at: 2)))
                            matched = true
                        }
                        else if  let nonKeyMatch = RouterElement.nonKeyRegex!.firstMatch(in: path, options: [], range: range) {
                            // We found a path element with an unnamed capture
                            let prefixRange = nonKeyMatch.range(at: 1)
                            if  prefixRange.location != NSNotFound  &&  prefixRange.location != -1  {
                                prefix = path.bridge().substring(with: prefixRange)
                            }
                            let matchExpRange = nonKeyMatch.range(at: 2)
                            if  matchExpRange.location != NSNotFound  &&  matchExpRange.location != -1  {
                                matchExp = path.bridge().substring(with: matchExpRange)
                            }
                            let pqsRange = nonKeyMatch.range(at: 3)
                            if  pqsRange.location != NSNotFound  &&  pqsRange.location != -1  {
                                plusQuestStar = path.bridge().substring(with: pqsRange)
                            }
                            keys.append(String(nonKeyIndex))
                            nonKeyIndex+=1
                            matched = true
                        }
#endif
                    }

                    if  matched  {
                        // We have some kind of capture for this path element
                        // Build the runtime regex depending on whether or not there is "repetition"
                        switch(plusQuestStar) {
                            case "+":
                                regexStr.append("/")
                                regexStr.append(prefix)
                                regexStr.append("(")
                                regexStr.append(matchExp)
                                regexStr.append("(?:/")
                                regexStr.append(matchExp)
                                regexStr.append(")*)")
                            case "?":
                                if  prefix.isEmpty  {
                                    regexStr.append("(?:/(")
                                    regexStr.append(matchExp)
                                    regexStr.append("))?")
                                }
                                else {
                                    regexStr.append("/")
                                    regexStr.append(prefix)
                                    regexStr.append("(?:(")
                                    regexStr.append(matchExp)
                                    regexStr.append("))?")
                                }
                            case "*":
                                if  prefix.isEmpty  {
                                    regexStr.append("(?:/(")
                                    regexStr.append(matchExp)
                                    regexStr.append("(?:/")
                                    regexStr.append(matchExp)
                                    regexStr.append(")*))?")
                                }
                                else {
                                    regexStr.append("/")
                                    regexStr.append(prefix)
                                    regexStr.append("(?:(")
                                    regexStr.append(matchExp)
                                    regexStr.append("(?:/")
                                    regexStr.append(matchExp)
                                    regexStr.append(")*))?")
                                }
                            default:
                                regexStr.append("/")
                                regexStr.append(prefix)
                                regexStr.append("(?:(")
                                regexStr.append(matchExp)
                                regexStr.append("))")
                        }
                    }
                    else {
                        // A path element with no capture
                        regexStr.append("/")
                        regexStr.append(path)
                    }
                }
            }
            regexStr.append("(?:/(?=$))?")
            if !allowPartialMatch {
                regexStr.append("$")
            }

            var regex: NSRegularExpression? = nil
            do {
                regex = try NSRegularExpression(pattern: regexStr, options: [])
            }
            catch {
                Log.error("Failed to compile the regular expression for the route \(pattern)")
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
public enum RouterMethod :Int {

    case All, Get, Post, Put, Head, Delete, Options, Trace, Copy, Lock, MkCol, Move, Purge, PropFind, PropPatch, Unlock, Report, MkActivity, Checkout, Merge, MSearch, Notify, Subscribe, Unsubscribe, Patch, Search, Connect, Error, Unknown

    init(string: String) {
        switch string.lowercased() {
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
