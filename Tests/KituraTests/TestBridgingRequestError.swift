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

import XCTest
import Foundation

@testable import Kitura

#if os(Linux)
import Glibc
#else
import Darwin
#endif

// This file does not import KituraContracts and is relying on the typealias of
// RequestError. This tests that a Codable handler can be declared, and built and
// run without error in the absence of this import. Other existing tests that
// import KituraContracts should be sufficient to show that the typealias does not
// interfere in that case.
class TestBridgingRequestError: KituraTest {

    static var allTests: [(String, (TestBridgingRequestError) -> () throws -> Void)] {
        return [
            ("testRequestError", testRequestError)
        ]
    }

    /// An error message that will be returned as a RequestError body. Equatable
    /// in order to assert that the correct body was received in the response.
    struct AccessError: Codable, Equatable {
        let errorReason: String

        static func ==(lhs: TestBridgingRequestError.AccessError, rhs: TestBridgingRequestError.AccessError) -> Bool {
            return lhs.errorReason == rhs.errorReason
        }
    }

    /// The error instance that will be used when responding, and used to validate
    /// that the deserialized response contains the same error.
    static let expectedError = AccessError(errorReason: "impossible")

    /// Used only in the signature of our route, never created as we return an error
    /// instead.
    struct Dummy: Codable {
        let dummy: String
    }

    let router = TestBridgingRequestError.setupRouter()

    /// Tests that a RequestError can be received, of the correct class, and that
    /// a custom error body containing the expected content can be decoded.
    func testRequestError() {
        buildServerTest(router, timeout: 30)
            .request("get", path: "/mission")
            .hasStatus(.badRequest)
            .hasContentType(withPrefix: "application/json")
            .hasData(TestBridgingRequestError.expectedError)
            .run()
    }

    static func setupRouter() -> Router {
        let router = Router()
        router.get("/mission") { (respondWith: ([Dummy]?, RequestError?) -> Void) in
            let error = RequestError(.badRequest, body: expectedError)
            respondWith(nil, error)
        }
        return router
    }
}
