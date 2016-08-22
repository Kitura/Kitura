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

@testable import Kitura
@testable import KituraNet
@testable import KituraSys

import Foundation

protocol KituraTest {
    func expectation(_ index: Int) -> XCTestExpectation
    func waitExpectation(timeout t: TimeInterval, handler: XCWaitCompletionHandler?)
}

extension KituraTest {

    func doSetUp() {
        PrintLogger.use()
    }
    
    func doTearDown() {
        // sleep(10)
    }

    func performServerTest(_ router: ServerDelegate, asyncTasks: (expectation: XCTestExpectation) -> Void...) {
        Kitura.addHTTPServer(onPort: 8090, with: router)
        Kitura.start()
        let requestQueue = Queue(type: .serial)

        for (index, asyncTask) in asyncTasks.enumerated() {
            let expectation = self.expectation(index)
            requestQueue.enqueueAsynchronously {
                asyncTask(expectation: expectation)
            }
        }

        waitExpectation(timeout: 10) { error in
                // blocks test until request completes
                Kitura.stop()
                XCTAssertNil(error);
        }
    }

    func performRequest(_ method: String, path: String, callback: ClientRequest.Callback, headers: [String: String]? = nil, requestModifier: ((ClientRequest) -> Void)? = nil) {
        var allHeaders = [String: String]()
        if  let headers = headers  {
            for  (headerName, headerValue) in headers  {
                allHeaders[headerName] = headerValue
            }
        }
        allHeaders["Content-Type"] = "text/plain"
        let req = HTTP.request([.method(method), .hostname("localhost"), .port(8090), .path(path), .headers(allHeaders)], callback: callback)
        if let requestModifier = requestModifier {
            requestModifier(req)
        }
        req.end()
    }
}

extension XCTestCase: KituraTest {
    func expectation(_ index: Int) -> XCTestExpectation {
        let expectationDescription = "\(self.dynamicType)-\(index)"
        return self.expectation(description: expectationDescription)
    }

    func waitExpectation(timeout t: TimeInterval, handler: XCWaitCompletionHandler?) {
        self.waitForExpectations(timeout: t, handler: handler)
    }
}
