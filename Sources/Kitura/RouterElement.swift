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
    static var keyRegex: NSRegularExpression?

    ///
    /// The regular expression matcher
    ///
    static var nonKeyRegex: NSRegularExpression?

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

        (regex, keys) = RouteRegex.sharedInstance.buildRegex(fromPattern: pattern, allowPartialMatch: allowPartialMatch)
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
        guard let urlPath = request.parsedUrl.path else {
            Log.error("Failed to process request (path is nil)")
            return
        }

        guard (response.error != nil && method == .Error)
        || (response.error == nil && (method == request.method || method == .All)) else {
            next()
            return
        }

        // Either response error exists and method is error, or method matches
        guard let regex = regex else {
            request.route = pattern
            request.params = [:]
            processHelper(request: request, response: response, next: next)
            return
        }

        guard let match = regex.firstMatch(in: urlPath, options: [], range: NSMakeRange(0, urlPath.characters.count)) else {
            next()
            return
        }

#if os(Linux)
          request.matchedPath = urlPath.bridge().substringWithRange(match.range)
#else
          request.matchedPath = urlPath.bridge().substring(with: match.range)
#endif

          request.route = pattern
          updateRequestParams(urlPath, match: match, request: request)
          processHelper(request: request, response: response, next: next)
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
        var nextCallbackPlaceholder: (()->Void)?

        let nextCallback = {
            middlewareCount += 1
            if middlewareCount < self.middlewares.count && (response.error == nil || self.method == .Error) {
                guard let nextCallbackPlaceholder = nextCallbackPlaceholder else { return }
                self.middlewares[middlewareCount].handle(request: request, response: response, next: nextCallbackPlaceholder)
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
    private func updateRequestParams(_ urlPath: String, match: NSTextCheckingResult, request: RouterRequest) {

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
/// RouterHandler is a closure
///
public typealias RouterHandler = (request: RouterRequest, response: RouterResponse, next: ()->Void) -> Void
