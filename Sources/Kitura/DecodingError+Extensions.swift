//
//  DecodingError+Extensions.swift
//  Kitura
//
//  Created by patrick on 21.04.18.
//

import Foundation

/// DecodingError Extension to print human readable error messages for clients
extension DecodingError {
    
    /// Concats the CodingKeys to provide a key path string
    static func codingKeyAsPrefixString(from codingKeys: [CodingKey]) -> String {
        let codingKeys = codingKeys.map { (key) -> String in
            return key.stringValue
        }
        return codingKeys.joined(separator: ".")
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
            if let nsError = context.underlyingError as! NSError?, let detailedError = nsError.userInfo["NSDebugDescription"] as? String {
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
