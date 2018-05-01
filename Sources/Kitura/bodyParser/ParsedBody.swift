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

// MARK ParsedBody

/// The result of parsing the body of the request.
///
/// When a body of a request is parsed the results of the parsing are placed
/// in the associated value of the enum case based on Content-Type
public indirect enum ParsedBody {

    /// If the content type was "application/x-www-form-urlencoded" this
    /// associated value will contain a representation of the body as a
    /// dictionary of key-value pairs.
    case urlEncoded([String:String])

    /// If the content type was "application/x-www-form-urlencoded" this
    /// associated value will contain a representation of the body as a
    /// dictionary of key-[value] pairs.
    case urlEncodedMultiValue([String: [String]])

    /// If the content type was "text" this associated value will contain a
    /// representation of the body as a String.
    case text(String)

    /// A raw representation of the body as a Data struct.
    case raw(Data)

    /// If the content type was "multipart/form-data" this associated value will
    /// contain an array of parts of multi-part respresentation of the body.
    case multipart([Part])

    /// If the content type was "application/json" this associated value will
    /// contain the body of a [String: Any] json dictionary object.
    case json([String: Any])

    /// Extract a "JSON" body from the `ParsedBody` enum
    ///
    /// - Returns: The parsed body as a [String: Any] object, or nil if the body wasn't in
    ///           JSON format.
    public var asJSON: [String: Any]? {
        switch self {
        case .json(let body):
            return body
        default:
            return nil
        }
    }

    /// Extract a "multipart" body from the `ParsedBody` enum
    ///
    /// - Returns: The parsed body as an array of `Part` structs, or nil if the body wasn't in
    ///           multi-part form format.
    public var asMultiPart: [Part]? {
        switch self {
        case .multipart(let body):
            return body
        default:
            return nil
        }
    }
    
    /// Extract a "raw" body from the `ParsedBody` enum
    ///
    /// - Returns: The "raw" body as a Data, or nil if the body wasn't in raw format.
    public var asRaw: Data? {
        switch self {
        case .raw(let body):
            return body
        default:
            return nil
        }
    }

    /// Extract a "text" body from the `ParsedBody` enum
    ///
    /// - Returns: The "text" body as a String, or nil if the body wasn't in text format.
    public var asText: String? {
        switch self {
        case .text(let body):
            return body
        default:
            return nil
        }
    }

    /// Extract a "urlEncoded" body from the `ParsedBody` enum with comma-
    /// separated values.
    ///
    /// - Returns: The parsed body as a Dictionary<String, String>, or nil if the body wasn't in
    ///           url encoded form format.
    public var asURLEncoded: [String:String]? {
        switch self {
        case .urlEncoded(let body):
            return body
        default:
            return nil
        }
    }

    /// Extract a "urlEncoded" body from the `ParsedBody` enum with values in
    /// an array..
    ///
    /// - Returns: The parsed body as a Dictionary<String, Array<String>>, or
    ///            nil if the body wasn't in url encoded form format.
    public var asURLEncodedMultiValue: [String: [String]]? {
        switch self {
        case .urlEncodedMultiValue(let body):
            return body
        default:
            return nil
        }
    }
}
