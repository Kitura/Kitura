/*
 * Copyright IBM Corporation 2017
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
import LoggerAPI

/// String Utils
extension String {

    /// Parses percent encoded string into query parameters with comma-separated
    /// values.
    var urlDecodedFieldValuePairs: [String: String] {
        var result: [String: String] = [:]
        for item in self.split(separator: "&") {
            let (keySub, valueSub) = item.keyAndDecodedValue
            if let valueSub = valueSub {
                let value = String(valueSub)
                let key = String(keySub)
                // If value already exists for this key, append it
                if let existingValue = result[key] {
                    result[key] = "\(existingValue),\(value)"
                }
                else {
                    result[key] = value
                }
            }
        }
        return result
    }

    /// Parses percent encoded string int query parameters with values as an
    /// array rather than a concatcenated string.
    var urlDecodedFieldMultiValuePairs: [String: [String]] {
        var result: [String: [String]] = [:]

        for item in self.split(separator: "&") {
            let (keySub, valueSub) = item.keyAndDecodedValue
            if let valueSub = valueSub {
                let value = String(valueSub)
                let key = String(keySub)
                result[key, default: []].append(value)
            }
        }

        return result
    }
}

extension Substring {
    /// Splits a URL-encoded key and value pair (e.g. "foo=bar") into a tuple
    /// with corresponding "key" and "value" values, with the value being URL
    /// unencoded.
    var keyAndDecodedValue: (key: Substring, value: Substring?) {
        guard let index = self.firstIndex(of: "=") else {
            return (key: self, value: nil)
        }
        // substring up to index
        let key = self[..<index]
        // substring from index
        var value = self[self.index(after: index)...]

        //let valueReplacingPlus = value.replacingOccurrences(of: "+", with: " ")
        // Faster way to replace '+' with ' ' that does not involve conversion to NSString
        value.replaceCharacters("+", with: " ")

// TEMPORARY - evaluate benefit of removing this NSString method
        let decodedValue = value.removingPercentEncoding
        //let decodedValue: Substring? = nil
        if decodedValue == nil {
            Log.warning("Unable to decode query parameter \(key) (coded value: \(value)")
        }
        return (key: key, value: decodedValue != nil ? Substring(decodedValue!) : value)
    }

    /// Finds and replaces all occurrences of a character with the provided substring
    /// (eg. another character).
    @inline(__always)
    private mutating func replaceCharacters(_ src: Character, with dst: Substring) {
        repeat {
            guard let startIndex = self.firstIndex(of: src) else {
                break
            }
            self.replaceSubrange(startIndex...startIndex, with: dst)
        } while true
    }
}
