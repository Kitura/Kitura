/*
 * Copyright IBM Corporation 2015
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

// MARK Router

extension Router {
    // MARK: error

    /// Setup error handling that will cause a set of one or more closures
    /// of the type `RouterHandler` to be invoked when an error occurs.
    ///
    /// - Parameter handler: A comma delimited set of `RouterHandler` that will be
    ///                     invoked if an error ocurrs.
    @discardableResult
    public func error(_ handler: RouterHandler...) -> Router {
        return routingHelper(.error, pattern: nil, handler: handler)
    }

    /// Setup error handling that will cause an array of one or more closures
    /// of the type `RouterHandler` to be invoked when an error occurs.
    ///
    /// - Parameter handler: An array of `RouterHandler` that will be
    ///                     invoked if an error ocurrs.
    @discardableResult
    public func error(_ handler: [RouterHandler]) -> Router {
        return routingHelper(.error, pattern: nil, handler: handler)
    }

    /// Setup error handling that will cause a set of one or more `RouterMiddleware`
    /// to be invoked when an error occurs.
    ///
    /// - Parameter middleware: A comma delimited set of `RouterMiddleware` that will be
    ///                        invoked if an error ocurrs.
    @discardableResult
    public func error(_ middleware: RouterMiddleware...) -> Router {
        return routingHelper(.error, pattern: nil, middleware: middleware)
    }

    /// Setup error handling that will cause an array of one or more `RouterMiddleware`
    /// to be invoked when an error occurs.
    ///
    /// - Parameter middleware: An array of `RouterMiddleware` that will be
    ///                        invoked if an error ocurrs.
    @discardableResult
    public func error(_ middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.error, pattern: nil, middleware: middleware)
    }
}
