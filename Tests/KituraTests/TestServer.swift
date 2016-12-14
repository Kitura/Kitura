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
import Dispatch

import Kitura

class TestServer: XCTestCase {

    static var allTests: [(String, (TestServer) -> () throws -> Void)] {
        return [
            ("testServerStartStop", testServerStartStop),
            ("testServerRun", testServerRun),
            ("testServerFail", testServerFail)
        ]
    }

    override func setUp() {
        doSetUp()
    }

    override func tearDown() {
        doTearDown()
    }

    private func setupServerAndExpectations(expectStart: Bool, expectStop: Bool, expectFail: Bool,
                                            httpPort: Int = 8090, fastCgiPort: Int = 9000) {
        let router = Router()
        let httpServer = Kitura.addHTTPServer(onPort: httpPort, with: router)
        let fastCgiServer = Kitura.addFastCGIServer(onPort: fastCgiPort, with: router)

        if expectStart {
            let httpStarted = expectation(description: "HTTPServer started()")
            let fastCgiStarted = expectation(description: "FastCGIServer started()")

            httpServer.started {
                httpStarted.fulfill()
            }
            fastCgiServer.started {
                fastCgiStarted.fulfill()
            }
        } else {
            httpServer.started {
                XCTFail("httpServer.started should not have been called")
            }
            fastCgiServer.started {
                XCTFail("fastCgiServer.started should not have been called")
            }
        }

        if expectStop {
            let httpStopped = expectation(description: "HTTPServer stopped()")
            let fastCgiStopped = expectation(description: "FastCGIServer stopped()")

            httpServer.stopped {
                httpStopped.fulfill()
            }
            fastCgiServer.stopped {
                fastCgiStopped.fulfill()
            }
        }

        if expectFail {
            let httpFailed = expectation(description: "HTTPServer failed()")
            let fastCgiFailed = expectation(description: "FastCGIServer failed()")

            httpServer.failed { error in
                httpFailed.fulfill()
            }
            fastCgiServer.failed { error in
                fastCgiFailed.fulfill()
            }
        } else {
            httpServer.failed { error in
                XCTFail("\(error)")
            }
            fastCgiServer.failed { error in
                XCTFail("\(error)")
            }
        }
    }

    func testServerStartStop() {
        setupServerAndExpectations(expectStart: true, expectStop: true, expectFail: false)

        let requestQueue = DispatchQueue(label: "Request queue")
        requestQueue.async() {
            Kitura.start()
            Kitura.stop()
        }

        waitExpectation(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }

    func testServerRun() {
        setupServerAndExpectations(expectStart: true, expectStop: false, expectFail: false)

        let requestQueue = DispatchQueue(label: "Request queue")
        requestQueue.async() {
            Kitura.run()
        }

        waitExpectation(timeout: 10) { error in
            Kitura.stop()
            XCTAssertNil(error)
        }
    }

    func testServerFail() {
        setupServerAndExpectations(expectStart: false, expectStop: false, expectFail: true,
                                   httpPort: -1, fastCgiPort: -1)

        let requestQueue = DispatchQueue(label: "Request queue")
        requestQueue.async() {
            Kitura.start()
        }

        waitExpectation(timeout: 10) { error in
            Kitura.stop()
            XCTAssertNil(error)
        }
    }
}
