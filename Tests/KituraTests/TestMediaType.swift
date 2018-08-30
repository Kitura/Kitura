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
            ("testValidMediaType", testValidMediaType),
            ("testInvalidMediaType", testInvalidMediaType),
        ]
    }
    
    func testAllTextMediaTypeBuilder() {
        let textMediaType = MediaType("text")
        XCTAssertEqual(textMediaType?.description, "text/*")
        XCTAssertEqual(textMediaType?.topLevelType, .text)
        XCTAssertEqual(textMediaType?.subType, "*")
    }
    
    func testAllTextSlashMediaTypeBuilder() {
        let textMediaType = MediaType("text/")
        XCTAssertEqual(textMediaType?.description, "text/*")
        XCTAssertEqual(textMediaType?.topLevelType, .text)
        XCTAssertEqual(textMediaType?.subType, "*")
    }
    
    func testHTMLMediaTypeBuilder() {
        let textMediaType = MediaType("text/html")
        XCTAssertEqual(textMediaType?.description, "text/html")
        XCTAssertEqual(textMediaType?.topLevelType, .text)
        XCTAssertEqual(textMediaType?.subType, "html")
    }
    
    func testMediaCaseInsensitive() {
        let textMediaType = MediaType("TexT/HTml")
        XCTAssertEqual(textMediaType?.description, "text/html")
        XCTAssertEqual(textMediaType?.topLevelType, .text)
        XCTAssertEqual(textMediaType?.subType, "html")
    }
    
    func testIncorrectTopLevelType() {
        XCTAssertNil(MediaType("Wrong/text"))
    }
    
    func testPartsAllTextMediaTypeBuilder() {
        let textMediaType = MediaType(type: .text)
        XCTAssertEqual(textMediaType.description, "text/*")
        XCTAssertEqual(textMediaType.topLevelType, .text)
        XCTAssertEqual(textMediaType.subType, "*")
    }
    
    func testPartsHTMLMediaTypeBuilder() {
        let textMediaType = MediaType(type: .text, subType: "html")
        XCTAssertEqual(textMediaType.description, "text/html")
        XCTAssertEqual(textMediaType.topLevelType, .text)
        XCTAssertEqual(textMediaType.subType, "html")
    }
    
    func testPartsMediaCaseInsensitive() {
        let textMediaType = MediaType(type: .text , subType: "hTmL")
        XCTAssertEqual(textMediaType.description, "text/html")
        XCTAssertEqual(textMediaType.topLevelType, .text)
        XCTAssertEqual(textMediaType.subType, "html")
    }
    
    func testValidMediaType() {
        let textMediaType = MediaType(contentTypeHeader: "tExT/hTmL; charset=utf-8")
        XCTAssertEqual(textMediaType?.description, "text/html")
        XCTAssertEqual(textMediaType?.topLevelType, .text)
        XCTAssertEqual(textMediaType?.subType, "html")
    }

    func testInvalidMediaType() {
        XCTAssertNil(MediaType(contentTypeHeader: "incorrect/html; charset=banana"))
    }
}
