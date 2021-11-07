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

@testable import Kitura
import KituraNet

import Foundation

import XCTest

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

final class TestErrors: KituraTest, KituraTestSuite {

    static var allTests: [(String, (TestErrors) -> () throws -> Void)] {
        return [
            ("testInvalidMethod", testInvalidMethod),
            ("testInvalidEndpoint", testInvalidEndpoint),
            ("testInvalidHeader", testInvalidHeader)
        ]
    }

    let router = Router()

    func testInvalidMethod() {
        performServerTest(router, asyncTasks: { serverContext, asyncTaskCompletion in
            self.performRequest(serverContext, "invalid", path: "/qwer", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.badRequest, "HTTP Status code was \(String(describing: response?.statusCode))")
                asyncTaskCompletion()
            })
        }, { serverContext, asyncTaskCompletion in
            let method = RouterMethod(fromRawValue: "PLOVER")
            XCTAssertEqual(method, .unknown, "Router method should be .unknown, it was \(method)")
            asyncTaskCompletion()
        })
    }

    func testInvalidEndpoint() {
        performServerTest(router) { serverContext, asyncTaskCompletion in
            self.performRequest(serverContext, "get", path: "/notreal", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(String(describing: response?.statusCode))")
                asyncTaskCompletion()
            })
        }
    }

    func testInvalidHeader() {
        performServerTest(router) { serverContext, asyncTaskCompletion in
            self.performRequest(serverContext, "get", path: "/qwer", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                // should this be ok?
                asyncTaskCompletion()
            }) {req in
                req.headers = ["garbage": "dfsfdsf"]
            }
        }
    }
}
