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

    /// Performs a comparison of a provided String to this String lowercased, as
    /// an alternative to caseInsensitiveCompare() avoiding NSString conversion.
    /// It is expected that the provided String will already be lowercased,
    /// for example, a hard-coded constant.
    func equalsLowercased(_ aString: String) -> Bool {
        assert(aString == aString.lowercased(), "equalsLowercased() should be passed a lowercased string, not '\(aString)'")
        return self.lowercased() == aString
        // Note: The following is faster on Darwin, but we are choosing to keep
        // our code consistent across platforms.
        // return self.caseInsensitiveCompare(aString) == .orderedSame
    }
}

extension Substring {
    /// Splits a URL-encoded key and value pair (e.g. "foo=bar") into a tuple
    /// with corresponding "key" and "value" values, with the value being URL
    /// unencoded.
    var keyAndDecodedValue: (key: Substring, value: Substring?) {
        #if swift(>=4.2)
        guard let index = self.firstIndex(of: "=") else {
            return (key: self, value: nil)
        }
        #else
        guard let index = self.index(of: "=") else {
            return (key: self, value: nil)
        }
        #endif
        // substring up to index
        let key = self[..<index]
        // substring from index
        var value = self[self.index(after: index)...]

        // Faster way to replace '+' with ' ' that does not involve conversion to NSString
        value.replaceCharacters("+", with: " ")

        // Note: Foundation processing function
        guard let decodedValue = value.removingPercentEncoding else {
            Log.warning("Unable to decode query parameter \(key) (coded value: \(value)")
            return (key: key, value: value)
        }
        return (key: key, value: Substring(decodedValue))
    }

    /// Finds and replaces all occurrences of a character with the provided substring
    /// (eg. another character).
    @inline(__always)
    private mutating func replaceCharacters(_ src: Character, with dst: Substring) {
        repeat {
            #if swift(>=4.2)
            guard let startIndex = self.firstIndex(of: src) else {
                break
            }
            #else
            guard let startIndex = self.index(of: src) else {
                break
            }
            #endif
            self.replaceSubrange(startIndex...startIndex, with: dst)
        } while true
    }

    /// Trims space and tab characters from the start and end of a string. This is
    /// equivalent to String.trimmingCharacters(in: .whitespaces) for ASCII strings.
    /// This function should *not* be used for strings that may be padded by exotic
    /// Unicode whitespaces.
    func trimASCIIWhitespace() -> Substring {
        // Trim whitespace (Space or TAB) from the front of a string
        let trimmedPrefix = self.drop(while: { $0 == " " || $0 == "\u{0009}" })
        // If the string is now empty, return early
        guard !trimmedPrefix.isEmpty else {
            return trimmedPrefix
        }
        // This is in lieu of a dropLast(while:) function
        let startIndex = trimmedPrefix.startIndex
        var endIndex = trimmedPrefix.endIndex
        repeat {
            let prevIndex = trimmedPrefix.index(before: endIndex)
            if trimmedPrefix[prevIndex] != " " && trimmedPrefix[prevIndex] != "\u{0009}" {
                break
            }
            endIndex = prevIndex
        } while endIndex > startIndex
        return trimmedPrefix.prefix(upTo: endIndex)
    }

}
