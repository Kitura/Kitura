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

import Kitura
import KituraNet
import KituraSys

import Foundation

import XCTest

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif


class TestErrors : XCTestCase, KituraTest {

    static var allTests : [(String, TestErrors -> () throws -> Void)] {
        return [
            ("testInvalidMethod", testInvalidMethod),
            ("testInvalidEndpoint", testInvalidEndpoint),
            ("testInvalidHeader", testInvalidHeader)
        ]
    }

    override func tearDown() {
        doTearDown()
    }

    func expectation(index index: Int) -> XCTestExpectation {
        let expectationDescription = "TestErrors-\(index)"
        #if os(Linux)
        return self.expectationWithDescription(expectationDescription)
        #else
        return self.expectation(withDescription: expectationDescription)
        #endif
    }

    func waitExpectation(timeout t: NSTimeInterval, handler: XCWaitCompletionHandler?) {
        #if os(Linux)
        self.waitForExpectationsWithTimeout(t, handler: handler)
        #else
        self.waitForExpectations(withTimeout: t, handler: handler)
        #endif
    }

    let router = Router()

    func testInvalidMethod() {
        performServerTest(router) { expectation in
            self.performRequest("invalid", path: "/qwer", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HttpStatusCode.BAD_REQUEST, "HTTP Status code was \(response!.statusCode)")
                expectation.fulfill()
            })
        }
    }

    func testInvalidEndpoint() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/notreal", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HttpStatusCode.NOT_FOUND, "HTTP Status code was \(response!.statusCode)")
                expectation.fulfill()
            })
        }
    }

    func testInvalidHeader() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/qwer", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                // should this be ok?
                expectation.fulfill()
            }) {req in
                req.headers = ["garbage" : "dfsfdsf"]
            }
        }
    }

}
