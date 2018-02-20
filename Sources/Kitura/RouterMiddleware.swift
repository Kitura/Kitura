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

// MARK: RouterMiddleware protocol

/// Defines the protocol which all Kitura compliant middleware must implement.
///
/// Middleware are class or struct based request handlers. They are often generic
/// in nature and not tied to a specific request.
public protocol RouterMiddleware {

    /// Handle an incoming HTTP request.
    ///
    /// - Parameter request: The `RouterRequest` object used to work with the incoming
    ///                     HTTP request.
    /// - Parameter response: The `RouterResponse` object used to respond to the
    ///                     HTTP request.
    /// - Parameter next: The closure called to invoke the next handler or middleware
    ///                     associated with the request.
    ///
    /// - Throws: Any `ErrorType`. If an error is thrown, processing of the request
    ///          is stopped, the error handlers, if any are defined, will be invoked,
    ///          and the user will get a response with a status code of 500.
    func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws
}
