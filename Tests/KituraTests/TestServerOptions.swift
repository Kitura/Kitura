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
import Dispatch

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
            ("testLargePostExceedsLimit", testLargePostExceedsLimit),
            ("testRequestSizeLimitCustomResponse", testRequestSizeLimitCustomResponse),
            ("testLargeHeaderExceedsLimit", testLargeHeaderExceedsLimit),
            ("testConnectionRejection", testConnectionRejection),
            ("testConnectionRejectionCustomResponse", testConnectionRejectionCustomResponse),
        ]
    }

    let router = TestServerOptions.setupRouter()

    // MARK: Request size limit tests

    // Tests that a request whose total size is smaller than the configured limit is successful.
    func testSmallPostSucceeds() {
        performServerTest(router, options: ServerOptions(requestSizeLimit: 10), timeout: 30) { expectation in
            // Data that is within request limit
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

    // Tests that a POST request containing body data that exceeds the configured limit is
    // correctly rejected with `.requestTooLong`.
    func testLargePostExceedsLimit() {
        performServerTest(router, options: ServerOptions(requestSizeLimit: 10), timeout: 30) { expectation in
            // Data that exceeds the request size limit
            let count = 20
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

    // Tests that a POST request containing body data that exceeds the configured limit is
    // correctly rejected, and the response is customized by the custom response generator.
    func testRequestSizeLimitCustomResponse() {
        let customResponse: (Int, String) -> (HTTPStatusCode, String)? = { requestLimit, client in
            return (.badRequest, "Request too large, limit \(requestLimit)")
        }
        performServerTest(router, options: ServerOptions(requestSizeLimit: 10, requestSizeResponseGenerator: customResponse), timeout: 30) { expectation in
            // Data that exceeds the request size limit
            let count = 20
            let postData = Data(repeating: UInt8.max, count: count)

            self.performRequest("post", path: "/largePostFail", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.badRequest, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let message = try response?.readString()
                    XCTAssertEqual(message, "Request too large, limit 10")
                } catch {
                    XCTFail("Unable to read response: \(error)")
                }
                expectation.fulfill()
            }, requestModifier: { request in
                request.write(from: postData)
            })
        }
    }

    // Tests that a request with a modest total size, but an over-sized header (> 80kb)
    // is correctly rejected as a `.badRequest`.
    func testLargeHeaderExceedsLimit() {
        performServerTest(router, options: nil /* default options */, timeout: 30) { expectation in
            // Data that is within default request limit
            let count = 10
            let postData = Data(repeating: UInt8.max, count: count)
            // Header data that is within the default request limit, but should be rejected
            // as headers are limited to 80kb.
            let headerBytes = 1024 * 80 + 1
            let headerData = Data(repeating: 0x7A, count: headerBytes)
            let tooLongString = String(data: headerData, encoding: .utf8)!

            self.performRequest("post", path: "/smallPost", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.badRequest, "HTTP Status code was \(String(describing: response?.statusCode))")
                expectation.fulfill()
            }, requestModifier: { request in
                request.headers["Much-Too-Long"] = tooLongString
                request.write(from: postData)
            })
        }
    }

    // MARK: Concurrent client limit tests

    // Class to hold status code from attempted client request
    class ClientStatus {
        var code: HTTPStatusCode = .unknown
    }

    // Wrap ClientRequest in an async dispatch block as Kitura-net's implementation is
    // not asynchronous, and we need connections to be established in parallel.
    func asyncClientRequest(expectation: XCTestExpectation, status: ClientStatus) {
        DispatchQueue.global().async {
            self.performRequest("get", path: "/answerSlowly", callback: { response in
                defer {
                    expectation.fulfill()
                }
                guard let response = response else {
                    return XCTFail("ERROR!!! ClientRequest response object was nil")
                }
                status.code = response.statusCode
            })
        }
    }

    // Tests that when more concurrent connections are attempted than the server permits,
    // the extra connections are rejected with `.serviceUnavailable`.
    // Clients attempt to make a request to a route that deliberately takes a second to
    // respond. This allows us to connect several clients in parallel.
    func testConnectionRejection() {
        let numClients = 5  // Number of clients to connect
        let maxClients = 2  // Maximum number of concurrent clients

        // Create client status objects and expectations
        var clientStatus = [ClientStatus]()
        var clientExpectations = [XCTestExpectation]()
        for i in 1...numClients {
            clientStatus.append(ClientStatus())
            clientExpectations.append(self.expectation(description: "Client \(i) completed"))
        }

        // Start server and make concurrent request attempts. performServerTest() will
        // not complete until all expectations (including client completion) are fulfilled.
        performServerTest(router, options: ServerOptions(connectionLimit: maxClients), sslOption: .httpOnly, socketTypeOption: .inet, timeout: 30) { expectation in
            for i in 0..<numClients {
                usleep(1000)  // TODO: properly fix crash when creating ClientRequests concurrently
                self.asyncClientRequest(expectation: clientExpectations[i], status: clientStatus[i])
            }
            expectation.fulfill()
        }

        // Assess results
        var successCount = 0
        var failCount = 0
        for i in 0..<numClients {
            switch clientStatus[i].code {
            case .OK: successCount += 1
            case .serviceUnavailable: failCount += 1
            default: XCTFail("Unexpected client status: \(clientStatus[i].code)")
            }
        }
        XCTAssertEqual(successCount, maxClients, "Incorrect number of accepted client connections")
        XCTAssertEqual(failCount, numClients - maxClients, "Incorrect number of rejected client connections")
    }

    // Tests that the response can be customized for when a connection is rejected.
    func testConnectionRejectionCustomResponse() {
        let numClients = 5  // Number of clients to connect
        let maxClients = 2  // Maximum number of concurrent clients

        // Create client status objects and expectations
        var clientStatus = [ClientStatus]()
        var clientExpectations = [XCTestExpectation]()
        for i in 1...numClients {
            clientStatus.append(ClientStatus())
            clientExpectations.append(self.expectation(description: "Client \(i) completed"))
        }

        let customResponse: (Int, String) -> (HTTPStatusCode, String)? = { limit, client in
            return (.badRequest, "Too many connections (more than \(limit))")
        }

        // Start server and make concurrent request attempts. performServerTest() will
        // not complete until all expectations (including client completion) are fulfilled.
        performServerTest(router, options: ServerOptions(connectionLimit: maxClients, connectionResponseGenerator: customResponse), sslOption: .httpOnly, socketTypeOption: .inet, timeout: 30) { expectation in
            for i in 0..<numClients {
                usleep(1000)  // TODO: properly fix crash when creating ClientRequests concurrently
                self.asyncClientRequest(expectation: clientExpectations[i], status: clientStatus[i])
            }
            expectation.fulfill()
        }

        // Assess results
        var successCount = 0
        var failCount = 0
        for i in 0..<numClients {
            switch clientStatus[i].code {
            case .OK: successCount += 1
            case .badRequest: failCount += 1
            case .serviceUnavailable: XCTFail("Response was not customized")
            default: XCTFail("Unexpected client status: \(clientStatus[i].code)")
            }
        }
        XCTAssertEqual(successCount, maxClients, "Incorrect number of accepted client connections")
        XCTAssertEqual(failCount, numClients - maxClients, "Incorrect number of rejected client connections")
    }

    // MARK: Router configuration for this suite

    static func setupRouter() -> Router {
        let router = Router()

        router.post("/smallPost") { request, response, _ in
            try response.status(.OK).end()
        }

        router.post("/largePostFail") { request, response, _ in
            XCTFail("Large post request succeeded, should have been rejected")
            try response.status(.OK).end()
        }

        router.get("/answerSlowly") { request, response, _ in
            // Return .OK after 1 second
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
                do {
                    try response.status(.OK).end()
                } catch {
                    XCTFail("\(error)")
                }
            }
        }

        return router
    }

}
