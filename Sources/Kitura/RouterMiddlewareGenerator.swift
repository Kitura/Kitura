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

// MARK: RouterMiddlewareGenerator

 /**
 Create an on the fly `RouterMiddleware` from a `RouterHandler` closure.
 
 ### Usage Example: ###
  In this example "middleware" has been made, which follows the `RouterMiddleware` protocol. "middleware" will return the HTTPStatusCode .OK with the body "Hello World". This middleware is then assigned to a router for the route "/hello".
 ```swift
 let middleware = RouterMiddlewareGenerator { _, response, next in
     response.status(HTTPStatusCode.OK).send("Hello World\n")
     next()
 }
 router.all("/hello", middleware: middleware)
 ```
 */
public class RouterMiddlewareGenerator: RouterMiddleware {

    /// The closure invoked to handle requests
    private let innerHandler: RouterHandler

    /// Initialize a `RouterMiddlewareGenerator` instance
    ///
    /// - Parameter handler: The closure that is of the type `RouterHandler` to be
    ///                     called to handle requests
    public init(handler: @escaping RouterHandler) {
        innerHandler = handler
    }

    /// Implementation of RouterMiddleware protocol. A simple wrapper around the closure
    /// that will handle the request.
    ///
    /// - Parameter request: The `RouterRequest` object that is used to work with
    ///                     the incoming request.
    /// - Parameter response: The `RouterResponse` object used to send responses
    ///                      to the HTTP request.
    /// - Parameter next: The closure to invoke to cause the router to inspect the
    ///                  path in the list of paths.
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        try innerHandler(request, response, next)
    }
}
