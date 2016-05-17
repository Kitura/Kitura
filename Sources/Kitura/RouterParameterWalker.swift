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

class RouterParameterWalker
{
    /// The array of handlers
    private let handlers: [RouterParameterHandler]

    /// The current router request
    private let request: RouterRequest

    /// The current router response
    private let response: RouterResponse

    /// Callback to call once all handlers have been processed
    private let callback: () -> Void

    /// The current query parameter value
    private let value: String

    /// Index of the current handler
    private var handlerIndex = -1

    init(handlers: [RouterParameterHandler], request: RouterRequest, response: RouterResponse, callback: () -> Void, value: String) {
        self.handlers = handlers
        self.request = request
        self.response = response
        self.callback = callback
        self.value = value
    }

    ///
    /// Handle the next middleware
    ///
    func next() {
        handlerIndex += 1

        if handlerIndex < handlers.count && response.error == nil {
            let handlerCallback = { [unowned self] in
                self.next()
            }
            handlers[handlerIndex](request: request, response: response, next: handlerCallback, value: value)
        } else {
            request.params = [:]
            callback()
        }
    }
}
