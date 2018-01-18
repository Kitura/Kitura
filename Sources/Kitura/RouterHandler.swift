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

/// A dummy class to get the documentation for the RouterHandler below to be emitted.
private class DummyRouterHAndlerClass {}

/// The definition of the closure type that is used by the `Router` class
/// when routing HTTP requests to closure.
///
/// - Parameter request: The `RouterRequest` object used to work with the incoming
///                     HTTP request.
/// - Parameter response: The `RouterResponse` object used to respond to the
///                     HTTP request.
/// - Parameter next: The closure called to invoke the next handler or middleware
///                     associated with the request.
public typealias RouterHandler = (RouterRequest, RouterResponse, @escaping () -> Void) throws -> Void
