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

#if os(Linux)
    typealias TimeIntervalType = NSTimeInterval
#else
    typealias TimeIntervalType = TimeInterval
#endif

protocol KituraTest {
    func expectation(_ index: Int) -> XCTestExpectation
    func waitExpectation(timeout t: TimeIntervalType, handler: XCWaitCompletionHandler?)
}

extension KituraTest {

   func doTearDown() {
  //       sleep(10)
    }

    func performServerTest(_ router: HTTPServerDelegate, asyncTasks: (expectation: XCTestExpectation) -> Void...) {
        let server = setupServer(port: 8090, delegate: router)
        let requestQueue = Queue(type: .serial)

        for (index, asyncTask) in asyncTasks.enumerated() {
            let expectation = self.expectation(index)
            requestQueue.enqueueAsynchronously {
                asyncTask(expectation: expectation)
            }
        }

        waitExpectation(timeout: 10) { error in
                // blocks test until request completes
                server.stop()
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

    private func setupServer(port: Int, delegate: HTTPServerDelegate) -> HTTPServer {
        return HTTPServer.listen(port: port, delegate: delegate,
                           notOnMainQueue:true)
    }
}

extension XCTestCase: KituraTest {
    func expectation(_ index: Int) -> XCTestExpectation {
        let expectationDescription = "\(self.dynamicType)-\(index)"
        return self.expectation(withDescription: expectationDescription)
    }

    func waitExpectation(timeout t: TimeIntervalType, handler: XCWaitCompletionHandler?) {
        self.waitForExpectations(withTimeout: t, handler: handler)
    }
}
