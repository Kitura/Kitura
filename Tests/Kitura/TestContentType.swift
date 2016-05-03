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

class TestContentType : XCTestCase {

    static var allTests : [(String, TestContentType -> () throws -> Void)] {
        return [
            ("test_initialize", test_initialize),
        ]
    }

    func test_initialize() {

        let pngType = ContentType.sharedInstance.contentTypeForExtension("png")

        XCTAssertEqual(pngType, "image/png")
        XCTAssertNotEqual(pngType, "application/javascript")

        let htmlType = ContentType.sharedInstance.contentTypeForExtension("html")

        XCTAssertEqual(htmlType, "text/html")
        XCTAssertNotEqual(pngType, "application/javascript")

        let jsType = ContentType.sharedInstance.contentTypeForExtension("js")

        XCTAssertEqual(jsType, "application/javascript")


        //XCTAssertEqual(contentType, contentType)
    }

}
