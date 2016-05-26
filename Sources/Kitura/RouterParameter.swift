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


import KituraSys
import LoggerAPI

import Foundation

public class RouterParameter: RouterMiddleware {

    private var name: String
    private var handlers: [RouterParameterHandler]

    public init(name: String, handlers: [RouterParameterHandler]) {
        self.name = name
        self.handlers = handlers
    }

    public func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let parameterValue = request.queryParams[self.name] else {
            next()
            return
        }

        let looper = RouterParameterWalker(handlers: handlers,
          request: request,
          response: response,
          callback: next,
          value: parameterValue)

        looper.next()
    }
}
