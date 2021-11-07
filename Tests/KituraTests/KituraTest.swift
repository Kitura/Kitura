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

enum SocketTypeOption {
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

typealias AsyncTaskCompletion = ()->Void

class KituraTest: XCTestCase {
    // A singleton Kitura server listening on HTTP on an INET socket
    static private(set) var httpInetServer: HTTPServer?
    // A singleton Kitura server listening on HTTPS on an INET socket
    static private(set) var httpsInetServer: HTTPServer?
    // A singleton Kitura server listening on HTTP on a Unix socket
    static private(set) var httpUnixServer: HTTPServer?
    // A singleton Kitura server listening on HTTPS on a Unix socket
    static private(set) var httpsUnixServer: HTTPServer?

    // A short-lived Kitura server created for a specific test
    private var serverWithOptions: HTTPServer?

    /// The types of listeners we currently support.
    internal enum ListenerType {
        case inet(Int)
        case unix(String)
    }

     struct ServerConfig {
        let socketType: SocketTypeOption
        let useSSL: Bool
    }

    internal struct ServerContext {
        public let listenerType: ListenerType
        public let useSSL: Bool
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

    func buildServerTest(_ router: ServerDelegate, sslOption: SSLOption = SSLOption.both, socketTypeOption: [SocketTypeOption] = [.inet, .unix], timeout: TimeInterval = 10,
                           line: Int = #line) -> RequestTestBuilder {
        return ServerTestBuilder(test: self, router: router, sslOption: sslOption, socketTypeOption: socketTypeOption, timeout: timeout, line: line)
    }

    func performServerTest(_ router: ServerDelegate, options: ServerOptions? = nil, sslOption: SSLOption = SSLOption.both, socketTypeOption: [SocketTypeOption] = [.inet, .unix], timeout: TimeInterval = 10,
                           line: Int = #line, asyncTasks: (KituraTest.ServerContext, @escaping AsyncTaskCompletion)->Void...) {
        performServerTest(router, options: options, sslOption: sslOption, socketTypeOption: socketTypeOption, timeout: timeout, line: line, asyncTasks: asyncTasks)
    }

    func performServerTest(_ router: ServerDelegate, options: ServerOptions? = nil, sslOption: SSLOption = SSLOption.both, socketTypeOption: SocketTypeOption, timeout: TimeInterval = 10,
                           line: Int = #line, asyncTasks: [(KituraTest.ServerContext, @escaping AsyncTaskCompletion)->Void]) {

        performServerTest(router, options: options, sslOption: sslOption, socketTypeOption: [socketTypeOption], timeout: timeout, asyncTasks: asyncTasks)
    }

    func performServerTest(_ router: ServerDelegate, options: ServerOptions? = nil, sslOption: SSLOption = SSLOption.both, socketTypeOption: [SocketTypeOption] = [.inet, .unix], timeout: TimeInterval = 10,
                           line: Int = #line, asyncTasks: [(KituraTest.ServerContext, @escaping AsyncTaskCompletion)->Void]) {
        if sslOption != SSLOption.httpsOnly {
            if socketTypeOption.contains(.inet) {
                doPerformServerTest(router: router,
                                    config: ServerConfig(socketType: .inet, useSSL: false),
                                    options: options, timeout: timeout, line: line, asyncTasks: asyncTasks)
            }
#if !SKIP_UNIX_SOCKETS
            setUp()
            if socketTypeOption.contains(.unix) {
                doPerformServerTest(router: router,
                                    config: ServerConfig(socketType: .unix, useSSL: false),
                                    options: options, timeout: timeout, line: line, asyncTasks: asyncTasks)
            }
#endif
        }
        
        // Call setUp to start at a known state (ideally, this should have been written as a separate test)
        setUp()

        if sslOption != SSLOption.httpOnly {
            if socketTypeOption.contains(.inet) {
                doPerformServerTest(router: router,
                                    config: ServerConfig(socketType: .inet, useSSL: true),
                                    options: options, timeout: timeout, line: line, asyncTasks: asyncTasks)
            }
#if !SKIP_UNIX_SOCKETS
            setUp()
            if socketTypeOption.contains(.unix) {
                doPerformServerTest(router: router,
                                    config: ServerConfig(socketType: .unix, useSSL: true),
                                    options: options, timeout: timeout, line: line, asyncTasks: asyncTasks)
            }
#endif
        }
    }

    private func doPerformServerTest(router: ServerDelegate, config: ServerConfig, options: ServerOptions?, timeout: TimeInterval, line: Int, asyncTasks: [(KituraTest.ServerContext, @escaping AsyncTaskCompletion) -> Void]) {

        let serverContext: ServerContext

        if config.socketType == .unix {
            guard let socketPath = startUnixSocketServer(config: config, router: router, options: options) else {
                return XCTFail("Error starting server. config: \(config) ")
            }
            serverContext = ServerContext(listenerType: .unix(socketPath), useSSL: config.useSSL)
        } else {
            guard let port = startServer(config: config, router: router, options: options) else {
                return XCTFail("Error starting server. config: \(config)")
            }
            serverContext = ServerContext(listenerType: .inet(port), useSSL: config.useSSL)
        }
        let requestQueue = DispatchQueue(label: "Request queue", attributes: .concurrent )
        let group = DispatchGroup()
        for asyncTask in asyncTasks {
            group.enter()
            requestQueue.async {
                asyncTask(serverContext) {
                    group.leave()
                }
            }
        }

        let result = group.wait(timeout: .now() + timeout)
        XCTAssertTrue(result == .success)

        // If we created a short-lived server for specific ServerOptions, shut it down now
        serverWithOptions?.stop()

        // TODO: Need a completion handler on stop() to properly check for existence
        if case .unix(let socketPath) = serverContext.listenerType {
            let useNIO = ProcessInfo.processInfo.environment["KITURA_NIO"] != "0"

            if !useNIO {
                // NIO will remove socket path on close
                removeTemporaryFilePath(socketPath)
            }
        }
    }

    // Start a server. If a non-nil `options` is provided, then the server is stored
    // as the `serverWithOptions` property, and will be shut down at the end of the test.
    private func doStartServer(config: ServerConfig, router: ServerDelegate, options: ServerOptions?) -> HTTPServer? {
        let server = HTTP.createServer()
        server.delegate = router

        if config.useSSL {
            server.sslConfig = KituraTest.sslConfig.config
        }

        if let options = options {
            server.options = options
            serverWithOptions = server
        }

        do {
            try server.listen(on: 0, address: "localhost")
            return server
        } catch {
            XCTFail("Error starting server: \(error)")
            return nil
        }
    }

    // Start a server on an inet socket. If nil `options` are specified, this is
    // a generic server that can be reused between tests, and will be stored as a
    // static property.
    private func startServer(config: ServerConfig, router: ServerDelegate, options: ServerOptions?) -> Int? {
        // Servers with options (live for duration of one test)
        if options != nil {
            let server = doStartServer(config: config, router: router, options: options)
            return server?.port
        }
        // Generic servers that can be long-lived (for a whole test class)
        if config.useSSL {
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

        let server = doStartServer(config: config, router: router, options: nil)

        if config.useSSL {
            KituraTest.httpsInetServer = server
        } else {
            KituraTest.httpInetServer = server
        }
        return server?.port
    }

    // Start a server. If a non-nil `options` is provided, then the server is stored
    // as the `serverWithOptions` property, and will be shut down at the end of the test.
    private func doStartUnixSocketServer(config: ServerConfig, router: ServerDelegate, options: ServerOptions?) -> HTTPServer? {
        let server = HTTP.createServer()
        server.delegate = router

        if config.useSSL {
            server.sslConfig = KituraTest.sslConfig.config
        }

        if let options = options {
            server.options = options
            serverWithOptions = server
        }

        // Create a temporary path for Unix domain socket
        let socketPath = uniqueTemporaryFilePath()
        do {
            try server.listen(unixDomainSocketPath: socketPath)
            return server
        } catch {
            XCTFail("Error starting server: \(error)")
            return nil
        }
    }

    // Start a server on a unix domain socket. If nil `options` are specified, this is
    // a generic server that can be reused between tests, and will be stored as a
    // static property.
    private func startUnixSocketServer(config: ServerConfig, router: ServerDelegate, options: ServerOptions?) -> String? {
        // Servers with options (live for duration of one test)
        if (options != nil) {
            let server = doStartUnixSocketServer(config: config, router: router, options: options)
            return server?.unixDomainSocketPath
        }
        // Generic servers that can be long-lived (for a whole test class)
        if config.useSSL {
            if let server = KituraTest.httpsUnixServer {
                server.delegate = router
                guard let listenPath = server.unixDomainSocketPath else {
                    XCTFail("Unix socket path missing")
                    return nil
                }
                return listenPath
            }
        } else {
            if let server = KituraTest.httpUnixServer {
                server.delegate = router
                guard let listenPath = server.unixDomainSocketPath else {
                    XCTFail("Unix socket path missing")
                    return nil
                }
                return listenPath
            }
        }

        let server = doStartUnixSocketServer(config: config, router: router, options: nil)

        if config.useSSL {
            KituraTest.httpsUnixServer = server
        } else {
            KituraTest.httpUnixServer = server
        }
        return server?.unixDomainSocketPath
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

//        // Clean up temporary file for Unix domain socket
//        if let socketFilePath = socketFilePath {
//            removeTemporaryFilePath(socketFilePath)
//        }
    }

    func performRequest(_ serverContext: ServerContext, _ method: String, path: String, followRedirects: Bool = true,
                        callback: @escaping ClientRequest.Callback, headers: [String: String]? = nil,
                        requestModifier: ((ClientRequest) -> Void)? = nil) {

        var allHeaders = [String: String]()
        if  let headers = headers {
            for  (headerName, headerValue) in headers {
                allHeaders[headerName] = headerValue
            }
        }
        if allHeaders["Content-Type"] == nil {
            allHeaders["Content-Type"] = "text/plain"
        }

        let schema = serverContext.useSSL ? "https" : "http"
        var options: [ClientRequest.Options] =
            [.method(method), .schema(schema), .hostname("localhost"), .path(path), .headers(allHeaders)]
        if serverContext.useSSL {
            options.append(.disableSSLVerification)
        }
        if !followRedirects {
            options.append(.maxRedirects(0))
        }
        let req: ClientRequest
        switch serverContext.listenerType {
        case .unix(let socketPath):
            req = HTTP.request(options, unixDomainSocketPath: socketPath, callback: callback)
        case .inet(let port):
            options.append(.port(UInt16(port).toInt16()))
            req = HTTP.request(options, callback: callback)
        }

        if let requestModifier = requestModifier {
            requestModifier(req)
        }
        req.end(close: true)
    }

    /*
    func expectation(line: Int, index: Int) -> XCTestExpectation {
        return self.expectation(description: "\(type(of: self)):\(line)[\(index)](ssl:\(useSSL))")
    }
     */

    // Generates a unique temporary file path suitable for use as a Unix domain socket.
    // path is returned within /tmp
    func uniqueTemporaryFilePath() -> String {
        let temporaryDirectory = "/tmp"
        return temporaryDirectory + "/KituraTest." + String(ProcessInfo.processInfo.globallyUniqueString.prefix(20) + "." + UUID().uuidString)
    }

    // Delete a temporary file path.
    func removeTemporaryFilePath(_ path: String, ignoreIfRemoved: Bool=false) {
        let fileURL = URL(fileURLWithPath: path)
        let fm = FileManager.default
        do {
            try fm.removeItem(at: fileURL)
        } catch {
            if ignoreIfRemoved {
                if !fm.fileExists(atPath: path) {
                    return
                }
            }
            XCTFail("Unable to remove \(path): \(error.localizedDescription)")
        }
    }

    func failIfFileExists(_ path: String) {
        let fm = FileManager.default
        if fm.fileExists(atPath: path) {
            XCTFail("File should not exist at: \(path)")
        }
    }
}

fileprivate extension UInt16 {
    func toInt16() -> Int16 {
        return Int16(bitPattern: self)
    }
}
