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

// Composite design pattern
class CompositeRelatedHeadersSetter: ResponseHeadersSetter {

    let responseHeadersSetters: [ResponseHeadersSetter]

    init(setters: ResponseHeadersSetter?...) {
        responseHeadersSetters = setters.filter { $0 != nil }.map { $0! }
    }

    func setCustomResponseHeaders(response: RouterResponse, filePath: String,
                                  fileAttributes: [FileAttributeKey : Any]) {
        responseHeadersSetters.forEach { $0.setCustomResponseHeaders(response: response,
                                                                     filePath: filePath,
                                                                     fileAttributes: fileAttributes)
        }
    }
}
