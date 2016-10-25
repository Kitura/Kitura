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

@testable import Kitura

class TestRouteRegex: XCTestCase {
    
    static var allTests: [(String, (TestRouteRegex) -> () throws -> Void)] {
        return [
                   ("testBuildRegexFromPattern", testBuildRegexFromPattern)
        ]
    }
    
    func testBuildRegexFromPattern() {
        #if os(Linux)
            var regex: RegularExpression?
        #else
            var regex: NSRegularExpression?
        #endif
        var strings: [String]?
        var path: String
        var range: NSRange

        // Partial match false adds '$' end of string special character
        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test", allowPartialMatch: false)
        path = "/test"
        range = regex!.rangeOfFirstMatch(in: path, options: [], range: NSMakeRange(0, path.characters.count))
        XCTAssertEqual(regex!.pattern, "^/test/?$")
        XCTAssertTrue(strings!.isEmpty)
        XCTAssertEqual(range.location, 0)
        XCTAssertEqual(range.length, 5)


        // Partial match true does not include '$' end of string special character
        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test", allowPartialMatch: true)
        path = "/test/hello/world"
        range = regex!.rangeOfFirstMatch(in: path, options: [], range: NSMakeRange(0, path.characters.count))
        XCTAssertEqual(regex!.pattern, "^/test/?(?=/|$)")
        XCTAssertTrue(strings!.isEmpty)
        XCTAssertEqual(range.location, 0)
        XCTAssertEqual(range.length, 5)

        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/:id", allowPartialMatch: true)
        path = "/test/123/hello/world"
        range = regex!.rangeOfFirstMatch(in: path, options: [], range: NSMakeRange(0, path.characters.count))
        XCTAssertEqual(regex!.pattern, "^/test/(?:([^/]+?))/?(?=/|$)")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "id")
        XCTAssertEqual(range.location, 0)
        XCTAssertEqual(range.length, 9)

        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/:id+", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern, "^/test/([^/]+?(?:/[^/]+?)*)/?$")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "id")
        
        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/:id*", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern, "^/test(?:/([^/]+?(?:/[^/]+?)*))?/?$")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "id")
        
        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/:id(\\d*)", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern, "^/test/(?:(\\d*))/?$")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "id")
        
        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/:id(Kitura\\d*)", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern, "^/test/(?:(Kitura\\d*))/?$")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "id")

        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/(Kitura\\d*)", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern, "^/test/(?:(Kitura\\d*))/?$")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "0")
    }
}
