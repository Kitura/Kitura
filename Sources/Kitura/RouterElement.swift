/*
 * Copyright IBM Corporation 2016, 2017
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

import LoggerAPI

import Foundation

// MARK: RouterElement

class RouterElement {

    /// The routing method (get, post, put, delete)
    let method: RouterMethod

    /// The regular expression pattern
    private let pattern: String?

    /// The regular expression
    #if os(Linux)
        #if swift(>=3.1)
            private var regex: NSRegularExpression?
        #else
            private var regex: RegularExpression?
        #endif
    #else
        private var regex: NSRegularExpression?
    #endif
    
    /// The pattern is a simple string
    private var isSimpleString = false

    /// The list of keys
    private var keys: [String]?

    /// The middlewares to use
    private let middlewares: [RouterMiddleware]

    /// Whether or not this RouterElement should removed the matched section of path or
    /// keep it for its middlewares to use
    private let allowPartialMatch: Bool

    /// Whether or not this RouterElement should make its parent's parsed parameters
    /// available for its middlewares to use
    private let mergeParameters: Bool

    /// Initialize a RouterElement
    ///
    /// - Parameter method: The `RouterMethod`
    /// - Parameter pattern: The String pattern to use
    /// - Parameter middleware: The `RouterMiddleware`s used to handle
    /// - Parameter allowPartialMatch: Are partial matches allowed. Defaults to true.
    /// - Parameter mergeParameters: Specify if this router should have access to path
    /// parameters matched in its parent router. Defaults to `false`.
    /// - Returns: A `RouterElement` instance
    ///
    init(method: RouterMethod, pattern: String?, middleware: [RouterMiddleware],
         allowPartialMatch: Bool = true, mergeParameters: Bool = false) {
        self.method = method
        self.pattern = pattern?.hasPrefix("/") ?? true ? pattern : "/" + (pattern ?? "")
        self.regex = nil
        self.keys = nil
        self.middlewares = middleware
        self.allowPartialMatch = allowPartialMatch
        self.mergeParameters = mergeParameters

        (regex, isSimpleString, keys) = RouteRegex.sharedInstance.buildRegex(fromPattern: pattern, allowPartialMatch: allowPartialMatch)
    }

    /// Convenience initializer
    convenience init(method: RouterMethod, pattern: String?, handler: [RouterHandler],
                     mergeParameters: Bool = false) {
        self.init(method: method, pattern: pattern,
                  middleware: handler.map {RouterMiddlewareGenerator(handler: $0)},
                  allowPartialMatch: false, mergeParameters: mergeParameters)
    }

    /// Process
    ///
    /// - Parameter request: the request
    /// - Parameter response: the response
    /// - Parameter parameterWalker: the walker for the list of parameter handlers
    /// - Parameter next: the callback
    func process(request: RouterRequest, response: RouterResponse, parameterWalker: RouterParameterWalker, next: @escaping () -> Void) {
        guard let path = request.parsedURLPath.path else {
            Log.error("Failed to process request (path is nil)")
            return
        }

        guard (response.error != nil && method == .error)
            || (response.error == nil && (method == request.method || method == .all)) else {
            next()
            return
        }
        
        // Check and see if the pattern is just a simple string
        guard !isSimpleString else {
            performSimpleMatch(path: path, request: request, response: response, next: next)
            return
        }

        // Either response error exists and method is error, or method matches
        guard let regex = regex else {
            request.allowPartialMatch = allowPartialMatch
            request.matchedPath = ""
            request.parameters = mergeParameters ? request.parameters : [:]
            request.route = pattern
            processHelper(request: request, response: response, next: next)
            return
        }

        // The pattern is a regular expression that needs to be checked
        let nsPath = NSString(string: path)

        guard let match = regex.firstMatch(in: path, options: [], range: NSRange(location: 0, length: path.characters.count)) else {
            next()
            return
        }

        request.matchedPath = nsPath.substring(with: match.range)
        request.allowPartialMatch = allowPartialMatch

        request.route = pattern
        setParameters(forRequest: request, fromUrlPath: nsPath, match: match)

        parameterWalker.handle(request: request, response: response) {
            self.processHelper(request: request, response: response, next: next)
        }
    }
    
    /// Perform a simple match
    ///
    /// - Parameter path: the path being matched
    /// - Parameter request: the request
    /// - Parameter response: the router response
    /// - Parameter next: the closure for the next execution block
    private func performSimpleMatch(path: String, request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        guard let pattern = pattern else { return }
        
        let pathToMatch = path.isEmpty ? "/" : path
        var matched: Bool
        let matchedPath: String
        
        if allowPartialMatch {
            matched = pathToMatch.hasPrefix(pattern)
            if matched && pattern != "/" {
                let patternCount = pattern.characters.count
                if pathToMatch.characters.count > patternCount {
                    matched = pathToMatch[pathToMatch.index(pathToMatch.startIndex, offsetBy: patternCount)] == "/"
                }
            }
            matchedPath = matched && !pattern.isEmpty && pattern != "/" ? pattern : ""
        }
        else {
            matched = pathToMatch == pattern
            matchedPath = matched ? pathToMatch : ""
        }
        
        if matched {
            request.matchedPath = matchedPath
            request.allowPartialMatch = allowPartialMatch
            request.parameters = mergeParameters ? request.parameters : [:]
            request.route = pattern
            processHelper(request: request, response: response, next: next)
        }
        else {
            next()
        }
    }

    /// Process the helper
    ///
    /// - Parameter request: the request
    /// - Parameter response: the router response
    /// - Parameter next: the closure for the next execution block
    private func processHelper(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        let looper = RouterMiddlewareWalker(middlewares: middlewares, method: method, request: request, response: response, callback: next)
        looper.next()
    }

    #if os(Linux)
        typealias TextCheckingResultType = TextCheckingResult
    #else
        typealias TextCheckingResultType = NSTextCheckingResult
    #endif

    /// Update the request parameters
    ///
    /// - Parameter match: the regular expression result
    /// - Parameter request:
    private func setParameters(forRequest request: RouterRequest, fromUrlPath urlPath: NSString, match: TextCheckingResultType) {
        var parameters = mergeParameters ? request.parameters : [:]

        if let keys = keys {
            for index in 0..<keys.count {
                #if os(Linux)
                    let matchRange = match.range(at: index+1)
                #else
                    let matchRange = match.rangeAt(index+1)
                #endif
                if  matchRange.location != NSNotFound  &&  matchRange.location != -1  {
                    var parameter = urlPath.substring(with: matchRange)
                    if let decodedParameter = parameter.removingPercentEncoding {
                        parameter = decodedParameter
                    } else {
                        Log.warning("Unable to decode parameter \(keys[index])")
                    }
                    parameters[keys[index]] = parameter
                }
            }
        }
        request.parameters = parameters
    }
}
