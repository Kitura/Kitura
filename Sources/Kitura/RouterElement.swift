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
    /// - Parameter request: the request
    /// - Parameter response: the response
    /// - Parameter next: the callback
    ///
    func process(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let urlPath = request.parsedURL.path else {
            Log.error("Failed to process request (path is nil)")
            return
        }

        guard (response.error != nil && method == .error)
        || (response.error == nil && (method == request.method || method == .all)) else {
            next()
            return
        }

        // Either response error exists and method is error, or method matches
        guard let regex = regex else {
            request.route = pattern
            request.parameters = [:]
            processHelper(request: request, response: response, next: next)
            return
        }

        guard let match = regex.firstMatch(in: urlPath, options: [], range: NSMakeRange(0, urlPath.characters.count)) else {
            next()
            return
        }

        request.matchedPath = urlPath.bridge().substring(with: match.range)

        request.route = pattern
        setParameters(forRequest: request, fromUrlPath: urlPath, match: match)
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
        let looper = RouterMiddlewareWalker(middlewares: middlewares, method: method, request: request, response: response, callback: next)
        looper.next()
    }

    ///
    /// Update the request parameters
    ///
    /// - Parameter match: the regular expression result
    /// - Parameter request:
    ///
    private func setParameters(forRequest request: RouterRequest, fromUrlPath urlPath: String, match: NSTextCheckingResult) {

        var parameters = [String:String]()
        if  let keys = keys {
            for index in 0..<keys.count {
                let matchRange = match.range(at: index+1)
                if  matchRange.location != NSNotFound  &&  matchRange.location != -1  {
                    parameters[keys[index]] = urlPath.bridge().substring(with: matchRange)
                }
            }
        }
        request.parameters = parameters
    }
}
