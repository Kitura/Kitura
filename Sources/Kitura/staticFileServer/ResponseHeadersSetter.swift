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

// MARK ResponseHeadersSetter

/// A protocol for providing a custom method for setting
/// the headers of the response of static file serving middleware.
public protocol ResponseHeadersSetter {

    /// Set the headers of the response
    ///
    /// - Parameter response: the router response
    /// - Parameter filePath: the path of the file being served
    /// - Parameter fileAttributes: an array of attributes of the file being served
    func setCustomResponseHeaders(response: RouterResponse, filePath: String, fileAttributes: [FileAttributeKey : Any])

}
