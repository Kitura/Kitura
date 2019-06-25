/**
 * Copyright IBM Corporation 2016-2019
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
import Kitura

@testable import KituraNet

import Foundation
import Dispatch

// The type of transport to use when communicating with the server.
enum SSLOption {
    // Tests will be performed over both HTTP and HTTPS.
    case both
    // Only HTTP will be tested.
    case httpOnly
    // Only HTTPS will be tested.
    case httpsOnly
}

// The type of socket to use when connecting to the server.
enum SocketTypeOption {
    // Both inet and unix sockets will be tested, in turn
    case both
    // Only inet sockets will be tested
    case inet
    // Only unix sockets will be tested
    case unix
}

// Kitura test suites should conform to this so that TestLinuxSafeguard can
// access the `allTests` array generically
protocol KituraTestSuite {
    static var allTests: [(String, (Self) -> () throws -> Void)] { get }
    #if os(macOS)
    // Expose defaultTestSuite from XCTestSuite
    static var defaultTestSuite: XCTestSuite { get }
    #endif
}

class KituraTest: XCTestCase {
    // A singleton Kitura server listening on HTTP on an INET socket
    static private(set) var httpInetServer: HTTPServer?
    // A singleton Kitura server listening on HTTPS on an INET socket
    static private(set) var httpsInetServer: HTTPServer?
    // A singleton Kitura server listening on HTTP on a Unix socket
    static private(set) var httpUnixServer: HTTPServer?
    // A singleton Kitura server listening on HTTPS on a Unix socket
    static private(set) var httpsUnixServer: HTTPServer?

    // The port of the server returned by startServer().
    private(set) var port = -1
    // Whether the server used by doPerformServerTest should use SSL.
    private(set) var useSSL = false
    // The socket file path of the server returned by startUnixSocketServer().
    private(set) var socketFilePath: String? = nil
    // Whether the server used by doPerformServerTest should use a Unix domain socket.
    private(set) var useUnixSocket = false

    /// The types of listeners we currently support.
    private enum ListenerType {
        case inet(Int)
        case unix(String)
    }

    static let sslConfig: SSLConfig = {
        let sslConfigDir = URL(fileURLWithPath: #file).appendingPathComponent("../SSLConfig")

        #if os(Linux)
            let certificatePath = sslConfigDir.appendingPathComponent("certificate.pem").standardized.path
            let keyPath = sslConfigDir.appendingPathComponent("key.pem").standardized.path
            return SSLConfig(withCACertificateDirectory: nil, usingCertificateFile: certificatePath,
                             withKeyFile: keyPath, usingSelfSignedCerts: true)
        #else
            let chainFilePath = sslConfigDir.appendingPathComponent("certificateChain.pfx").standardized.path
            return SSLConfig(withChainFilePath: chainFilePath, withPassword: "kitura",
                             usingSelfSignedCerts: true)
        #endif
    }()

    private static let initOnce: () = {
        PrintLogger.use(colored: true)
    }()

    override func setUp() {
        super.setUp()
        KituraTest.initOnce
    }

    func buildServerTest(_ router: ServerDelegate, sslOption: SSLOption = SSLOption.httpOnly, socketTypeOption: SocketTypeOption = SocketTypeOption.both, timeout: TimeInterval = 10,
                           line: Int = #line) -> RequestTestBuilder {
        return ServerTestBuilder(test: self, router: router, sslOption: sslOption, socketTypeOption: socketTypeOption, timeout: timeout, line: line)
    }

    func performServerTest(_ router: ServerDelegate, sslOption: SSLOption = SSLOption.httpOnly, socketTypeOption: SocketTypeOption = SocketTypeOption.both, timeout: TimeInterval = 10,
                           line: Int = #line, asyncTasks: (XCTestExpectation) -> Void...) {
        performServerTest(router, sslOption: sslOption, socketTypeOption: socketTypeOption, timeout: timeout, line: line, asyncTasks: asyncTasks)
    }

    func performServerTest(_ router: ServerDelegate, sslOption: SSLOption = SSLOption.httpOnly, socketTypeOption: SocketTypeOption = SocketTypeOption.both, timeout: TimeInterval = 10,
                           line: Int = #line, asyncTasks: [(XCTestExpectation) -> Void]) {
        if sslOption != SSLOption.httpsOnly {
            self.useSSL = false
            if socketTypeOption != SocketTypeOption.unix {
                self.useUnixSocket = false
                doPerformServerTest(router: router, timeout: timeout, line: line, asyncTasks: asyncTasks)
            }
#if !SKIP_UNIX_SOCKETS
            setUp()
            if socketTypeOption != SocketTypeOption.inet {
                self.useUnixSocket = true
                doPerformServerTest(router: router, timeout: timeout, line: line, asyncTasks: asyncTasks)
            }
#endif
        }
        
        // Call setUp to start at a known state (ideally, this should have been written as a separate test)
        setUp()

        if sslOption != SSLOption.httpOnly {
            self.useSSL = true
            if socketTypeOption != SocketTypeOption.unix {
                self.useUnixSocket = false
                doPerformServerTest(router: router, timeout: timeout, line: line, asyncTasks: asyncTasks)
            }
#if !SKIP_UNIX_SOCKETS
            setUp()
            if socketTypeOption != SocketTypeOption.inet {
                self.useUnixSocket = true
                doPerformServerTest(router: router, timeout: timeout, line: line, asyncTasks: asyncTasks)
            }
#endif
        }
    }

    func doPerformServerTest(router: ServerDelegate, timeout: TimeInterval, line: Int, asyncTasks: [(XCTestExpectation) -> Void]) {

        if self.useUnixSocket {
            guard let socketPath = startUnixSocketServer(router: router) else {
                return XCTFail("Error starting server. useSSL:\(self.useSSL), useUnixSocket:\(self.useUnixSocket)")
            }
            XCTAssertEqual(socketPath, self.socketFilePath, "Server is listening on the wrong path")
        } else {
            guard let port = startServer(router: router) else {
                return XCTFail("Error starting server. useSSL:\(self.useSSL), useUnixSocket:\(self.useUnixSocket)")
            }
            self.port = port
        }
        let requestQueue = DispatchQueue(label: "Request queue")
        for (index, asyncTask) in asyncTasks.enumerated() {
            let expectation = self.expectation(line: line, index: index)
            requestQueue.async {
                asyncTask(expectation)
            }
        }

        // wait for timeout or for all created expectations to be fulfilled
        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error)
        }
    }

    private func startServer(router: ServerDelegate) -> Int? {
        if useSSL {
            if let server = KituraTest.httpsInetServer {
                server.delegate = router
                return server.port
            }
        } else {
            if let server = KituraTest.httpInetServer {
                server.delegate = router
                return server.port
            }
        }

        let server = HTTP.createServer()
        server.delegate = router
        if useSSL {
            server.sslConfig = KituraTest.sslConfig.config
        }

        do {
            try server.listen(on: 0, address: "localhost")

            if useSSL {
                KituraTest.httpsInetServer = server
            } else {
                KituraTest.httpInetServer = server
            }
            return server.port
        } catch {
            XCTFail("Error starting server: \(error)")
            return nil
        }
    }

    private func startUnixSocketServer(router: ServerDelegate) -> String? {
        if useSSL {
            if let server = KituraTest.httpsUnixServer {
                server.delegate = router
                guard let listenPath = server.unixDomainSocketPath else {
                    XCTFail("Unix socket path missing")
                    return nil
                }
                self.socketFilePath = listenPath
                return server.unixDomainSocketPath
            }
        } else {
            if let server = KituraTest.httpUnixServer {
                server.delegate = router
                guard let listenPath = server.unixDomainSocketPath else {
                    XCTFail("Unix socket path missing")
                    return nil
                }
                self.socketFilePath = listenPath
                return server.unixDomainSocketPath
            }
        }
        let server = HTTP.createServer()
        server.delegate = router
        if useSSL {
            server.sslConfig = KituraTest.sslConfig.config
        }

        // Create a temporary path for Unix domain socket
        let socketPath = uniqueTemporaryFilePath()
        self.socketFilePath = socketPath

        do {
            try server.listen(unixDomainSocketPath: socketPath)

            if useSSL {
                KituraTest.httpsUnixServer = server
            } else {
                KituraTest.httpUnixServer = server
            }
            return server.unixDomainSocketPath
        } catch {
            XCTFail("Error starting server: \(error)")
            return nil
        }
    }

    func stopServer() {
        KituraTest.httpInetServer?.stop()
        KituraTest.httpInetServer = nil

        KituraTest.httpsInetServer?.stop()
        KituraTest.httpsInetServer = nil

        KituraTest.httpUnixServer?.stop()
        KituraTest.httpUnixServer = nil

        KituraTest.httpsUnixServer?.stop()
        KituraTest.httpsUnixServer = nil

        // Clean up temporary file for Unix domain socket
        if let socketFilePath = socketFilePath {
            removeTemporaryFilePath(socketFilePath)
        }
    }

    func performRequest(_ method: String, path: String, port: Int? = nil, socketPath: String? = nil, useSSL: Bool? = nil, useUnixSocket: Bool? = nil, followRedirects: Bool = true,
                        callback: @escaping ClientRequest.Callback, headers: [String: String]? = nil,
                        requestModifier: ((ClientRequest) -> Void)? = nil) {

        let port = port ?? self.port
        let socketPath = socketPath ?? self.socketFilePath
        let useSSL = useSSL ?? self.useSSL
        let useUnixSocket = useUnixSocket ?? self.useUnixSocket

        var allHeaders = [String: String]()
        if  let headers = headers {
            for  (headerName, headerValue) in headers {
                allHeaders[headerName] = headerValue
            }
        }
        if allHeaders["Content-Type"] == nil {
            allHeaders["Content-Type"] = "text/plain"
        }

        let schema = useSSL ? "https" : "http"
        var options: [ClientRequest.Options] =
            [.method(method), .schema(schema), .hostname("localhost"), .path(path), .headers(allHeaders)]
        if useSSL {
            options.append(.disableSSLVerification)
        }
        if !followRedirects {
            options.append(.maxRedirects(0))
        }
        let req: ClientRequest
        if useUnixSocket {
            req = HTTP.request(options, unixDomainSocketPath: socketPath, callback: callback)
        } else {
            options.append(.port(UInt16(port).toInt16()))
            req = HTTP.request(options, callback: callback)
        }
        if let requestModifier = requestModifier {
            requestModifier(req)
        }
        req.end(close: true)
    }

    func expectation(line: Int, index: Int) -> XCTestExpectation {
        return self.expectation(description: "\(type(of: self)):\(line)[\(index)](ssl:\(useSSL))")
    }

    // Generates a unique temporary file path suitable for use as a Unix domain socket.
    // On Linux, a path is returned within /tmp
    // On MacOS, a path is returned within /var/folders
    func uniqueTemporaryFilePath() -> String {
        #if os(Linux)
        let temporaryDirectory = "/tmp"
        #else
        var temporaryDirectory: String
        if #available(OSX 10.12, *) {
            temporaryDirectory = FileManager.default.temporaryDirectory.path
        } else {
            temporaryDirectory = "/tmp"
        }
        #endif
        return temporaryDirectory + "/KituraTest." + String(ProcessInfo.processInfo.globallyUniqueString.prefix(20))
    }

    // Delete a temporary file path.
    func removeTemporaryFilePath(_ path: String) {
        let fileURL = URL(fileURLWithPath: path)
        let fm = FileManager.default
        do {
            try fm.removeItem(at: fileURL)
        } catch {
            XCTFail("Unable to remove \(path): \(error.localizedDescription)")
        }
    }
}

fileprivate extension UInt16 {
    func toInt16() -> Int16 {
        return Int16(bitPattern: self)
    }
}
