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

import LoggerAPI
import Foundation

extension StaticFileServer {

    // MARK: ResourcePathHandler
    class ResourcePathHandler {
        static func getAbsolutePath(for path: String) -> String {
            var path = path
            if path.hasSuffix("/") {
                path = String(path.characters.dropLast())
            }

            // If we received a path with a tilde (~) in the front, expand it.
            path = NSString(string: path).expandingTildeInPath

            return path
        }
    }
}
