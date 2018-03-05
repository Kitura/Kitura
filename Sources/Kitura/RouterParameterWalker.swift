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

/// A [type alias](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Declarations.html#//apple_ref/doc/uid/TP40014097-CH34-ID361) declaration to describe a handler for named parameters when using `Router.parameter(...)`. The example below shows two ways to use it, both as a function named `handler` to handle the "id" parameter and as a closure to handle the "name" parameter.
/// ### Usage Example: ###
/// ```swift
/// let router = Router()
/// func handler(request: RouterRequest, response: RouterResponse, param: String, next: @escaping () -> Void) throws -> Void {
///     //Code to handle id parameter here
///     next()
/// }
/// router.parameter("id", handler: handler)
///
/// router.parameter("name") { request, response, param, next in
///     //Code to handle name parameter here
///     next()
/// }
/// router.get("/item/:id") { request, response, next in
///     //This will be reached after the id parameter is handled by `handler`
/// }
/// router.get("/user/:name") { request, response, next in
///     //This will be reached after the name parameter is handled by the closure above
/// }
/// ```
/// - Parameter request: The `RouterRequest` object used to work with the incoming
///                     HTTP request.
/// - Parameter response: The `RouterResponse` object used to respond to the
///                     HTTP request.
/// - Parameter param: The named parameter to be handled.
/// - Parameter next: The closure called to invoke the next handler or middleware
///                     associated with the request.


public typealias RouterParameterHandler = (RouterRequest, RouterResponse, String, @escaping () -> Void) throws -> Void

class RouterParameterWalker {

    /// Collection of `RouterParameterHandler` instances for a specified parameter name.
    private var parameterHandlers: [String : [RouterParameterHandler]]

    init(handlers: [String : [RouterParameterHandler]]) {
        self.parameterHandlers = handlers
    }

    /// Invoke all possible parameter handlers for the request.
    ///
    /// - Parameter request: The `RouterRequest` object used to work with the incoming
    ///                     HTTP request.
    /// - Parameter response: The `RouterResponse` object used to respond to the
    ///                     HTTP request.
    /// - Parameter callback: The callback that will be invoked after all possible
    ///                         handlers are invoked.
    func handle(request: RouterRequest, response: RouterResponse, with callback: @escaping () -> Void) {
        guard self.parameterHandlers.count > 0 else {
            callback()
            return
        }

        let filtered = request.parameters.filter { (key, _) in
            self.parameterHandlers.keys.contains(key) && !request.handledNamedParameters.contains(key)
            }.map { ($0, $1) }

        self.handle(filtered: filtered, request: request, response: response, with: callback)
    }

    private func handle(filtered: [(String, String)], request: RouterRequest, response: RouterResponse, with callback: @escaping () -> Void) {
        guard filtered.count > 0 else {
            callback()
            return
        }

        var parameters = filtered
        let (key, value) = parameters[0]

        if !request.handledNamedParameters.contains(key),
            (self.parameterHandlers[key]?.count ?? 0) > 0,
            let handler = self.parameterHandlers[key]?.remove(at: 0) {
            do {
                try handler(request, response, value) {
                    self.handle(filtered: parameters, request: request, response: response, with: callback)
                }
            } catch {
                response.error = error
                self.handle(filtered: parameters, request: request, response: response, with: callback)
            }
        } else {
            request.handledNamedParameters.insert(key)
            self.parameterHandlers[key] = nil
            parameters.remove(at: parameters.startIndex)
            self.handle(filtered: parameters, request: request, response: response, with: callback)
        }
    }
}
