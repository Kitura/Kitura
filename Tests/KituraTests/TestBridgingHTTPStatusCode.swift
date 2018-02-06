/**
 * Copyright IBM Corporation 2016, 2018
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

import XCTest
import Foundation

@testable import Kitura

#if os(Linux)
import Glibc
#else
import Darwin
#endif

// This file does not import KituraNet and is relying on the typealias of
// HTTPStatusCode. This test is a simple response test to check that referring
// to HTTPStatusCode builds and runs without error. Other existing tests
// that import KituraNet should be sufficient to show that the typealias does not
// interfere in that case.
class TestBridgingHTTPStatusCode: KituraTest {

    static var allTests: [(String, (TestBridgingHTTPStatusCode) -> () throws -> Void)] {
        return [
            ("testSimpleResponse", testSimpleResponse)
        ]
    }

    let router = TestBridgingHTTPStatusCode.setupRouter()

    func testSimpleResponse() {
    	performServerTest(router) { expectation in
            self.performRequest("get", path:"/qwer", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                //XCTAssertEqual(response?.method, "GET", "The request wasn't recognized as a get")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }
    }

    static func setupRouter() -> Router {
        let router = Router()
        router.get("/qwer") { _, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            do {
                try response.send("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n").end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
            next()
        }
        return router
    }
}
