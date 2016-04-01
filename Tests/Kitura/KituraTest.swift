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

class KituraTest : XCTestCase {

    #if os(Linux)
        var allTests : [(String, () throws -> Void)] {
            return []
        }
    #endif

   override func tearDown() {
       doTearDown()
   }

    private func doTearDown() {
        sleep(10)
    }

    func performServerTest(router: HttpServerDelegate, asyncTasks: () -> Void...) {
        let server = setupServer(8090, delegate: router)
        let requestQueue = Queue(type: QueueType.SERIAL)

        for asyncTask in asyncTasks {
            requestQueue.queueAsync(asyncTask)
        }

        requestQueue.queueSync {
                // blocks test until request completes
                server.stop()
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
