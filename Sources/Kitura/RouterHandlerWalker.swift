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

// MARK: RouterHandlerWalker

class RouterHandlerWalker
{
    /// The array of router elements to be processed
    private let routeElems: [RouterElement]

    /// The current router request
    private let request: RouterRequest

    /// The current router response
    private let response: RouterResponse

    /// Callback to execute once all elements have been processed
    private let callback: () -> Void

    /// Index of element currently being processed
    private var elemIndex = -1

    init(routeElems: [RouterElement], request: RouterRequest, response: RouterResponse, callback: () -> Void) {
        self.routeElems = routeElems
        self.request = request
        self.response = response
        self.callback = callback
    }

    ///
    /// Process the next router element
    ///
    func next() {
        elemIndex += 1

        if elemIndex < self.routeElems.count {
            routeElems[elemIndex].process(request: request, response: response) {
                [unowned self] in
                self.next()
            }
        } else {
            callback()
        }
    }
}
