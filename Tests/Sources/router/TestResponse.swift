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

import Foundation
import XCTest

@testable import KituraRouter
@testable import KituraNet
@testable import KituraSys
@testable import HeliumLogger

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

#if os(Linux)
    extension TestResponse : XCTestCaseProvider {
        var allTests : [(String, () throws -> Void)] {
            return [
                ("testSimpleResponse", testSimpleResponse),
                ("testPostRequest", testPostRequest),
                ("testParameter", testParameter),
                ("testRedirect", testRedirect)
            ]
        }
    }
#endif

class TestResponse : XCTestCase {

    let serverTask = NSTask()
    let serverQueue = Queue(type: QueueType.PARALLEL)
    let router = TestResponse.setupRouter()

    override func tearDown() {
        sleep(10)
    }

    func testSimpleResponse() {
    	let server = setupServer(8090, delegate: router)

        let requestQueue = Queue(type: QueueType.SERIAL)
        requestQueue.queueAsync {
                let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/qwer"), .Headers(headers)]) {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                    XCTAssertNotNil(response!.headers["Date"], "There was No Date header in the response")
                    //XCTAssertEqual(response!.method, "GET", "The request wasn't recognized as a get")
                    do {
                        let body = try response!.readString()
                        XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n")
                    }
                    catch{
                        XCTFail("No respose body")
                    }
                }
                req.end()
            }
        requestQueue.queueSync {
                // blocks test until request completes
		        server.stop()
            }
    }

    func testPostRequest() {
    	let server = setupServer(8090, delegate: router)

        let requestQueue = Queue(type: QueueType.SERIAL)
        requestQueue.queueAsync {
                let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("post"), .Hostname("localhost"), .Port(8090), .Path("/bodytest"), .Headers(headers)]) {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    //XCTAssertEqual(response!.method, "POST", "The request wasn't recognized as a post")
                    XCTAssertNotNil(response!.headers["Date"], "There was No Date header in the response")
                    do {
                        let body = try response!.readString()
                        XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Received text body: </b>plover\nxyzzy\n</body></html>\n\n")
                    }
                    catch{
                        XCTFail("No respose body")
                    }
                }
                req.writeString("plover\n")
                req.writeString("xyzzy\n")
                req.end()
            }
        requestQueue.queueSync {
                // blocks test until request completes
		        server.stop()
            }
    }

    func testParameter() {
    	let server = setupServer(8090, delegate: router)

        let requestQueue = Queue(type: QueueType.SERIAL)
        requestQueue.queueAsync {
                let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/zxcv/test?q=test2"), .Headers(headers)]) {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    do {
                        let body = try response!.readString()
                        XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Received /zxcv</b><p><p>p1=test<p><p>q=test2<p><p>u1=Ploni Almoni</body></html>\n\n")
                    }
                    catch{
                        XCTFail("No respose body")
                    }
                }
                req.end()
            }
        requestQueue.queueSync {
                // blocks test until request completes
		        server.stop()
            }
    }

    func testRedirect() {
    	let server = setupServer(8090, delegate: router)

        let requestQueue = Queue(type: QueueType.SERIAL)
        requestQueue.queueAsync {
                let headers = ["Content-Type": "text/plain"]
                let req = Http.request([.Method("get"), .Hostname("localhost"), .Port(8090), .Path("/redir"), .Headers(headers)]) {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    do {
                        let body = try response!.readString()
                        XCTAssertNotNil(body!.rangeOfString("ibm"),"response does not contain IBM")
                    }
                    catch{
                        XCTFail("No respose body")
                    }
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
        // the same router definition is used for all these test cases
        router.use("/zxcv/*", middleware: EchoTest())
        router.all("/zxcv/:p1") { request, _, next in
            request.userInfo["u1"] = "Ploni Almoni".bridge()
            next()
        }

        router.get("/qwer") { _, response, next in
            response.setHeader("Content-Type", value: "text/html; charset=utf-8")
            do {
                try response.status(HttpStatusCode.OK).end("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n")
            }
            catch {}
            next()
        }


        router.get("/zxcv/:p1") { request, response, next in
            response.setHeader("Content-Type", value: "text/html; charset=utf-8")
            let p1 = request.params["p1"] ?? "(nil)"
            let q = request.queryParams["q"] ?? "(nil)"
            let u1 = request.userInfo["u1"] as? NSString ?? "(nil)"
            do {
                try response.status(HttpStatusCode.OK).send("<!DOCTYPE html><html><body><b>Received /zxcv</b><p><p>p1=\(p1)<p><p>q=\(q)<p><p>u1=\(u1)</body></html>\n\n").end()
            }
            catch {}
            next()
        }
    
        router.get("/redir") { _, response, next in
            do {
                try response.redirect("http://www.ibm.com")
            }
            catch {}

            next()
        }


        router.use("/bodytest", middleware: BodyParser())
                
        router.post("/bodytest") { request, response, next in
            if let body = request.body?.asUrlEncoded() {
                response.setHeader("Content-Type", value: "text/html; charset=utf-8")
                do {
                    try response.status(HttpStatusCode.OK).end("<!DOCTYPE html><html><body><b>Received URL encoded body</b><br> \(body) </body></html>\n\n")
                }
                catch {}
            }
            else if let text = request.body?.asText() {
                response.setHeader("Content-Type", value: "text/html; charset=utf-8")
                do {
                    try response.status(HttpStatusCode.OK).end("<!DOCTYPE html><html><body><b>Received text body: </b>\(text)</body></html>\n\n")
                }
                catch {}
            }
            else {
                response.error = NSError(domain: "RouterTestDomain", code: 1, userInfo: [NSLocalizedDescriptionKey:"Failed to parse request body"])
            }

            next()
        }
	return router
    }
}

class EchoTest: RouterMiddleware {
    func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        for  (key, value) in request.headers {
            print("EchoTest. key=\(key). value=\(value).")
        }
        next()
    }
}

