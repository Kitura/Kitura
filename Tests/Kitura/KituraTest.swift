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

@testable import KituraNet
@testable import KituraSys

import Foundation

protocol KituraTest {
    func expectation(index index: Int) -> XCTestExpectation
    func waitExpectation(timeout t: NSTimeInterval, handler: XCWaitCompletionHandler?)
}

extension KituraTest {

   func doTearDown() {
  //       sleep(10)
    }

    func performServerTest(router: HttpServerDelegate, asyncTasks: (expectation: XCTestExpectation) -> Void...) {
        let server = setupServer(8090, delegate: router)
        let requestQueue = Queue(type: QueueType.SERIAL)

        for (index, asyncTask) in asyncTasks.enumerated() {
            let expectation = self.expectation(index: index)
            requestQueue.queueAsync {
                asyncTask(expectation: expectation)
            }
        }

        waitExpectation(timeout: 10) { error in
                // blocks test until request completes
                server.stop()
                XCTAssertNil(error);
        }
    }

    func performRequest(method: String, path: String, callback: ClientRequestCallback, headers: [String: String]? = nil, requestModifier: ((ClientRequest) -> Void)? = nil) {
        var allHeaders = [String: String]()
        if  let headers = headers  {
            for  (headerName, headerValue) in headers  {
                allHeaders[headerName] = headerValue
            }
        }
        allHeaders["Content-Type"] = "text/plain"
        let req = Http.request([.Method(method), .Hostname("localhost"), .Port(8090), .Path(path), .Headers(allHeaders)], callback: callback)
        if let requestModifier = requestModifier {
            requestModifier(req)
        }
        req.end()
    }

    private func setupServer(port: Int, delegate: HttpServerDelegate) -> HttpServer {
        return HttpServer.listen(port, delegate: delegate,
                           notOnMainQueue:true)
    }
}

extension XCTestCase: KituraTest {
    func expectation(index index: Int) -> XCTestExpectation {
        let expectationDescription = "\(self.dynamicType)-\(index)"
        #if os(Linux)
        return self.expectationWithDescription(expectationDescription)
        #else
        return self.expectation(withDescription: expectationDescription)
        #endif
    }

    func waitExpectation(timeout t: NSTimeInterval, handler: XCWaitCompletionHandler?) {
        #if os(Linux)
        self.waitForExpectationsWithTimeout(t, handler: handler)
        #else
        self.waitForExpectations(withTimeout: t, handler: handler)
        #endif
    }
}
