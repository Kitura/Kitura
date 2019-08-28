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

import XCTest
import Foundation

@testable import Kitura
@testable import KituraNet

#if os(Linux)
import Glibc
#else
import Darwin
#endif

final class TestServerOptions: KituraTest, KituraTestSuite {

    static var allTests: [(String, (TestServerOptions) -> () throws -> Void)] {
        return [
            ("testSmallPostSucceeds", testSmallPostSucceeds),
            ("testLargePostFails", testLargePostFails),
        ]
    }

    let router = TestServerOptions.setupRouter()

    override func setUp() {
        super.setUp()
        // Impose limit on request size. Must allow for headers and payload
        KituraTest.options = ServerOptions(requestSizeLimit: 200, connectionLimit: 1)
    }

    func testSmallPostSucceeds() {
        performServerTest(router, timeout: 30) { expectation in
            // Data that (together with headers) is within request limit
            let count = 10
            let postData = Data(repeating: UInt8.max, count: count)

            self.performRequest("post", path: "/smallPost", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                expectation.fulfill()
            }, requestModifier: { request in
                request.write(from: postData)
            })
        }
    }

    func testLargePostFails() {
        performServerTest(router, timeout: 30) { expectation in
            // Data that exceeds the request size limit
            let count = 10000
            let postData = Data(repeating: UInt8.max, count: count)

            self.performRequest("post", path: "/largePostFail", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.requestTooLong, "HTTP Status code was \(String(describing: response?.statusCode))")
                expectation.fulfill()
            }, requestModifier: { request in
                request.write(from: postData)
            })
        }
    }

    static func setupRouter() -> Router {
        let router = Router()

        router.post("/smallPost") { request, response, _ in
            try response.status(.OK).end()
        }

        router.post("/largePostFail") { request, response, _ in
            XCTFail("Large post request succeeded, should have been rejected")
        }

        return router
    }

}
