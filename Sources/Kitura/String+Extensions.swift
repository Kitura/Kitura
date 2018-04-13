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
    var urlDecodedFieldValuePairs: [String : String] {
        var result: [String: String] = [:]
        self.urlDecodedFieldMultiValuePairs.forEach { key, values in
            result[key] = values.joined(separator: ",")
        }
        return result
    }

    /// Parses percent encoded string int query parameters with values as an
    /// array rather than a concatcenated string.
    var urlDecodedFieldMultiValuePairs: [String: [String]] {
        var result: [String: [String]] = [:]

        for item in self.components(separatedBy: "&") {
            guard let range = item.range(of: "=") else {
                result[item] = nil
                continue
            }

            let key = String(item[..<range.lowerBound])
            let value = String(item[range.upperBound...])

            let valueReplacingPlus = value.replacingOccurrences(of: "+", with: " ")
            if let decodedValue = valueReplacingPlus.removingPercentEncoding {
                result[key, default: []].append(decodedValue)
            }
            else {
                Log.warning("Unable to decode query parameter \(key) (coded value: \(valueReplacingPlus)")
                result[key, default: []].append(valueReplacingPlus)
            }
        }

        return result
    }

}
