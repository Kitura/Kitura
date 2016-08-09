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

class TestRouteRegex : XCTestCase {
    
    static var allTests : [(String, (TestRouteRegex) -> () throws -> Void)] {
        return [
                   ("testBuildRegexFromPattern", testBuildRegexFromPattern)
        ]
    }
    
    func testBuildRegexFromPattern() {
        #if os(Linux)
            var regex:RegularExpression?
        #else
            var regex:NSRegularExpression?
        #endif
        var strings:[String]?

        //Partial match false adds '$' end of string special character
        (regex,strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern,"^/test(?:/(?=$))?$")
        XCTAssertTrue(strings!.isEmpty)

        //Partial match true does not include '$' end of string special character
        (regex,strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test", allowPartialMatch: true)
        XCTAssertEqual(regex!.pattern,"^/test(?:/(?=$))?")
        XCTAssertTrue(strings!.isEmpty)

        //Invalid regular expression
    #if os(OSX)
        (regex,strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "\\", allowPartialMatch: false)
        XCTAssertNil(regex)
        XCTAssertTrue(strings!.isEmpty)
    #endif
    }
}
