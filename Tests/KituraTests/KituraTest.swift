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
import Kitura

@testable import KituraNet

import Foundation
import Dispatch

class KituraTest: XCTestCase {

    static let useSSLDefault = true
    static let portDefault = 8090

    static private(set) var server: HTTPServer? = nil
    static private(set) var port = portDefault
    static private(set) var useSSL = useSSLDefault

    static let sslConfig: SSLConfig = {
        let path = #file
        let sslConfigDir: String
        if let range = path.range(of: "/", options: .backwards) {
            sslConfigDir = path.substring(to: range.lowerBound) + "/SSLConfig/"
        } else {
            sslConfigDir = "./SSLConfig/"
        }

        #if os(Linux)
            let certificatePath = sslConfigDir + "certificate.pem"
            let keyPath = sslConfigDir + "key.pem"
            return SSLConfig(withCACertificateDirectory: nil, usingCertificateFile: certificatePath,
                             withKeyFile: keyPath, usingSelfSignedCerts: true)
        #else
            let chainFilePath = sslConfigDir + "certificateChain.pfx"
            return SSLConfig(withChainFilePath: chainFilePath, withPassword: "kitura",
                             usingSelfSignedCerts: true)
        #endif
    }()

    func doSetUp() {
        PrintLogger.use(colored: true)
    }

    func doTearDown() {
    }

    private static func startServer(router: ServerDelegate, port: Int, useSSL: Bool) {
        if KituraTest.server != nil {
            if port == KituraTest.port && useSSL == KituraTest.useSSL {
                KituraTest.server!.delegate = router
                return
            } else {
                stopServer()
            }
        }

        KituraTest.port = port
        KituraTest.useSSL = useSSL

        let sslConfig = useSSL ? KituraTest.sslConfig : nil
        let server = Kitura.addHTTPServer(onPort: port, with: router, withSSL: sslConfig)

        var failed = false
        server.failed { error in
            failed = true
            XCTFail("Error starting server on port \(port): \(error)")
        }

        Kitura.start()

        if !failed {
            KituraTest.server = server
        }
    }

    static func stopServer() {
        Kitura.stop()
        KituraTest.server = nil
    }

    func performServerTest(_ router: ServerDelegate, port: Int = portDefault, useSSL: Bool = useSSLDefault,
                           line: Int = #line, asyncTasks: @escaping (XCTestExpectation) -> Void...) {

        KituraTest.startServer(router: router, port: port, useSSL: useSSL)
        guard KituraTest.server != nil else {
            return
        }

        let requestQueue = DispatchQueue(label: "Request queue")
        for (index, asyncTask) in asyncTasks.enumerated() {
            let expectation = self.expectation(line: line, index: index)
            requestQueue.async() {
                asyncTask(expectation)
            }
        }

        // wait for timeout or for all created expectations to be fulfilled
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }

    func performRequest(_ method: String, path: String, callback: @escaping ClientRequest.Callback,
                        headers: [String: String]? = nil, requestModifier: ((ClientRequest) -> Void)? = nil) {

        var allHeaders = [String: String]()
        if  let headers = headers {
            for  (headerName, headerValue) in headers {
                allHeaders[headerName] = headerValue
            }
        }
        if allHeaders["Content-Type"] == nil {
            allHeaders["Content-Type"] = "text/plain"
        }

        let schema = KituraTest.useSSL ? "https" : "http"
        var options: [ClientRequest.Options] =
                [.method(method), .schema(schema), .hostname("localhost"), .port(Int16(KituraTest.port)), .path(path),
                 .headers(allHeaders)]
        if KituraTest.useSSL {
            options.append(.disableSSLVerification)
        }

        let req = HTTP.request(options, callback: callback)
        if let requestModifier = requestModifier {
            requestModifier(req)
        }
        req.end(close: true)
    }

    func expectation(line: Int, index: Int) -> XCTestExpectation {
        return self.expectation(description: "\(type(of: self)):\(line)[\(index)]")
    }
}
