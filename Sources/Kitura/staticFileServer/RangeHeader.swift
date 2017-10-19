/**
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
 **/

import Foundation

/// Struct that represents a Range Header defined in RFC7233.
struct RangeHeader {
    /// type is the left side of `=`
    let type: String
    /// ranges is the right side of `=`
    let ranges: [Range<UInt64>]
}

extension RangeHeader {

    /// Parse a range header string into a RangeHeader structure.
    /// Implementation based on: [jshttp/range-parser](https://github.com/jshttp/range-parser)
    ///
    /// - Parameter size: the size of the resource
    /// - Parameter headerValue: the stringn to parse
    ///
    static func parse(size: UInt64, headerValue: String) -> RangeHeader? {

        guard let index = headerValue.range(of: "=")?.lowerBound else {
            // malformed
            return nil
        }

        // split the range string
        let startOfRangeString = headerValue.index(index, offsetBy: 1)
        #if swift(>=3.2)
            let type = String(headerValue[headerValue.startIndex..<index])
            let rangeStrings = String(headerValue[startOfRangeString..<headerValue.endIndex]).components(separatedBy:",")
        #else
            let type = headerValue.substring(with: headerValue.startIndex..<index)
            let rangeStrings = headerValue.substring(with: startOfRangeString..<headerValue.endIndex).components(separatedBy:",")
        #endif

        // parse all ranges
        var ranges: [Range<UInt64>] = []
        rangeStrings.forEach { rangeString in
            var range = rangeString.components(separatedBy: "-")
            guard range.count > 1 else {
                // one range is malformed
                return
            }
            let startString = range[0]
            let endString = range[1]

            let start: UInt64?
            var end: UInt64?
            if !startString.isEmpty && !endString.isEmpty {
                // nnn-nnn : Read both values
                start = UInt64(startString)
                end = UInt64(endString)
            } else if startString.isEmpty {
                // -nnn : Read end. Start will be calculated
                end = UInt64(endString)
                if end == nil {
                    start = nil
                } else {
                    start = size - end!
                    end = size - 1
                }
            } else {
                // nnn- : Read start. End will be calculated
                start = UInt64(startString)
                end = size - 1
            }

            // limit last-byte-pos to current length
            if end != nil && end! > (size - 1) {
                end = size - 1
            }

            // invalid or unsatisifiable
            guard let rangeStart = start, let rangeEnd = end, rangeStart <= rangeEnd, 0 <= rangeStart else {
                return
            }
            ranges.append(rangeStart..<rangeEnd)
        }

        guard !ranges.isEmpty else {
            // unsatisifiable
            return nil
        }

        return RangeHeader(type: type, ranges: ranges)
    }
}
