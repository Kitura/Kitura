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

// MARK: RouterElementWalker

class RouterElementWalker {

    /// The array of router elements to be processed
    private let elements: [RouterElement]

    /// The current router request
    private let request: RouterRequest

    /// The current router response
    private let response: RouterResponse

    /// Callback to execute once all elements have been processed
    private let callback: () -> Void

    /// Index of element currently being processed
    private var elementIndex = -1

    /// Copy of request parameters to enable mergeParams
    private let parameters: [String: String]

    /// An instance of `RouterParameterWalker` that is used to handle named parameters of requests
    private var parameterWalker: RouterParameterWalker

    init(elements: [RouterElement], parameterHandlers: [String : [RouterParameterHandler]],
        request: RouterRequest, response: RouterResponse, callback: @escaping () -> Void) {
        self.elements = elements
        self.request = request
        self.response = response
        self.callback = callback
        self.parameters = request.parameters

        self.parameterWalker = RouterParameterWalker(handlers: parameterHandlers)
    }

    /// Process the next router element
    func next() {
        elementIndex += 1

        if elementIndex < self.elements.count {
            // reset parameters before processing next element
            request.parameters = parameters

            elements[elementIndex].process(request: request,
                response: response,
                parameterWalker: self.parameterWalker) {
                // Purposefully capture self here
                self.next()
            }
        } else {
            callback()
        }
    }
}
