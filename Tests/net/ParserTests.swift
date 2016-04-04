/**
 * Copyright IBM Corporation 2016
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

@testable import KituraNet

class ParserTests: XCTestCase {
    static var allTests : [(String, ParserTests -> () throws -> Void)] {
        return [
            ("testParseSimpleUrl", testParseSimpleUrl),
            ("testParseComplexUrl", testParseComplexUrl)
        ]
    }
    
    func testParseSimpleUrl() {
#if os(Linux)
    let url = "https://example.org/absolute/URI/with/absolute/path/to/resource.txt".bridge().dataUsingEncoding(NSUTF8StringEncoding)!
#else
    let url = "https://example.org/absolute/URI/with/absolute/path/to/resource.txt".data(usingEncoding: NSUTF8StringEncoding)!
#endif 
        let urlParser = UrlParser(url: url, isConnect: false)
        XCTAssertEqual(urlParser.schema!, "https", "Incorrect schema")
        XCTAssertEqual(urlParser.host!, "example.org", "Incorrect host")
        XCTAssertEqual(urlParser.path!, "/absolute/URI/with/absolute/path/to/resource.txt", "Incorrect path")
    }
    
    func testParseComplexUrl() {
#if os(Linux)
    let url = "abc://username:password@example.com:123/path/data?key=value&key1=value1#fragid1".bridge().dataUsingEncoding(NSUTF8StringEncoding)!
#else
    let url = "abc://username:password@example.com:123/path/data?key=value&key1=value1#fragid1".data(usingEncoding: NSUTF8StringEncoding)!
#endif 
        let urlParser = UrlParser(url: url, isConnect: false)
        XCTAssertEqual(urlParser.schema!, "abc", "Incorrect schema")
        XCTAssertEqual(urlParser.host!, "example.com", "Incorrect host")
        XCTAssertEqual(urlParser.path!, "/path/data", "Incorrect path")
        XCTAssertEqual(urlParser.port!, 123, "Incorrect port")
        XCTAssertEqual(urlParser.fragment!, "fragid1", "Incorrect fragment")
        XCTAssertEqual(urlParser.userinfo!, "username:password", "Incorrect userinfo")
        XCTAssertEqual(urlParser.queryParams["key"], "value", "Incorrect query")
        XCTAssertEqual(urlParser.queryParams["key1"], "value1", "Incorrect query")
    }
}
