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
            let (key, value) = item.keyAndDecodedValue
            if let value = value {
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
            let (key, value) = item.keyAndDecodedValue
            if let value = value {
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
    var keyAndDecodedValue: (key: String, value: String?) {
        guard let index = self.firstIndex(of: "=") else {
            return (key: String(self), value: nil)
        }
        // substring up to index
        let key = String(self[..<index])
        // substring from index
        var value = String(self[self.index(after: index)...])

        repeat {
            guard let startIndex = value.firstIndex(of: "+") else {
                break
            }
            value.replaceSubrange(startIndex...startIndex, with: " ")
        } while true

        //let valueReplacingPlus = value.replacingOccurrences(of: "+", with: " ")
        let decodedValue = value.removingPercentEncoding
        if decodedValue == nil {
            Log.warning("Unable to decode query parameter \(key) (coded value: \(value)")
        }
        return (key: key, value: decodedValue ?? value)
    }

}
