/**
 * Copyright IBM Corporation 2016, 2017
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

#if KITURA_NIO
import KituraNIO
#else
import KituraNet
#endif

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

    let httpPort = 8080
    let fastCgiPort = 9000

    override func setUp() {
        super.setUp()
        stopServer() // stop common server so we can run these tests
    }

    private func setupServerAndExpectations(expectStart: Bool, expectStop: Bool, expectFail: Bool, httpPort: Int?=nil, fastCgiPort: Int?=nil) {
        let router = Router()

        #if KITURA_NIO
        let httpServer = Kitura.addHTTPServer(onPort: httpPort ?? self.httpPort, with: router, allowPortReuse: true)
        #else
        let httpServer = Kitura.addHTTPServer(onPort: httpPort ?? self.httpPort, with: router)
        let fastCgiServer = Kitura.addFastCGIServer(onPort: fastCgiPort ?? self.fastCgiPort, with: router)
        #endif

        if expectStart {
            let httpStarted = expectation(description: "HTTPServer started()")

            #if !KITURA_NIO
            let fastCgiStarted = expectation(description: "FastCGIServer started()")
            #endif

            httpServer.started {
                httpStarted.fulfill()
            }

            #if !KITURA_NIO
            fastCgiServer.started {
                fastCgiStarted.fulfill()
            }
            #endif
        } else {
            httpServer.started {
                XCTFail("httpServer.started should not have been called")
            }

            #if !KITURA_NIO
            fastCgiServer.started {
                XCTFail("fastCgiServer.started should not have been called")
            }
            #endif
        }

        if expectStop {
            let httpStopped = expectation(description: "HTTPServer stopped()")

            #if !KITURA_NIO
            let fastCgiStopped = expectation(description: "FastCGIServer stopped()")
            #endif

            httpServer.stopped {
                httpStopped.fulfill()
            }

            #if !KITURA_NIO
            fastCgiServer.stopped {
                fastCgiStopped.fulfill()
            }
            #endif
        }

        if expectFail {
            let httpFailed = expectation(description: "HTTPServer failed()")

            #if !KITURA_NIO
            let fastCgiFailed = expectation(description: "FastCGIServer failed()")
            #endif

            httpServer.failed { error in
                httpFailed.fulfill()
            }

            #if !KITURA_NIO
            fastCgiServer.failed { error in
                fastCgiFailed.fulfill()
            }
            #endif

        } else {
            httpServer.failed { error in
                XCTFail("\(error)")
            }

            #if !KITURA_NIO
            fastCgiServer.failed { error in
                XCTFail("\(error)")
            }
            #endif
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
        // setupServer startup should fail as we are passing in illegal ports
        setupServerAndExpectations(expectStart: false, expectStop: false, expectFail: true,
                                   httpPort: -1, fastCgiPort: -2)

        let requestQueue = DispatchQueue(label: "Request queue")
        requestQueue.async() {
            Kitura.start()
        }

        waitForExpectations(timeout: 10) { error in
            Kitura.stop()
            XCTAssertNil(error)
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

        #if KITURA_NIO
        let server = Kitura.addHTTPServer(onPort: port, with: router, allowPortReuse: true)
        #else
        let server = Kitura.addHTTPServer(onPort: port, with: router)
        #endif

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
            XCTAssertEqual(status, expectedStatus, "status was \(String(describing: status)), expected \(String(describing: expectedStatus))")
            do {
                let body = try response?.readString()
                XCTAssertEqual(body, expectedBody, "body was '\(String(describing: body))', expected '\(String(describing: expectedBody))'")
            } catch {
                XCTFail("Error reading body: \(error)")
            }
        })
    }
}
