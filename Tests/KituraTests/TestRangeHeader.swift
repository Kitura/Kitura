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

import XCTest

@testable import Kitura

class TestRangeHeaderParser: XCTestCase {

    // Test cases based on from:
    // https://github.com/jshttp/range-parser/blob/master/test/range-parser.js

    func parse(_ size: UInt64, _ headerValue: String, combine: Bool = false) -> RangeHeader? {
        return RangeHeader.parse(size: size, headerValue: headerValue, shouldCombine: combine)
    }

    func testReturnNilOnMalformedHeader() {
        XCTAssertNil(parse(200, "malformed"))
    }

    func testReturnNilOnInvalidRanges() {
        XCTAssertNil(parse(200, "bytes=500-20"))
        XCTAssertNil(parse(200, "bytes=500-999"))
        XCTAssertNil(parse(200, "bytes=500-999,1000-1499"))
    }

    func testReturnNilOnInvalidNonDigitsRanges() {
        XCTAssertNil(parse(200, "bytes=xyz"))
        XCTAssertNil(parse(200, "bytes=xyz-"))
        XCTAssertNil(parse(200, "bytes=-xyz"))
    }

    func testParseString() {
        let range = parse(1000, "bytes=0-499")
        XCTAssertEqual(range?.type, "bytes")
        XCTAssertEqual(range?.ranges.count, 1)
        XCTAssertEqual(range?.ranges[0], 0..<499)
    }

    func testShouldCapEndAtSize() {
        let range = parse(200, "bytes=0-499")
        XCTAssertEqual(range?.type, "bytes")
        XCTAssertEqual(range?.ranges.count, 1)
        XCTAssertEqual(range?.ranges[0], 0..<199)
    }

    func testShouldParseNormalString() {
        let range = parse(1000, "bytes=40-80")
        XCTAssertEqual(range?.type, "bytes")
        XCTAssertEqual(range?.ranges.count, 1)
        XCTAssertEqual(range?.ranges[0], 40..<80)
    }

    func testShouldParseStringWithOnlyEnd() {
        let range = parse(1000, "bytes=-400")
        XCTAssertEqual(range?.type, "bytes")
        XCTAssertEqual(range?.ranges.count, 1)
        XCTAssertEqual(range?.ranges[0], 600..<999)
    }

    func testShouldParseStringWithOnlyStart() {
        let range = parse(1000, "bytes=400-")
        XCTAssertEqual(range?.type, "bytes")
        XCTAssertEqual(range?.ranges.count, 1)
        XCTAssertEqual(range?.ranges[0], 400..<999)
    }

    func testShouldParseWithStartBytesEqualtToZero() {
        let range = parse(1000, "bytes=0-")
        XCTAssertEqual(range?.type, "bytes")
        XCTAssertEqual(range?.ranges.count, 1)
        XCTAssertEqual(range?.ranges[0], 0..<999)
    }

    func testShouldParseStringWithBytesEqualZeroZero() {
        let range = parse(1000, "bytes=0-0")
        XCTAssertEqual(range?.type, "bytes")
        XCTAssertEqual(range?.ranges.count, 1)
        XCTAssertEqual(range?.ranges[0], 0..<0)
    }

    func testShouldParseStringAskingForLastByte() {
        let range = parse(1000, "bytes=-1")
        XCTAssertEqual(range?.type, "bytes")
        XCTAssertEqual(range?.ranges.count, 1)
        XCTAssertEqual(range?.ranges[0], 999..<999)
    }

    func testShouldParseStringWithMultipleRanges() {
        let range = parse(1000, "bytes=40-80,81-90,-1")
        XCTAssertEqual(range?.type, "bytes")
        XCTAssertEqual(range?.ranges.count, 3)
        XCTAssertEqual(range?.ranges[0], 40..<80)
        XCTAssertEqual(range?.ranges[1], 81..<90)
        XCTAssertEqual(range?.ranges[2], 999..<999)
    }

    func testShouldParseStringWithSomeInvalidRanges() {
        let range = parse(200, "bytes=0-499,1000-,500-999")
        XCTAssertEqual(range?.type, "bytes")
        XCTAssertEqual(range?.ranges.count, 1)
        XCTAssertEqual(range?.ranges[0], 0..<199)
    }

    func testShouldParseNonBytesRange() {
        let range = parse(1000, "items=0-5")
        XCTAssertEqual(range?.type, "items")
        XCTAssertEqual(range?.ranges.count, 1)
        XCTAssertEqual(range?.ranges[0], 0..<5)
    }

    func testShouldCombineOverlappingRanges() {
        let range = parse(150, "bytes=0-4,90-99,5-75,100-199,101-102", combine: true)!
        XCTAssertEqual(range.type, "bytes")
        XCTAssertEqual(range.ranges.count, 2)
        XCTAssertEqual(range.ranges[0], 0..<75)
        XCTAssertEqual(range.ranges[1], 90..<149)
    }

    func testShouldCombineOverlappingRangesAndRetainOriginalOrder() {
        let range = parse(150, "bytes=-1,20-100,0-1,101-120", combine: true)!
        XCTAssertEqual(range.type, "bytes")
        XCTAssertEqual(range.ranges.count, 3)
        XCTAssertEqual(range.ranges[0], 149..<149)
        XCTAssertEqual(range.ranges[1], 20..<120)
        XCTAssertEqual(range.ranges[2], 0..<1)
    }
}
