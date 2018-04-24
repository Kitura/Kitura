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
        for item in self.components(separatedBy: "&") {
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

        for item in self.components(separatedBy: "&") {
            let (key, value) = item.keyAndDecodedValue
            if let value = value {
                result[key, default: []].append(value)
            }
        }

        return result
    }

    /// Splits a URL-encoded key and value pair (e.g. "foo=bar") into a tuple
    /// with corresponding "key" and "value" values, with the value being URL
    /// unencoded.
    var keyAndDecodedValue: (key: String, value: String?) {
        guard let range = self.range(of: "=") else {
            return (key: self, value: nil)
        }
        let key = String(self[..<range.lowerBound])
        let value = String(self[range.upperBound...])

        let valueReplacingPlus = value.replacingOccurrences(of: "+", with: " ")
        let decodedValue = valueReplacingPlus.removingPercentEncoding
        if decodedValue == nil {
            Log.warning("Unable to decode query parameter \(key) (coded value: \(valueReplacingPlus)")
        }
        return (key: key, value: decodedValue ?? valueReplacingPlus)
    }

}
