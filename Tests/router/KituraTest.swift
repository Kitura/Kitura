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

     #if os(Linux)
       func tearDown() {
           doTearDown()
       }
    #else
       override func tearDown() {
           doTearDown()
       }
    #endif

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

    func performRequest(method: String, path: String, callback: ClientRequestCallback) {
        let headers = ["Content-Type": "text/plain"]
        let req = Http.request([.Method(method), .Hostname("localhost"), .Port(8090), .Path(path), .Headers(headers)], callback: callback)
        req.end()
    }

    private func setupServer(port: Int, delegate: HttpServerDelegate) -> HttpServer {
        return HttpServer.listen(port, delegate: delegate, 
                           notOnMainQueue:true)
    }
}
