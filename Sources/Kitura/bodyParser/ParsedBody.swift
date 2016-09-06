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

/// The result of parsing the body of the request.
///
/// When a body of a request is parsed the results of the parsing are placed 
/// in the associated value of the enum case based on Content-Type
public indirect enum ParsedBody {
    
    /// If the content type was "application/json" this associated value will 
    /// contain the body of a JSON object.
    case json(JSON)
    
    /// If the content type was "application/x-www-form-urlencoded" this 
    /// associated value will contain a representation of the body as a
    /// dictionary of key-value pairs.
    case urlEncoded([String:String])
    
    /// If the content type was "text" this associated value will contain a
    /// representation of the body as a String.
    case text(String)
    
    /// A raw representation of the body as a Data struct.
    case raw(Data)
    
    /// If the content type was "multipart/form-data" this associated value will
    /// contain an array of parts of multi-part respresentation of the body.
    case multipart([Part])
}
