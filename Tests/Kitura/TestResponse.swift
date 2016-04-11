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

class TestResponse : XCTestCase, KituraTest {

    static var allTests : [(String, TestResponse -> () throws -> Void)] {
        return [
            ("testSimpleResponse", testSimpleResponse),
            ("testPostRequest", testPostRequest),
            ("testParameter", testParameter),
            ("testRedirect", testRedirect),
            ("testErrorHandler", testErrorHandler),
            ("testHeaderModifiers", testHeaderModifiers),
            ("testRouteFunc", testRouteFunc)
        ]
    }

    override func tearDown() {
        doTearDown()
    }

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
                req.write(from: "plover\n")
                req.write(from: "xyzzy\n")
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
#if os(Linux)
                    XCTAssertNotNil(body!.rangeOfString("ibm"),"response does not contain IBM")
#else
                    XCTAssertNotNil(body!.range(of: "ibm"),"response does not contain IBM")
#endif 
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
                    let errorDescription = "Internal Server Error"
                    XCTAssertEqual(body!,"Caught the error: \(errorDescription)")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        }
    }

    func testRouteFunc() {
        performServerTest(router, asyncTasks: {
            self.performRequest("get", path: "/route", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"get 1\nget 2\n")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        }, {
            self.performRequest("post", path: "/route", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"post received")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        })
    }

    func testHeaderModifiers() {

        router.get("/headerTest") { _, response, next in

            response.append("Content-Type", value: "text/html")
            XCTAssertEqual(response.getHeader("Content-Type"), "text/html")

            response.append("Content-Type", value: "text/plain; charset=utf-8")
            XCTAssertNil(response.getHeader("Content-Type"))
            XCTAssertEqual(response.getHeaders("Content-Type")!, ["text/html", "text/plain; charset=utf-8"])

            response.removeHeader("Content-Type")
            XCTAssertNil(response.getHeader("Content-Type"))

            response.append("Content-Type", value: ["text/plain", "image/png"])
            XCTAssertEqual(response.getHeaders("Content-Type")!, ["text/plain", "image/png"])

            response.append("Content-Type", value: ["text/html", "image/jpeg"])
            XCTAssertEqual(response.getHeaders("Content-Type")!, ["text/plain", "image/png", "text/html", "image/jpeg"])

            response.append("Content-Type", value: "charset=UTF-8")
            XCTAssertEqual(response.getHeaders("Content-Type")!, ["text/plain", "image/png", "text/html", "image/jpeg", "charset=UTF-8"])

            response.removeHeader("Content-Type")

            response.append("Content-Type", value: ["text/plain"])
            XCTAssertEqual(response.getHeader("Content-Type"), "text/plain")

            response.append("Content-Type", value: ["image/png", "text/html"])
            XCTAssertEqual(response.getHeaders("Content-Type")!, ["text/plain", "image/png", "text/html"])

            do {
                try response.status(HttpStatusCode.OK).end("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n")
            }
            catch {}
            next()
        }

        performServerTest(router) {
            self.performRequest("get", path: "/headerTest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
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
            response.error = Error(message: "Internal Server Error")
            next()
        }

        router.route("/route")
        .get { _, response, next in
            response.status(HttpStatusCode.OK).send("get 1\n")
            next()
        }
        .post {_, response, next in
            response.status(HttpStatusCode.OK).send("post received")
            next()
        }
        .get { _, response, next in
            response.status(HttpStatusCode.OK).send("get 2\n")
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
                response.error = Error(message: "Failed to parse request body")
            }

            next()
        }

        router.error { request, response, next in
            response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
            do {
                try response.send("Caught the error: \(response.error!.message)").end()
            }
            catch {}
            next()
        }

	return router
    }
}

