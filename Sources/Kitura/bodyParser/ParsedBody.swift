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

import SwiftyJSON
import Foundation

// MARK ParsedBody

/// The result of body parsing
///
/// - SeeAlso: `BodyParser.parse(_ mesage:, contentType:)->ParsedBody?`
public indirect enum ParsedBody {
    
    /// A JSON representation of the body
    case json(JSON)
    
    /// A representation of the body as dictionary of URL encoded key-value pairs
    case urlEncoded([String:String])
    
    /// A plane text representation of the body
    case text(String)
    
    /// A raw data representation of the body
    case raw(Data)
    
    /// An array of parts of multi-part respresentation of the body
    case multipart([Part])
}
