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

class CustomCodingTests: XCTestCase {

    static var allTests: [(String, (CustomCodingTests) -> () throws -> Void)] {
        return [
            ("testQueryDecoder", testQueryDecoder),
            ("testQueryEncoder", testQueryEncoder),
            ("testCycle", testCycle)
        ]
    }

    struct MyQuery: Codable, Equatable {
        public let intField: Int
        public let optionalIntField: Int?
        public let stringField: String
        public let intArray: [Int]
        public let dateField: Date
        public let optionalDateField: Date?
        public let nested: Nested

        public static func ==(lhs: MyQuery, rhs: MyQuery) -> Bool {
            return  lhs.intField == rhs.intField &&
                    lhs.optionalIntField == rhs.optionalIntField &&
                    lhs.stringField == rhs.stringField &&
                    lhs.intArray == rhs.intArray &&
                    lhs.dateField == rhs.dateField &&
                    lhs.optionalDateField == rhs.optionalDateField &&
                    lhs.nested == rhs.nested
        }
    }

    struct Nested: Codable, Equatable {
        public let nestedIntField: Int
        public let nestedStringField: String

        public static func ==(lhs: Nested, rhs: Nested) -> Bool {
            return lhs.nestedIntField == rhs.nestedIntField && lhs.nestedStringField == rhs.nestedStringField
        }
    }

    let expectedDict = ["optionalIntField": "282", "intField": "23", "stringField": "a string", "intArray": "1,2,3", "dateField": "2017-10-31T16:15:56+0000", "optionalDateField": "2017-10-31T16:15:56+0000", "nested": "{\"nestedIntField\":333,\"nestedStringField\":\"nested string\"}" ]

    let expectedQueryString = "?intArray=1%2C2%2C3&stringField=a%20string&intField=23&optionalIntField=282&dateField=2017-12-07T21:42:06%2B0000&nested=%7B\"nestedStringField\":\"nested%20string\"%2C\"nestedIntField\":333%7D"

    let expectedDateStr = "2017-10-31T16:15:56+0000"
    let expectedDate = Coder().dateFormatter.date(from: "2017-10-31T16:15:56+0000")!

    let expectedMyQuery = MyQuery(intField: 23,
                                  optionalIntField: 282,
                                  stringField: "a string",
                                  intArray: [1, 2, 3],
                                  dateField: Coder().dateFormatter.date(from: "2017-10-31T16:15:56+0000")!,
                                  optionalDateField: Coder().dateFormatter.date(from: "2017-10-31T16:15:56+0000")!,
                                  nested: Nested(nestedIntField: 333, nestedStringField: "nested string"))

    func testQueryDecoder() {
        guard let query = try? QueryDecoder(dictionary: expectedDict).decode(MyQuery.self) else {
            XCTFail("Failed to decode query to MyQuery Object")
            return
        }

        XCTAssertEqual(query, expectedMyQuery)

    }

    func testQueryEncoder() {

        let query = MyQuery(intField: 23, optionalIntField: 282, stringField: "a string", intArray: [1, 2, 3], dateField: expectedDate, optionalDateField: expectedDate, nested: Nested(nestedIntField: 333, nestedStringField: "nested string"))

        guard let myQueryDict: [String: String] = try? QueryEncoder().encode(query) else {
            XCTFail("Failed to encode query to [String: String]")
            return
        }
        guard let myQueryStr: String = try? QueryEncoder().encode(query) else {
            XCTFail("Failed to encode query to String")
            return
        }

        XCTAssertEqual(myQueryDict["intField"], "23")
        XCTAssertEqual(myQueryDict["optionalIntField"], "282")
        XCTAssertEqual(myQueryDict["stringField"], "a string")
        XCTAssertEqual(myQueryDict["intArray"], "1,2,3")
        XCTAssertEqual(myQueryDict["dateField"], expectedDateStr)
        XCTAssertEqual(myQueryDict["optionalDateField"], expectedDateStr)

        /// Ordering of encoded JSON is differnt on Darwin and Linux
        XCTAssert(myQueryDict["nested"] == "{\"nestedStringField\":\"nested string\",\"nestedIntField\":333}" ||
                  myQueryDict["nested"] == "{\"nestedIntField\":333,\"nestedStringField\":\"nested string\"}"
        )

        func createDict(_ str: String) -> [String: String] {
            return myQueryStr.components(separatedBy: "&").reduce([String: String]()) { acc, val in
                var acc = acc
                let split = val.components(separatedBy: "=")
                acc[split[0]] = split[1]
                return acc
            }
        }
        let myQueryStrSplit1: [String: String] = createDict(myQueryStr)
        let myQueryStrSplit2: [String: String] = createDict(expectedQueryString)

        XCTAssertEqual(myQueryStrSplit1["intField"], myQueryStrSplit2["intField"])
        XCTAssertEqual(myQueryStrSplit1["optionalIntField"], myQueryStrSplit2["optionalIntField"])
        XCTAssertEqual(myQueryStrSplit1["stringField"], myQueryStrSplit2["stringField"])
        XCTAssertEqual(myQueryStrSplit1["intArray"], myQueryStrSplit2["intArray"])
        XCTAssertEqual(myQueryStrSplit1["dateField"], myQueryStrSplit2["dateField"])
        XCTAssertEqual(myQueryStrSplit1["optionalDateField"], myQueryStrSplit2["optionalDateField"])
        XCTAssertEqual(myQueryStrSplit1["nested"], myQueryStrSplit2["nested"])

    }

    func testCycle() {

        guard let myQueryDict: [String : String] = try? QueryEncoder().encode(expectedMyQuery) else {
            XCTFail("Failed to encode query to [String: String]")
            return
        }

        guard let myQuery2 = try? QueryDecoder(dictionary: myQueryDict).decode(MyQuery.self) else {
            XCTFail("Failed to decode query to MyQuery object")
            return
        }

        XCTAssertEqual(myQuery2, expectedMyQuery)
    }
}
