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

#if os(Linux)
    extension TestMultiplicity : XCTestCaseProvider {
        var allTests : [(String, () throws -> Void)] {
            return [
                ("testPlus", testPlus),
                ("testStar", testStar),
                ("testQuestion", testQuestion),
                ("testCombined", testCombined)
            ]
        }
    }
#endif

class TestMultiplicity : XCTestCase {

    let serverTask = NSTask()
    let serverQueue = Queue(type: QueueType.PARALLEL)
    let router = TestMultiplicity.setupRouter()

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

    func testPlus() {
		let server = setupServer(8090, delegate: router)

        let requestQueue = Queue(type: QueueType.SERIAL)
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/1/plus"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Plus route did not match single path request")
                }
                req.end()
        }
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/1/plus/plus"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Plus route did not match multiple path request")
                }
                req.end()
        }
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/1"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.NOT_FOUND, "Plus route did not miss empty path request")
                }
                req.end()
        }

        requestQueue.queueSync {
                // blocks test until request completes
		        server.stop()
            }
	}

	func testStar() {
		let server = setupServer(8090, delegate: router)

        let requestQueue = Queue(type: QueueType.SERIAL)
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/2/star"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Star route did not match single path request")
                }
                req.end()
        }
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/2/star/star"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Star route did not match multiple path request")
                }
                req.end()
        }
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/2"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Star route did not match empty path request")
                }
                req.end()
        }

        requestQueue.queueSync {
                // blocks test until request completes
		        server.stop()
            }
	}

	func testQuestion() {
		let server = setupServer(8090, delegate: router)

        let requestQueue = Queue(type: QueueType.SERIAL)
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/3/question"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Question route did not match single path request")
                }
                req.end()
        }
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/3/question/question"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.NOT_FOUND, "Question route did not miss multiple path request")
                }
                req.end()
        }
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/3"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Question route did not match empty path request")
                }
                req.end()
        }

        requestQueue.queueSync {
                // blocks test until request completes
		        server.stop()
            }
	}

	func testCombined() {
		let server = setupServer(8090, delegate: router)

        let requestQueue = Queue(type: QueueType.SERIAL)
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/4/question/plus"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Complex route did not match dropped star ending")
                }
                req.end()
        }
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/4/plus/plus/star"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Complex route did not match dropped beginning with extra middle")
                }
                req.end()
        }
        requestQueue.queueAsync {
        	let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/4/question/plusssssss/plus/pluss/star/star"), .Headers(headers)]) {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Complex route did not match internal extra plus signs with multiple extras")
                }
                req.end()
        }

        requestQueue.queueSync {
                // blocks test until request completes
		        server.stop()
            }
	}

	func setupServer(port: Int, delegate: HttpServerDelegate) -> HttpServer {
	return HttpServer.listen(port, delegate: delegate, 
		     		       notOnMainQueue:true)
    }

    static func setupRouter() -> Router {
    	let router = Router()

    	router.get("/1/(plus)+") {_, response, next in 
    		do {
    			try response.status(HttpStatusCode.OK).end()
    		}
    		catch {}

    		next()	
    	}

    	router.get("/2/(star)*") {_, response, next in
    		do {
    			try response.status(HttpStatusCode.OK).end()
    		}
    		catch {}
    		next()
    	}

    	router.get("/3/(question)?") {_, response, next in
    		do {
    			try response.status(HttpStatusCode.OK).end()
    		}
    		catch {}

    		next()
    	}

    	router.get ("/4/(question)?/(plus+)+/(star)*") {_, response, next in
    		do {
    			try response.status(HttpStatusCode.OK).end()
    		}
    		catch {}

    		next()
    	}

    	return router
    }
}
