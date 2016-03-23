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

@testable import Kitura
@testable import KituraNet

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

class TestResponse : KituraTest {
    #if os(Linux)
        override var allTests : [(String, () throws -> Void)] {
            return [
                ("testSimpleResponse", testSimpleResponse),
                ("testPostRequest", testPostRequest),
                ("testParameter", testParameter),
                ("testRedirect", testRedirect),
                ("testErrorHandler", testErrorHandler)
            ]
        }
    #endif

    let router = TestResponse.setupRouter()

    func testSimpleResponse() {
    	performServerTest(router) {
            self.performRequest("get", path:"/qwer", callback: {response in
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
            })
        }
    }

    func testPostRequest() {
    	performServerTest(router) {
            self.performRequest("post", path: "/bodytest", callback: {response in
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
            }) {req in
                req.writeString("plover\n")
                req.writeString("xyzzy\n")
            }
        }
    }

    func testParameter() {
    	performServerTest(router) {
            self.performRequest("get", path: "/zxcv/test?q=test2", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Received /zxcv</b><p><p>p1=test<p><p>q=test2<p><p>u1=Ploni Almoni</body></html>\n\n")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        }
    }

    func testRedirect() {
        performServerTest(router) {
            self.performRequest("get", path: "/redir", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response!.readString()
                    XCTAssertNotNil(body!.rangeOfString("ibm"),"response does not contain IBM")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        }
    }

    func testErrorHandler() {
        performServerTest(router) {
            self.performRequest("get", path: "/error", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response!.readString()
                    #if os(Linux)
                    let errorDescription = "The operation could not be completed"
                    #else
                    let errorDescription = "The operation couldn’t be completed. (RouterTestDomain error 1.)"
                    #endif
                    XCTAssertEqual(body!,"Caught the error: \(errorDescription)")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        }
    }

    static func setupRouter() -> Router {
        let router = Router()
        // the same router definition is used for all these test cases
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

        // Error handling example
        router.get("/error") { _, response, next in
            response.status(HttpStatusCode.INTERNAL_SERVER_ERROR)
            response.error = NSError(domain: "RouterTestDomain", code: 1, userInfo: [:])
            next()
        }


        router.all("/bodytest", middleware: BodyParser())

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

        router.error { request, response, next in
            response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
            do {
                try response.send("Caught the error: \(response.error!.localizedDescription)").end()
            }
            catch {}
            next()
        }

	return router
    }
}

