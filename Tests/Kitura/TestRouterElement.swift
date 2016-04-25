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
@testable import KituraNet

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

class TestRouterElement : XCTestCase {
    
    static var allTests : [(String, TestRouterElement -> () throws -> Void)] {
        return [
                   ("testBuildRegexFromPattern", testBuildRegexFromPattern)
        ]
    }
    
    func testBuildRegexFromPattern() {
        let element = RouterElement(method: RouterMethod.All, pattern: nil, handler: [])
        var regex:NSRegularExpression?
        var strings:[String]?

        //Partial match false adds '$' end of string special character
        (regex,strings) = element.buildRegexFromPattern("test", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern,"^/test(?:/(?=$))?$")

        //Partial match true does not include '$' end of string special character
        (regex,strings) = element.buildRegexFromPattern("test", allowPartialMatch: true)
        XCTAssertEqual(regex!.pattern,"^/test(?:/(?=$))?")

        //Invalid regular expression
        (regex,strings) = element.buildRegexFromPattern("\\", allowPartialMatch: false)
        XCTAssertNil(regex)
    
    }
}
