/**
 * Copyright IBM Corporation 2015
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
import XCTest

@testable import Kitura
@testable import KituraNet

class MiscellaneousTests: KituraTest {

    static var allTests: [(String, (MiscellaneousTests) -> () throws -> Void)] {
        return [
            ("testHeaders", testHeaders),
            ("testHeadersHelpers", testHeadersHelpers)
        ]
    }

    func testHeaders() {
        var headers = Headers(headers: HeadersContainer())
        headers.append("plover", value: "xyzzy")
        headers.append("kitura", value: "The greatest")

        var (key, value) = headers[headers.startIndex]
        let firstKeyWasKitura: Bool

        switch key {
        case "kitura":
            XCTAssertNotNil(value, "Value for the header kitura was nil")
            XCTAssertEqual(value, "The greatest", "The value for the kitura header wasn't \"The greatest\". It was \(String(describing: value))")
            firstKeyWasKitura = true
        case "plover":
            XCTAssertNotNil(value, "Value for the header plover was nil")
            XCTAssertEqual(value, "xyzzy", "The value for the plover header wasn't \"xyzzy\". It was \(String(describing: value))")
            firstKeyWasKitura = false
        default:
            firstKeyWasKitura = false
            XCTFail("The header key was neither kitura nor plover, it was \(key)")
        }

        let next = headers.index(after: headers.startIndex)
        XCTAssertLessThan(next, headers.endIndex, "Next should be less than the endIndex")

        (key, value) = headers[next]
        switch key {
        case "kitura":
            XCTAssertFalse(firstKeyWasKitura, "Second key was kitura, it should not have been")
            XCTAssertNotNil(value, "Value for the header kitura was nil")
            XCTAssertEqual(value, "The greatest", "The value for the kitura header wasn't \"The greatest\". It was \(String(describing: value))")
        case "plover":
            XCTAssertTrue(firstKeyWasKitura, "The first key should have been kitura")
            XCTAssertNotNil(value, "Value for the header plover was nil")
            XCTAssertEqual(value, "xyzzy", "The value for the plover header wasn't \"xyzzy\". It was \(String(describing: value))")
        default:
            XCTFail("The header key was neither kitura nor plover, it was \(key)")
        }
    }

    func testHeadersHelpers() {
        var headers = Headers(headers: HeadersContainer())

        headers.setLocation("back")   // Without referrer set
        var location = headers["Location"]
        XCTAssertNotNil(location, "Location header wasn't set")
        XCTAssertEqual(location, "/", "Location header should have been /, it was \(String(describing: location))")

        let referrer = "http://plover.com/xyzzy"
        headers["referrer"] = referrer
        headers.setLocation("back")   // With referrer set
        location = headers["Location"]
        XCTAssertEqual(location, referrer, "Location header should have been \(referrer), it was \(String(describing: location))")

        headers.setType("html", charset: "UTF-8")
        let contentType = headers["Content-Type"]
        XCTAssertNotNil(contentType, "Content-Type header wasn't set")
        let expectedContentType = "text/html; charset=UTF-8"
        XCTAssertEqual(contentType, expectedContentType, "Content-Type header should have been \(expectedContentType), it was \(String(describing: contentType))")

        var contentDispostion = headers["Content-Disposition"]
        XCTAssertNil(contentDispostion, "Content-Disposition shouldn't have been set yet")

        headers.addAttachment(for: "")
        contentDispostion = headers["Content-Disposition"]
        XCTAssertNil(contentDispostion, "Content-Disposition shouldn't have been set. It's value is \(String(describing: contentDispostion))")

        headers.addAttachment()
        contentDispostion = headers["Content-Disposition"]
        XCTAssertNotNil(contentDispostion, "Content-Disposition should have been set.")
        XCTAssertEqual(contentDispostion, "attachment", "Content-Disposition should have the value attachment. It has the value \(String(describing: contentDispostion))")
    }
}
