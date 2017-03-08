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

import KituraNet
@testable import Kitura

class TestServer: KituraTest {

    static var allTests: [(String, (TestServer) -> () throws -> Void)] {
        return [
            ("testServerStartStop", testServerStartStop),
            ("testServerRun", testServerRun),
            ("testServerFail", testServerFail),
            ("testServerRestart", testServerRestart)
        ]
    }

    let httpPort = 8090
    let fastCgiPort = 9000

    override func setUp() {
        super.setUp()
        stopServer() // stop common server so we can run these tests
    }

    private func setupServerAndExpectations(expectStart: Bool, expectStop: Bool, expectFail: Bool) {
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

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }

    func testServerRun() {
        setupServerAndExpectations(expectStart: true, expectStop: false, expectFail: false)

        let requestQueue = DispatchQueue(label: "Request queue")
        requestQueue.async() {
            Kitura.run()
        }

        waitForExpectations(timeout: 10) { error in
            Kitura.stop()
            XCTAssertNil(error)
        }
    }

    func testServerFail() {
        do {
            let httpServer = HTTP.createServer()
            let fastCgiServer = FastCGI.createServer()
            defer {
                httpServer.stop()
                fastCgiServer.stop()
            }
            try httpServer.listen(on: httpPort)
            try fastCgiServer.listen(on: fastCgiPort)

            // setupServer startup should fail as we are already listening on the ports
            setupServerAndExpectations(expectStart: false, expectStop: false, expectFail: true)

            let requestQueue = DispatchQueue(label: "Request queue")
            requestQueue.async() {
                Kitura.start()
            }

            waitForExpectations(timeout: 10) { error in
                Kitura.stop()
                XCTAssertNil(error)
            }
        } catch {
            XCTFail("Unexpected error starting server: \(error)")
        }
    }

    func testServerRestart() {
        let port = httpPort
        let path = "/testServerRestart"
        let body = "Server is running."

        let router = Router()
        router.get(path) { _, response, next in
            response.send(body)
            next()
        }

        let server = Kitura.addHTTPServer(onPort: port, with: router)
        server.sslConfig = KituraTest.sslConfig.config

        let stopped = DispatchSemaphore(value: 0)
        server.stopped {
            stopped.signal()
        }

        Kitura.start()
        testResponse(port: port, path: path, expectedBody: body)
        Kitura.stop(unregister: false)
        stopped.wait()

        XCTAssertEqual(Kitura.httpServersAndPorts.count, 1, "Kitura.httpServersAndPorts.count is \(Kitura.httpServersAndPorts.count), should be 1")
        testResponse(port: port, path: path, expectedBody: nil, expectedStatus: nil)

        Kitura.start()
        testResponse(port: port, path: path, expectedBody: body)
        Kitura.stop() // default for unregister is true

        XCTAssertEqual(Kitura.httpServersAndPorts.count, 0, "Kitura.httpServersAndPorts.count is \(Kitura.httpServersAndPorts.count), should be 0")
    }

    private func testResponse(port: Int, method: String = "get", path: String, expectedBody: String?, expectedStatus: HTTPStatusCode? = HTTPStatusCode.OK) {

        performRequest(method, path: path, port: port, useSSL: true, callback: { response in
            let status = response?.statusCode
            XCTAssertEqual(status, expectedStatus, "status was \(status), expected \(expectedStatus)")
            do {
                let body = try response?.readString()
                XCTAssertEqual(body, expectedBody, "body was '\(body)', expected '\(expectedBody)'")
            } catch {
                XCTFail("Error reading body: \(error)")
            }
        })
    }
}
