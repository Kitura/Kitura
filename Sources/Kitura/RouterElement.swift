/*
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
 */

import KituraSys
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
        private var regex: RegularExpression?
    #else
        private var regex: NSRegularExpression?
    #endif

    /// The list of keys
    private var keys: [String]?

    /// The middlewares to use
    private let middlewares: [RouterMiddleware]

    /// Initialize a RouterElement
    ///
    /// - Parameter method: The `RouterMethod`
    /// - Parameter pattern: The String pattern to use
    /// - Parameter middleware: The `RouterMiddleware`s used to handle
    /// - Parameter allowPartialMatch: Are partial matches allowed. Defaults to true.
    /// - Returns: A `RouterElement` instance
    ///
    init(method: RouterMethod, pattern: String?, middleware: [RouterMiddleware], allowPartialMatch: Bool = true) {
        self.method = method
        self.pattern = pattern
        self.regex = nil
        self.keys = nil
        self.middlewares = middleware

        (regex, keys) = RouteRegex.sharedInstance.buildRegex(fromPattern: pattern, allowPartialMatch: allowPartialMatch)
    }

    /// Convenience initializer
    convenience init(method: RouterMethod, pattern: String?, handler: [RouterHandler]) {
        self.init(method: method, pattern: pattern, middleware: handler.map {RouterMiddlewareGenerator(handler: $0)}, allowPartialMatch: false)
    }

    /// Process
    ///
    /// - Parameter request: the request
    /// - Parameter response: the response
    /// - Parameter next: the callback
    func process(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        guard let path = request.parsedURL.path else {
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
        
        let nsPath = NSString(string: path)

        guard let match = regex.firstMatch(in: path, options: [], range: NSMakeRange(0, path.characters.count)) else {
            next()
            return
        }

        request.matchedPath = nsPath.substring(with: match.range)

        request.route = pattern
        setParameters(forRequest: request, fromUrlPath: nsPath, match: match)
        processHelper(request: request, response: response, next: next)
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
        typealias TextChekingResultType = TextCheckingResult
    #else
        typealias TextChekingResultType = NSTextCheckingResult
    #endif

    /// Update the request parameters
    ///
    /// - Parameter match: the regular expression result
    /// - Parameter request:
    private func setParameters(forRequest request: RouterRequest, fromUrlPath urlPath: NSString, match: TextChekingResultType) {
        var parameters = [String:String]()
        if let keys = keys {
            for index in 0..<keys.count {
                #if os(Linux)
                    let matchRange = match.range(at: index+1)
                #else
                    let matchRange = match.rangeAt(index+1)
                #endif
                if  matchRange.location != NSNotFound  &&  matchRange.location != -1  {
                    parameters[keys[index]] = urlPath.substring(with: matchRange)
                }
            }
        }
        request.parameters = parameters
    }
}
