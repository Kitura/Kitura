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

import Foundation

// possibly known error, e.g. user tries to access an invalid url path
// it makes sense to send the error as HTTP response
enum Error: Swift.Error {
    case failedToParseRequestBody(body: String)
    case failedToRedirectRequest(path: String, chainedError: Swift.Error)
}

extension Error: CustomStringConvertible {
    var description: String {
        switch self {
        case .failedToParseRequestBody(let body):
             return "Failed to parse request body \(body)"
        case .failedToRedirectRequest(let path, let chainedError):
            return "Failed to redirect a request for directory at \(path)" +
                     " caught error = \(chainedError)"
        }
    }
}
