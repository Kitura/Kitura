/**
 * Copyright IBM Corporation 2018
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

class TestMediaType: KituraTest {
    
    static var allTests: [(String, (TestMediaType) -> () throws -> Void)] {
        return [
            ("testAllTextMediaTypeBuilder", testAllTextMediaTypeBuilder),
            ("testAllTextSlashMediaTypeBuilder", testAllTextSlashMediaTypeBuilder),
            ("testHTMLMediaTypeBuilder", testPartsHTMLMediaTypeBuilder),
            ("testMediaCaseInsensitive", testMediaCaseInsensitive),
            ("testPartsAllTextMediaTypeBuilder", testPartsAllTextMediaTypeBuilder),
            ("testPartsHTMLMediaTypeBuilder", testPartsHTMLMediaTypeBuilder),
            ("testPartsMediaCaseInsensitive", testPartsMediaCaseInsensitive),
            ("testNoHeaderMediaType", testNoHeaderMediaType),
            ("testSingleHeaderMediaType", testSingleHeaderMediaType),
            ("testTwoHeaderMediaType", testTwoHeaderMediaType),
            ("testWrongHeaderMediaType", testWrongHeaderMediaType),
        ]
    }
    
    func testAllTextMediaTypeBuilder() {
        let textMediaType = MediaType("text")
        XCTAssertEqual(textMediaType?.description, "text/*")
        XCTAssertEqual(textMediaType?.topLevelType, .text)
        XCTAssertEqual(textMediaType?.subtype, "*")
    }
    
    func testAllTextSlashMediaTypeBuilder() {
        let textMediaType = MediaType("text/")
        XCTAssertEqual(textMediaType?.description, "text/*")
        XCTAssertEqual(textMediaType?.topLevelType, .text)
        XCTAssertEqual(textMediaType?.subtype, "*")
    }
    
    func testHTMLMediaTypeBuilder() {
        let textMediaType = MediaType("text/html")
        XCTAssertEqual(textMediaType?.description, "text/html")
        XCTAssertEqual(textMediaType?.topLevelType, .text)
        XCTAssertEqual(textMediaType?.subtype, "html")
    }
    
    func testMediaCaseInsensitive() {
        let textMediaType = MediaType("TexT/HTml")
        XCTAssertEqual(textMediaType?.description, "text/html")
        XCTAssertEqual(textMediaType?.topLevelType, .text)
        XCTAssertEqual(textMediaType?.subtype, "html")
    }
    
    func testIncorrectTopLevelType() {
        XCTAssertNil(MediaType("Wrong/text"))
    }
    
    func testPartsAllTextMediaTypeBuilder() {
        let textMediaType = MediaType(type: .text)
        XCTAssertEqual(textMediaType.description, "text/*")
        XCTAssertEqual(textMediaType.topLevelType, .text)
        XCTAssertEqual(textMediaType.subtype, "*")
    }
    
    func testPartsHTMLMediaTypeBuilder() {
        let textMediaType = MediaType(type: .text, subtype: "html")
        XCTAssertEqual(textMediaType.description, "text/html")
        XCTAssertEqual(textMediaType.topLevelType, .text)
        XCTAssertEqual(textMediaType.subtype, "html")
    }
    
    func testPartsMediaCaseInsensitive() {
        let textMediaType = MediaType(type: .text , subtype: "hTmL")
        XCTAssertEqual(textMediaType.description, "text/html")
        XCTAssertEqual(textMediaType.topLevelType, .text)
        XCTAssertEqual(textMediaType.subtype, "html")
    }
    
    func testNoHeaderMediaType() {
        let headers = HeadersContainer()
        XCTAssertNil(MediaType(headers: headers))
    }
    
    func testSingleHeaderMediaType() {
        let headers = HeadersContainer()
        headers.append("Content-Type", value: ["text/html"])
        let textMediaType = MediaType(headers: headers)
        XCTAssertEqual(textMediaType?.description, "text/html")
        XCTAssertEqual(textMediaType?.topLevelType, .text)
        XCTAssertEqual(textMediaType?.subtype, "html")
    }
    
    func testTwoHeaderMediaType() {
        let headers = HeadersContainer()
        headers.append("Content-Type", value: ["text/html", "application/json"])
        let textMediaType = MediaType(headers: headers)
        XCTAssertEqual(textMediaType?.description, "text/html")
        XCTAssertEqual(textMediaType?.topLevelType, .text)
        XCTAssertEqual(textMediaType?.subtype, "html")
    }
    
    func testWrongHeaderMediaType() {
        let headers = HeadersContainer()
        headers.append("Content-Type", value: "incorrect/html")
        XCTAssertNil(MediaType(headers: headers))
    }
}
