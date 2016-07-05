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

// MARK: RouterMiddlewareWalker

class RouterMiddlewareWalker
{
    /// The array of middlewares to handle
    private let middlewares: [RouterMiddleware]

    /// The current router method
    private let method: RouterMethod

    /// The current router request
    private let request: RouterRequest

    /// The current router response
    private let response: RouterResponse

    /// Callback to call once all middlewares have been handled
    private let callback: () -> Void

    /// Index of the current middleware being handled
    private var middlewareIndex = -1

    init(middlewares: [RouterMiddleware], method: RouterMethod, request: RouterRequest, response: RouterResponse, callback: () -> Void) {
        self.middlewares = middlewares
        self.method = method
        self.request = request
        self.response = response
        self.callback = callback
    }

    ///
    /// Handle the next middleware
    ///
    func next() {
        middlewareIndex += 1

        if middlewareIndex < middlewares.count && (response.error == nil || method == .error) {
            do {
                // Purposfully capture self here
                try middlewares[middlewareIndex].handle(request: request, response: response) {
                    self.next()
                }
            }
            catch {
                response.error = error
                self.next()
            }
            
        } else {
            callback()
        }
    }
}
