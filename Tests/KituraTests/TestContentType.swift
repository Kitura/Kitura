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

class TestContentType: KituraTest {

    static var allTests: [(String, (TestContentType) -> () throws -> Void)] {
        return [
            ("testInitialize", testInitialize),
            ("testFilename", testFilename),
            ("testIsContentType", testIsContentType)
        ]
    }

    let contentType = ContentType.sharedInstance

    func testInitialize() {

        let pngType = contentType.getContentType(forExtension: "png")

        XCTAssertEqual(pngType, "image/png")
        XCTAssertNotEqual(pngType, "application/javascript")

        let htmlType = contentType.getContentType(forExtension: "html")

        XCTAssertEqual(htmlType, "text/html")
        XCTAssertNotEqual(pngType, "application/javascript")

        let jsType = contentType.getContentType(forExtension: "js")

        XCTAssertEqual(jsType, "application/javascript")

    }

    func testFilename() {

        var result = contentType.getContentType(forFileName: "foo.png")
        XCTAssertEqual(result, "image/png")

        result = contentType.getContentType(forFileName: "a/foo.png")
        XCTAssertEqual(result, "image/png")

        result = contentType.getContentType(forFileName: "a/b/c/foo.png")
        XCTAssertEqual(result, "image/png")

        result = contentType.getContentType(forFileName: "test.html")
        XCTAssertEqual(result, "text/html")

        result = contentType.getContentType(forFileName: "a/b/c/test.html")
        XCTAssertEqual(result, "text/html")

        result = contentType.getContentType(forFileName: "test.with.periods.html")
        XCTAssertEqual(result, "text/html")

        result = contentType.getContentType(forFileName: "test/html")
        XCTAssertEqual(result, "text/html")
    }

    func testIsContentType() {
        var result = contentType.isContentType("application/json", ofType: "json")
        XCTAssertTrue(result)

        result = contentType.isContentType("json", ofType: "json")
        XCTAssertTrue(result)

        result = contentType.isContentType("text/html", ofType: "json")
        XCTAssertFalse(result)

        result = contentType.isContentType("application/x-www-form-urlencoded", ofType: "urlencoded")
        XCTAssertTrue(result)

        result = contentType.isContentType("multipart/form-data", ofType: "multipart")
        XCTAssertTrue(result)

    }
}
