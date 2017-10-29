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

    /// Collection of `RouterParameterHandler` for specified parameter name
    private var parameterHandlers: [String : [RouterParameterHandler]]

    init(handlers: [String : [RouterParameterHandler]]) {
        self.parameterHandlers = handlers
    }

    /// Invoke all possible parameter handlers for request
    ///
    /// - Parameter request: A current `RouterRequest` that is handled by a server
    /// - Parameter response: A current `RouterResponse` that is handled by a server
    /// - Parameter callback: A callback that will be invoked after all possible handlers are invoked
    func handle(request: RouterRequest, response: RouterResponse, with callback: @escaping () -> Void) {
        guard self.parameterHandlers.count > 0 else {
            callback()
            return
        }

        let filtered = request.parameters.filter { (key, _) in
            self.parameterHandlers.keys.contains(key) && !request.handledNamedParameters.contains(key)
            }.map { ($0, $1) }

        self.handle(filtered: filtered, request: request, response: response, with: callback)
    }

    private func handle(filtered: [(String, String)], request: RouterRequest, response: RouterResponse, with callback: @escaping () -> Void) {
        guard filtered.count > 0 else {
            callback()
            return
        }

        var parameters = filtered
        let (key, value) = parameters.remove(at: parameters.startIndex)

        if !request.handledNamedParameters.contains(key),
            (self.parameterHandlers[key]?.count ?? 0) > 0,
            let handler = self.parameterHandlers[key]?.remove(at: 0) {
            do {
                try handler(request, response, value) {
                    self.handle(filtered: parameters, request: request, response: response, with: callback)
                }
            } catch {
                response.error = error
                self.handle(filtered: parameters, request: request, response: response, with: callback)
            }
        } else {
            request.handledNamedParameters.insert(key)
            self.parameterHandlers[key] = nil
            self.handle(filtered: parameters, request: request, response: response, with: callback)
        }
    }
}
