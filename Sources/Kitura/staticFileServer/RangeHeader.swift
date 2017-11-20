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

import LoggerAPI
import Foundation

/// Struct that represents a Range Header defined in RFC7233.
struct RangeHeader {
    /// type is the left side of `=`
    let type: String
    /// ranges is the right side of `=`
    let ranges: [Range<UInt64>]
}

extension RangeHeader {

    /// Possible errors thrown by RangeHeader.parse function
    enum Error: Swift.Error {
        /// Happens when none of the ranges in Range header was not satisfiable as per RFC 7233 (Section 4.4)
        case notSatisfiable
        /// Could not be parsed. Bad syntax
        case malformed
    }

    /// Check if header is a byte range header
    static func isBytesRangeHeader(_ rangeHeaderValue: String) -> Bool {
        /// Regular expression for identifying a bytes Range header.
        let bytesRangePattern = "^ *bytes="

        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: bytesRangePattern, options: [])
        } catch {
            Log.error("Failed to create regular expressions used to check byte Range headers")
            exit(1)
        }
        let matches = regex.matches(in: rangeHeaderValue, options: [], range: NSRange(location: 0, length: rangeHeaderValue.count))
        return !matches.isEmpty
    }

    /// Parse a range header string into a RangeHeader structure.
    /// Implementation based on: [jshttp/range-parser](https://github.com/jshttp/range-parser)
    ///
    /// - Parameter size: the size of the resource
    /// - Parameter headerValue: the stringn to parse
    ///
    static func parse(size: UInt64, headerValue: String, shouldCombine: Bool = true) throws -> RangeHeader {

        guard let index = headerValue.range(of: "=")?.lowerBound else {
            // malformed
            throw RangeHeader.Error.malformed
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
            throw RangeHeader.Error.notSatisfiable
        }

        if shouldCombine {
            let combinedRanges = RangeHeader.combinedRanges(ranges: ranges)
            return RangeHeader(type: type, ranges: combinedRanges)
        } else {
            return RangeHeader(type: type, ranges: ranges)
        }
    }
}

extension RangeHeader {

    struct IndexedRange {
        var index: Int
        var range: Range<UInt64>
    }

    /// Return an array of combined ranges (overlapping and adjacent)
    static func combinedRanges(ranges: [Range<UInt64>]) -> [Range<UInt64>] {

        // map [Range]s to [IndexedRange]s and sort them by range.lowerBound
        var index = 0
        var ordered = ranges.map { range in
                let i = IndexedRange(index: index, range: range)
                index += 1
                return i
            }.sorted { (rangeA: IndexedRange, rangeB: IndexedRange) -> Bool in
                return rangeA.range.lowerBound < rangeB.range.lowerBound
            }

        // try to combine them
        var j = 0
        for i in 1..<ordered.count {
            let indexedRange = ordered[i]
            let currentIndexedRange = ordered[j]
            if indexedRange.range.lowerBound > (currentIndexedRange.range.upperBound + 1) {
                // next range
                j += 1
                ordered[j] = indexedRange
            } else if indexedRange.range.upperBound > currentIndexedRange.range.upperBound {
                // extend range
                ordered[j] = IndexedRange(
                    index: min(currentIndexedRange.index, indexedRange.index),
                    range: currentIndexedRange.range.lowerBound..<indexedRange.range.upperBound)
            }
        }
        ordered = Array(ordered.prefix(j + 1)) // trim ordered array

        // map [IndexedRange]s back to [Range]s but sort them in their original order
        let combined = ordered.sorted { (rangeA: IndexedRange, rangeB: IndexedRange) -> Bool in
                return rangeA.index < rangeB.index
            }.map { indexedRange in
                return indexedRange.range
            }

        return combined
    }
}
