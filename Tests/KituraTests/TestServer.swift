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

import KituraNet
@testable import Kitura

final class TestServer: KituraTest, KituraTestSuite {

    static var allTests: [(String, (TestServer) -> () throws -> Void)] {
        var listOfTests: [(String, (TestServer) -> () throws -> Void)] = [
            ("testServerStartStop", testServerStartStop),
            ("testServerRun", testServerRun),
            ("testServerFail", testServerFail),
            ("testServerStartWithStatus", testServerStartWithStatus),
            ("testServerStartWaitStop", testServerStartWaitStop),
            ("testServerRestart", testServerRestart)
        ]
        #if !SKIP_UNIX_SOCKETS
            listOfTests.append(("testUnixSocketServerRestart", testUnixSocketServerRestart))
        #endif
        return listOfTests
    }

    var httpPort = 8080
    let useNIO = ProcessInfo.processInfo.environment["KITURA_NIO"] != nil

    override func setUp() {
        super.setUp()
        stopServer() // stop common server so we can run these tests
    }

    private func setupServerAndExpectations(expectStart: Bool, expectStop: Bool, expectFail: Bool, httpPort: Int?=nil, fastCgiPort: Int?=nil) {
        let router = Router()
        let httpServer = Kitura.addHTTPServer(onPort: httpPort ?? 0, with: router)
        let fastCgiServer = useNIO ? FastCGIServer() : Kitura.addFastCGIServer(onPort: fastCgiPort ?? 0, with: router)

        if expectStart {
            let httpStarted = expectation(description: "HTTPServer started()")
            let fastCgiStarted = expectation(description: "FastCGIServer started()")

            httpServer.started {
                httpStarted.fulfill()
            }

            if useNIO {
                fastCgiStarted.fulfill()
            } else {
                fastCgiServer.started {
                    fastCgiStarted.fulfill()
                }
            }

        } else {
            httpServer.started {
                XCTFail("httpServer.started should not have been called")
            }

            if !useNIO {
                fastCgiServer.started {
                    XCTFail("fastCgiServer.started should not have been called")
                }
            }
        }

        if expectStop {
            let httpStopped = expectation(description: "HTTPServer stopped()")
            let fastCgiStopped = expectation(description: "FastCGIServer stopped()")

            httpServer.stopped {
                httpStopped.fulfill()
            }

            if useNIO {
                fastCgiStopped.fulfill()
            } else {
                fastCgiServer.stopped {
                    fastCgiStopped.fulfill()
                }
            }
        }

        if expectFail {
            let httpFailed = expectation(description: "HTTPServer failed()")
            let fastCgiFailed = expectation(description: "FastCGIServer failed()")

            httpServer.failed { error in
                httpFailed.fulfill()
            }

            if useNIO {
                fastCgiFailed.fulfill()
            } else {
                fastCgiServer.failed { error in
                    fastCgiFailed.fulfill()
                }
            }

        } else {
            httpServer.failed { error in
                XCTFail("\(error)")
            }

            if !useNIO {
                fastCgiServer.failed { error in
                    XCTFail("\(error)")
                }
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

    /// Sets up two servers on the same port. One will start, and one will fail to start
    /// as the address is already in use.
    private func setupConflictingServers(onPort: Int) {
        let router1 = Router()
        let router2 = Router()
        let server1 = Kitura.addHTTPServer(onPort: onPort, with: router1)
        let server2 = Kitura.addHTTPServer(onPort: onPort, with: router2)
        // Expect server 1 to start
        let server1Started = expectation(description: "Server 1 started on port \(onPort)")
        server1.started {
            server1Started.fulfill()
        }
        // Expect server 2 to fail (same port)
        let server2Failed = expectation(description: "Server 2 failed - port should already be in use")
        server2.failed { error in
            XCTAssertNotNil(error)
            server2Failed.fulfill()
        }
    }

    /// Tests that Kitura.startWithStatus() returns the correct number of servers
    /// that failed to start.
    func testServerStartWithStatus() {
        setupConflictingServers(onPort: 12345)
        let numFailures = Kitura.startWithStatus()
        XCTAssertEqual(numFailures, 1, "Expected startWithStatus() to report 1 server fail")
        waitForExpectations(timeout: 10) { error in
            Kitura.stop()
            XCTAssertNil(error)
        }
    }

    /// Tests that Kitura.wait() will wait until all successful servers are stopped.
    func testServerStartWaitStop() {
        setupConflictingServers(onPort: 23456)
        let waitComplete = DispatchSemaphore(value: 0)
        let requestQueue = DispatchQueue(label: "Request queue")
        requestQueue.async() {
            let failures = Kitura.startWithStatus()
            XCTAssertEqual(failures, 1, "Expected one server to fail to start")
            // As soon as the server has started, wait for it to stop
            Kitura.wait()
            // Signal that Kitura.wait() has completed
            waitComplete.signal()
        }
        waitForExpectations(timeout: 10) { error in
            // Check that Kitura.wait() is still waiting
            let preStopStatus = waitComplete.wait(timeout: DispatchTime.now())
            XCTAssertEqual(preStopStatus, DispatchTimeoutResult.timedOut, "Kitura.wait() unexpectedly completed")
            // Stop the server, allowing wait() to complete
            Kitura.stop()
            XCTAssertNil(error)
            // Check that the Kitura.wait() call completes
            let postStopStatus = waitComplete.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(10))
            XCTAssertEqual(postStopStatus, DispatchTimeoutResult.success, "Timed out waiting to Kitura.wait() to complete")
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
        var port = httpPort
        let path = "/testServerRestart"
        let body = "Server is running."

        let router = Router()
        router.get(path) { _, response, next in
            response.send(body)
            next()
        }

        let server = Kitura.addHTTPServer(onPort: 0, with: router)
        server.sslConfig = KituraTest.sslConfig.config

        let stopped = DispatchSemaphore(value: 0)
        server.stopped {
            stopped.signal()
        }

        Kitura.start()
        port = server.port!
        testResponse(port: port, path: path, expectedBody: body)
        Kitura.stop(unregister: false)
        stopped.wait()

        XCTAssertEqual(Kitura.httpServersAndPorts.count, 1, "Kitura.httpServersAndPorts.count is \(Kitura.httpServersAndPorts.count), should be 1")
        testResponse(port: port, path: path, expectedBody: nil, expectedStatus: nil)

        Kitura.start()
        port = server.port!
        testResponse(port: port, path: path, expectedBody: body)
        Kitura.stop() // default for unregister is true

        XCTAssertEqual(Kitura.httpServersAndPorts.count, 0, "Kitura.httpServersAndPorts.count is \(Kitura.httpServersAndPorts.count), should be 0")
    }

    func testUnixSocketServerRestart() {
#if !SKIP_UNIX_SOCKETS
        let path = "/testSocketServerRestart"
        let body = "Server is running."

        // Create a temporary socket path for this server
        let socketPath = uniqueTemporaryFilePath()
        defer {
            removeTemporaryFilePath(socketPath)
        }

        let router = Router()
        router.get(path) { _, response, next in
            response.send(body)
            next()
        }

        let server = Kitura.addHTTPServer(onUnixDomainSocket: socketPath, with: router)
        server.sslConfig = KituraTest.sslConfig.config

        let stopped = DispatchSemaphore(value: 0)
        let started = DispatchSemaphore(value: 0)
        server.stopped {
            stopped.signal()
        }
        server.started {
            started.signal()
        }

        Kitura.start()
        if started.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(5)) != DispatchTimeoutResult.success {
            return XCTFail("Server failed to start")
        }
        XCTAssertEqual(server.unixDomainSocketPath, socketPath, "Server listening on wrong path")
        testResponse(socketPath: socketPath, path: path, expectedBody: body)
        Kitura.stop(unregister: false)
        if stopped.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(5)) != DispatchTimeoutResult.success {
            return XCTFail("Server failed to stop")
        }

        XCTAssertEqual(Kitura.httpServersAndUnixSocketPaths.count, 1, "Kitura.httpServersAndUnixSocketPaths.count is \(Kitura.httpServersAndUnixSocketPaths.count), should be 1")
        testResponse(socketPath: socketPath, path: path, expectedBody: nil, expectedStatus: nil)

        Kitura.start()
        if started.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(5)) != DispatchTimeoutResult.success {
            return XCTFail("Server failed to start")
        }
        XCTAssertEqual(server.unixDomainSocketPath, socketPath, "Server listening on wrong path")
        testResponse(socketPath: socketPath, path: path, expectedBody: body)
        Kitura.stop() // default for unregister is true
        if stopped.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(5)) != DispatchTimeoutResult.success {
            return XCTFail("Server failed to stop")
        }

        XCTAssertEqual(Kitura.httpServersAndUnixSocketPaths.count, 0, "Kitura.httpServersAndUnixSocketPaths.count is \(Kitura.httpServersAndUnixSocketPaths.count), should be 0")
#endif
    }

    private func testResponse(port: Int? = nil, socketPath: String? = nil, method: String = "get", path: String, expectedBody: String?, expectedStatus: HTTPStatusCode? = HTTPStatusCode.OK) {

        performRequest(method, path: path, port: port, socketPath: socketPath, useSSL: true, useUnixSocket: (socketPath != nil), callback: { response in
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
