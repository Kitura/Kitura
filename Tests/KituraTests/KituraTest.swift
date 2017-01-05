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

protocol KituraTest {
    func expectation(line: Int, index: Int) -> XCTestExpectation
    // swiftlint:disable variable_name
    func waitExpectation(timeout t: TimeInterval, handler: XCWaitCompletionHandler?)
    // swiftlint:enable variable_name
}

extension KituraTest {

    func doSetUp() {
        PrintLogger.use()
    }

    func doTearDown() {
    }

    func performServerTest(_ router: ServerDelegate, line: Int = #line,
                           asyncTasks: @escaping (XCTestExpectation) -> Void...) {
        let port = 8090
        let server = Kitura.addHTTPServer(onPort: port, with: router)
        defer {
            Kitura.stop() // make sure to remove server from Kitura static list
        }

        var failed = false
        server.failed { error in
            failed = true
            XCTFail("Error starting server on port \(port): \(error)")
        }

        Kitura.start()

        let requestQueue = DispatchQueue(label: "Request queue")
        if !failed {
            for (index, asyncTask) in asyncTasks.enumerated() {
                let expectation = self.expectation(line: line, index: index)
                requestQueue.async() {
                    asyncTask(expectation)
                }
            }

            waitExpectation(timeout: 10) { error in
                // wait for timeout or for all created expectations to be fulfilled
                XCTAssertNil(error)
            }
        }
    }

    func performRequest(_ method: String, path: String, callback: @escaping ClientRequest.Callback, headers: [String: String]? = nil, requestModifier: ((ClientRequest) -> Void)? = nil) {
        var allHeaders = [String: String]()
        if  let headers = headers {
            for  (headerName, headerValue) in headers {
                allHeaders[headerName] = headerValue
            }
        }
        if allHeaders["Content-Type"] == nil {
            allHeaders["Content-Type"] = "text/plain"
        }
        let options: [ClientRequest.Options] =
                [.method(method), .hostname("localhost"), .port(8090), .path(path), .headers(allHeaders)]
        let req = HTTP.request(options, callback: callback)
        if let requestModifier = requestModifier {
            requestModifier(req)
        }
        req.end()
    }
}

extension XCTestCase: KituraTest {
    func expectation(line: Int, index: Int) -> XCTestExpectation {
        return self.expectation(description: "\(type(of: self)):\(line)[\(index)]")
    }

    // swiftlint:disable variable_name
    func waitExpectation(timeout t: TimeInterval, handler: XCWaitCompletionHandler?) {
    // swiftlint:enable variable_name
        self.waitForExpectations(timeout: t, handler: handler)
    }
}
