/*
 * Copyright IBM Corporation 2018
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

/// DecodingError Extension to print human readable error messages for clients
extension DecodingError {
    
    /// Concats the CodingKeys to provide a key path string
    static func codingKeyAsPrefixString(from codingKeys: [CodingKey]) -> String {
        return codingKeys.map({ $0.stringValue }).joined(separator: ".")
    }
    
    /// Returns a human readable error description from a `DecodingError`, useful for returning back to clients to help them debug their malformed JSON objects.
    public var humanReadableDescription: String {
        switch self {
        case .valueNotFound(_, let context):
            return "Key '\(DecodingError.codingKeyAsPrefixString(from: context.codingPath))' has the wrong type or was not found. \(context.debugDescription)"
        case .keyNotFound(let type, let context):
            
            var prefixString = DecodingError.codingKeyAsPrefixString(from: context.codingPath)
            if prefixString.count > 0 {
                prefixString = "\(prefixString)."
            }
            return "The required key '\(prefixString)\(type.stringValue)' not found."
        case .dataCorrupted(let context):
            // Linux does not get to this state but sends an Error "The operation could not be completed" instead. Future proofing this though just in case.
            #if os(Linux)
            // Linux wants a force downcast, MacOS doesn't.
            if let nsError = context.underlyingError as? NSError, let detailedError = nsError.userInfo["NSDebugDescription"] as? String {
                return "The JSON appears to be malformed. \(detailedError)"
            }
            #else
            if let nsError = context.underlyingError as NSError?, let detailedError = nsError.userInfo["NSDebugDescription"] as? String {
                return "The JSON appears to be malformed. \(detailedError)"
            }
            #endif
            return "The JSON appears to be malformed."
        case .typeMismatch(_, let context):
            return "Key '\(DecodingError.codingKeyAsPrefixString(from: context.codingPath))' has the wrong type. \(context.debugDescription)"
        }
    }
}
