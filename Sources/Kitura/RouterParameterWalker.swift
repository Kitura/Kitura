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

public typealias RouterParameterHandler = (RouterRequest, RouterResponse, String, @escaping () -> Void) throws -> Void

class RouterParameterWalker {

    ///
    private var parameterHandlers: [String : [RouterParameterHandler]]

    init(handlers: [String : [RouterParameterHandler]]) {
        self.parameterHandlers = handlers
    }

    func handle(request: RouterRequest, response: RouterResponse, with callback: @escaping () -> Void) {
        let filtered = request.parameters.filter { (key, _) in self.parameterHandlers.keys.contains(key) }
        self.handle(filtered: filtered, request: request, response: response, with: callback)
    }

    private func handle(filtered: [(String, String)], request: RouterRequest, response: RouterResponse, with callback: @escaping () -> Void) {
        if filtered.count > 0 {
            var parameters = filtered
            let (key, value) = parameters.remove(at: parameters.startIndex)

            if self.parameterHandlers[key]!.count > 0 {
                let handler = self.parameterHandlers[key]!.remove(at: 0)

                do {
                    try handler(request, response, value) {
                        self.handle(filtered: parameters, request: request, response: response, with: callback)
                    }
                } catch {
                    response.error = error
                    self.handle(filtered: parameters, request: request, response: response, with: callback)
                }
            }

            self.parameterHandlers[key] = nil
            self.handle(filtered: parameters, request: request, response: response, with: callback)
        } else {
            callback()
        }
    }
}
