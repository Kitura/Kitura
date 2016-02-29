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

import KituraRouter
import KituraNet
import KituraSys
import HeliumLogger

import Foundation

import XCTest

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif


class TestErrors : XCTestCase {
    
    let router = Router()

    var allTests : [(String, () throws -> Void)] {
        return [
            ("testInvalidMethod", testInvalidMethod),
            ("testInvalidEndpoint", testInvalidEndpoint),
            ("testInvalidHeader", testInvalidHeader)
        ]
    }

    var serverQueue = Queue(type: QueueType.PARALLEL)

    override func tearDown() {
        sleep(10)
    }

    func setupServer(port: Int, delegate: HttpServerDelegate) -> HttpServer {
	return HttpServer.listen(port, delegate: delegate, 
		     		       notOnMainQueue:true)
    }
    
    func testInvalidMethod() {
    	let server = setupServer(8090, delegate: router)

        let requestQueue = Queue(type: QueueType.SERIAL)
        requestQueue.queueAsync {
                let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("invalid"), .Hostname("localhost"), .Port(8090), .Path("/qwer"), .Headers(headers)]) {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response!.statusCode, HttpStatusCode.BAD_REQUEST, "HTTP Status code was \(response!.statusCode)")
                }
                req.end()
            }
        requestQueue.queueSync {
                // blocks test until request completes
		        server.stop()
            }
    }

    func testInvalidEndpoint() {
        let server = setupServer(8090, delegate: router)
        
        // the sample from .build/debug/sample must be running

        let requestQueue = Queue(type: QueueType.SERIAL)
        requestQueue.queueAsync {
                let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/notreal"), .Headers(headers)]) {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response!.statusCode, HttpStatusCode.NOT_FOUND, "HTTP Status code was \(response!.statusCode)")
                }
                req.end()
            }
        requestQueue.queueSync {
                // blocks test until request completes
		        server.stop()
            }
    }

    func testInvalidHeader() {
        let server = setupServer(8090, delegate: router)

        let requestQueue = Queue(type: QueueType.SERIAL)
        requestQueue.queueAsync {
                let headers = ["garbage" : "dfsfdsf"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/qwer"), .Headers(headers)]) {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    // should this be ok?
                }
                req.end()
            }
        requestQueue.queueSync {
                // blocks test until request completes
                server.stop()
        }
    }

}
