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

extension String {
    /// Parses percent encoded string into query parameters
    var urlDecodedFieldValuePairs: [String : String] {
        var result: [String:String] = [:]

        for item in self.components(separatedBy: "&") {
            guard let range = item.range(of: "=") else {
                result[item] = nil
                continue
            }

            let key = String(item[..<range.lowerBound])
            let value = String(item[range.upperBound...])

            let valueReplacingPlus = value.replacingOccurrences(of: "+", with: " ")
            if let decodedValue = valueReplacingPlus.removingPercentEncoding {
                if let value = result[key] {
                    result[key] = "\(value),\(decodedValue)"
                } else {
                    result[key] = decodedValue
                }
            } else {
                Log.warning("Unable to decode query parameter \(key)")
                result[key] = valueReplacingPlus
            }
        }

        return result
    }
}
