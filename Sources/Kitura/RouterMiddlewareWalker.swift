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

class RouterMiddlewareWalker
{
    private let middlewares: [RouterMiddleware]
    private let method: RouterMethod
    private let request: RouterRequest
    private let response: RouterResponse
    private let callback: () -> Void

    private var middlewareCount = -1

    init(middlewares: [RouterMiddleware], method: RouterMethod, request: RouterRequest, response: RouterResponse, callback: () -> Void) {
        self.middlewares = middlewares
        self.method = method
        self.request = request
        self.response = response
        self.callback = callback
    }

    func next() {
        middlewareCount += 1

        if middlewareCount < middlewares.count && (response.error == nil || method == .error) {
            middlewares[middlewareCount].handle(request: request, response: response) {
                [unowned self] in
                self.next()
            }
        } else {
            request.params = [:]
            callback()
        }
    }
}
