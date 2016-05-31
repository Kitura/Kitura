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

class TestResponse : XCTestCase {

    static var allTests : [(String, TestResponse -> () throws -> Void)] {
        return [
            ("testSimpleResponse", testSimpleResponse),
            ("testPostRequest", testPostRequest),
            ("testPostRequestUrlEncoded", testPostRequestUrlEncoded),
            ("testMultipartFormParsing", testMultipartFormParsing),
            ("testParameter", testParameter),
            ("testRedirect", testRedirect),
            ("testErrorHandler", testErrorHandler),
            ("testHeaderModifiers", testHeaderModifiers),
            ("testRouteFunc", testRouteFunc),
            ("testAcceptTypes", testAcceptTypes),
            ("testFormat", testFormat),
            ("testLink", testLink),
            ("testSubdomains", testSubdomains)
        ]
    }

    override func tearDown() {
        doTearDown()
    }

    let router = TestResponse.setupRouter()

    func testSimpleResponse() {
    	performServerTest(router) { expectation in
            self.performRequest("get", path:"/qwer", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                XCTAssertNotNil(response!.headers["Date"], "There was No Date header in the response")
                //XCTAssertEqual(response!.method, "GET", "The request wasn't recognized as a get")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }
    }

    func testPostRequest() {
    	performServerTest(router) { expectation in
            self.performRequest("post", path: "/bodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                //XCTAssertEqual(response!.method, "POST", "The request wasn't recognized as a post")
                XCTAssertNotNil(response!.headers["Date"], "There was No Date header in the response")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Received text body: </b>plover\nxyzzy\n</body></html>\n\n")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
            }) {req in
                req.write(from: "plover\n")
                req.write(from: "xyzzy\n")
            }
        }
    }
    
    func testPostRequestUrlEncoded() {
        performServerTest(router) { expectation in
            self.performRequest("post", path: "/bodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertNotNil(response!.headers["Date"], "There was No Date header in the response")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Received URL encoded body</b><br> [\"swift\": \"rocks\"] </body></html>\n\n")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
            }) {req in
                req.headers["Content-Type"] = "application/x-www-form-urlencoded"
                req.write(from: "swift=rocks")
            }
        }
        // repeat the same test with a Content-Type parameter of charset=UTF-8
        performServerTest(router) { expectation in
            self.performRequest("post", path: "/bodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertNotNil(response!.headers["Date"], "There was No Date header in the response")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Received URL encoded body</b><br> [\"swift\": \"rocks\"] </body></html>\n\n")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
            }) {req in
                req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
                req.write(from: "swift=rocks")
            }
        }
    }

    func testMultipartFormParsing() {
        performServerTest(router) { expectation in
            self.performRequest("post", path: "/multibodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!, "text text(\"text default\") file1 text(\"Content of a.txt.\") file2 text(\"<!DOCTYPE html><title>Content of a.html.</title>\") ")
                }
                catch {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            }) {req in
                req.headers["Content-Type"] = "multipart/form-data; boundary=---------------------------9051914041544843365972754266"
                req.write(from: "-----------------------------9051914041544843365972754266\r\n" +
                    "Content-Disposition: form-data; name=\"text\"\r\n\r\n" +
                    "text default\r\n" +
                    "-----------------------------9051914041544843365972754266\r\n" +
                    "Content-Disposition: form-data; name=\"file1\"; filename=\"a.txt\"\r\n" +
                    "Content-Type: text/plain\r\n\r\n" +
                    "Content of a.txt.\r\n\r\n" +
                    "-----------------------------9051914041544843365972754266\r\n" +
                    "Content-Disposition: form-data; name=\"file2\"; filename=\"a.html\"\r\n" +
                    "Content-Type: text/html\r\n\r\n" +
                    "<!DOCTYPE html><title>Content of a.html.</title>\r\n\r\n" +
                    "-----------------------------9051914041544843365972754266--")
            }
        }
    }

    func testParameter() {
    	performServerTest(router) { expectation in
            self.performRequest("get", path: "/zxcv/test?q=test2", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Received /zxcv</b><p><p>p1=test<p><p>q=test2<p><p>u1=Ploni Almoni</body></html>\n\n")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }
    }

    func testRedirect() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/redir", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response!.readString()
                    XCTAssertNotNil(body!.range(of: "ibm"),"response does not contain IBM")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }
    }

    func testErrorHandler() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/error", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response!.readString()
                    let errorDescription = "foo is nil"
                    XCTAssertEqual(body!,"Caught the error: \(errorDescription)")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }
    }

    func testRouteFunc() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/route", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"get 1\nget 2\n")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("post", path: "/route", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"post received")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        })
    }

    func testHeaderModifiers() {

        router.get("/headerTest") { _, response, next in

            response.headers.append("Content-Type", value: "text/html")
            XCTAssertEqual(response.headers["Content-Type"]!, "text/html")

            response.headers.append("Content-Type", value: "text/plain; charset=utf-8")
            XCTAssertEqual(response.headers["Content-Type"]!, "text/html, text/plain; charset=utf-8")

            response.headers["Content-Type"] = nil
            XCTAssertNil(response.headers["Content-Type"])

            response.headers.append("Content-Type", value: "text/plain, image/png")
            XCTAssertEqual(response.headers["Content-Type"]!, "text/plain, image/png")

            response.headers.append("Content-Type", value: "text/html, image/jpeg")
            XCTAssertEqual(response.headers["Content-Type"]!, "text/plain, image/png, text/html, image/jpeg")

            response.headers.append("Content-Type", value: "charset=UTF-8")
            XCTAssertEqual(response.headers["Content-Type"]!, "text/plain, image/png, text/html, image/jpeg, charset=UTF-8")

            response.headers["Content-Type"] = nil

            response.headers.append("Content-Type", value: "text/plain")
            XCTAssertEqual(response.headers["Content-Type"]!, "text/plain")

            response.headers.append("Content-Type", value: "image/png, text/html")
            XCTAssertEqual(response.headers["Content-Type"]!, "text/plain, image/png, text/html")

            do {
                try response.status(HTTPStatusCode.OK).end("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n")
            }
            catch {}
            next()
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/headerTest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        }

    }

    func testAcceptTypes() {

        router.get("/customPage") { request, response, next in

            XCTAssertEqual(request.accepts("html"), "html", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts("text/html"), "text/html", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(["json", "text"]), "json", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts("application/json"), "application/json", "Accepts did not return expected value")

            // test for headers with * subtype
            XCTAssertEqual(request.accepts("application/xml"), "application/xml", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts("xml", "json"), "json", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts("html", "xml", "png"), "html", "Accepts did not return expected value")

            // shouldn't match anything
            XCTAssertNil(request.accepts("image/png"), "Request accepts this type when it shouldn't")
            XCTAssertNil(request.accepts("png"), "Request accepts this type when it shouldn't")
            XCTAssertNil(request.accepts("unreal"), "Invalid extension was accepted!")

            do {
                try response.status(HTTPStatusCode.OK).end("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n")
            }
            catch {}
            next()
        }

        router.get("/customPage2") { request, response, next in

            XCTAssertEqual(request.accepts("image/png"), "image/png", "Request accepts this type when it shouldn't")
            XCTAssertEqual(request.accepts("image/tiff"), "image/tiff", "Request accepts this type when it shouldn't")
            XCTAssertEqual(request.accepts("json", "jpeg", "html"), "html", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(["png", "html", "text/html"]), "html", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(["xml", "html", "unreal"]), "html", "Accepts did not return expected value")

            do {
                try response.status(HTTPStatusCode.OK).end("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n")
            }
            catch {}
            next()
        }

        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/customPage", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            }) {req in
                req.headers = ["Accept" : "text/*;q=.5, application/json, application/*;q=.3"]
            }
        }, { expectation in
            self.performRequest("get", path:"/customPage2", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            }) {req in
                req.headers = ["Accept" : "application/*;q=0.2, image/jpeg;q=0.8, text/html, text/plain, */*;q=.7"]
            }
        })
    }

    func testFormat() {
        performServerTest(router) { expectation in
            self.performRequest("get", path:"/format", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                XCTAssertEqual(response!.headers["Content-Type"]!.first!, "text/html")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body>Hi from Kitura!</body></html>\n\n")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
                }, headers: ["Accept" : "text/html"])
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path:"/format", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                XCTAssertEqual(response!.headers["Content-Type"]!.first!, "text/plain")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"Hi from Kitura!")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
                }, headers: ["Accept" : "text/plain"])
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path:"/format", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"default")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
                }, headers: ["Accept" : "text/cmd"])
        }

    }

    func testLink() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/single_link", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                let header = response!.headers["Link"]?.first
                XCTAssertNotNil(header, "Link header should not be nil")
                XCTAssertEqual(header!, "<https://developer.ibm.com/swift>; rel=\"root\"")
                expectation.fulfill()
            })
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/multiple_links", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                let firstLink = "<https://developer.ibm.com/swift/products/ibm-swift-sandbox/>; rel=\"next\""
                let secondLink = "<https://developer.ibm.com/swift/products/ibm-bluemix/>; rel=\"prev\""
                let header = response!.headers["Link"]?.first
                XCTAssertNotNil(header, "Link header should not be nil")
                XCTAssertNotNil(header!.range(of: firstLink), "link header should contain first link")
                XCTAssertNotNil(header!.range(of: secondLink), "link header should contain second link")
                expectation.fulfill()
            })
        }
    }

    func testSubdomains() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/subdomains", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                let hostHeader = response!.headers["Host"]?.first
                let domainHeader = response!.headers["Domain"]?.first
                let subdomainsHeader = response!.headers["Subdomain"]?.first

                XCTAssertEqual(hostHeader, "localhost", "Wrong http response host")
                XCTAssertEqual(domainHeader, "localhost", "Wrong http response domain")
                XCTAssertEqual(subdomainsHeader, "", "Wrong http response subdomains")
                expectation.fulfill()
            })
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/subdomains", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                let hostHeader = response!.headers["Host"]?.first
                let domainHeader = response!.headers["Domain"]?.first
                let subdomainsHeader = response!.headers["Subdomain"]?.first

                XCTAssertEqual(hostHeader, "a.b.c.example.com", "Wrong http response host")
                XCTAssertEqual(domainHeader, "example.com", "Wrong http response domain")
                XCTAssertEqual(subdomainsHeader, "a, b, c", "Wrong http response subdomains")
                expectation.fulfill()
            }, headers: ["Host" : "a.b.c.example.com"])
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/subdomains", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                let hostHeader = response!.headers["Host"]?.first
                let domainHeader = response!.headers["Domain"]?.first
                let subdomainsHeader = response!.headers["Subdomain"]?.first

                XCTAssertEqual(hostHeader, "a.b.c.d.example.co.uk", "Wrong http response host")
                XCTAssertEqual(domainHeader, "example.co.uk", "Wrong http response domain")
                XCTAssertEqual(subdomainsHeader, "a, b, c, d", "Wrong http response subdomains")
                expectation.fulfill()
            }, headers: ["Host" : "a.b.c.d.example.co.uk"])
        }
    }


    static func setupRouter() -> Router {
        let router = Router()

        // subdomains test
        router.get("subdomains") { request, response, next in
            response.headers["Host"] = request.hostname
            response.headers["Domain"] = request.domain

            let subdomains = request.subdomains

            response.headers["Subdomain"] = subdomains.joined(separator: ", ")

            response.status(.OK)
            next()
        }

        // the same router definition is used for all these test cases
        router.all("/zxcv/:p1") { request, _, next in
            request.userInfo["u1"] = "Ploni Almoni".bridge()
            next()
        }

        router.get("/qwer") { _, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            do {
                try response.end("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n")
            }
            catch {}
            next()
        }

        router.get("/zxcv/:p1") { request, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            let p1 = request.params["p1"] ?? "(nil)"
            let q = request.queryParams["q"] ?? "(nil)"
            let u1 = request.userInfo["u1"] as? NSString ?? "(nil)"
            do {
                try response.send("<!DOCTYPE html><html><body><b>Received /zxcv</b><p><p>p1=\(p1)<p><p>q=\(q)<p><p>u1=\(u1)</body></html>\n\n").end()
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
            response.status(HTTPStatusCode.internalServerError)
            response.error = InternalError.nilVariable(variable: "foo")
            next()
        }

        router.route("/route")
        .get { _, response, next in
            response.send("get 1\n")
            next()
        }
        .post {_, response, next in
            response.send("post received")
            next()
        }
        .get { _, response, next in
            response.send("get 2\n")
            next()
        }

        router.all("/bodytest", middleware: BodyParser())

        router.post("/bodytest") { request, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            guard let requestBody = request.body else {
                next ()
                return
            }
            switch (requestBody) {
                case .urlEncoded(let value):
                    do {
                        try response.end("<!DOCTYPE html><html><body><b>Received URL encoded body</b><br> \(value) </body></html>\n\n")
                    }
                    catch {}
                case .text(let value):
                    do {
                        try response.end("<!DOCTYPE html><html><body><b>Received text body: </b>\(value)</body></html>\n\n")
                    }
                    catch {}
                default:
                    response.error = Error.failedToParseRequestBody(body: "\(request.body)")

            }

            next()
        }
        
        router.all("/multibodytest", middleware: BodyParser())
        
        router.post("/multibodytest") { request, response, next in
            guard let requestBody = request.body else {
                next ()
                return
            }
            switch (requestBody) {
            case .multipart(let parts):
                for part in parts {
                    response.send("\(part.name) \(part.body) ")
                }
            default:
                response.error = Error.failedToParseRequestBody(body: "\(request.body)")
            }
            next()
        }
        
        router.post("/bodytest") { request, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            guard let requestBody = request.body else {
                next ()
                return
            }
            
            print(requestBody)
        }

        func callbackText(request: RouterRequest, response: RouterResponse) {
            do {
                try response.status(HTTPStatusCode.OK).send("Hi from Kitura!").end()
            }
            catch {}

        }

        func callbackHtml(request: RouterRequest, response: RouterResponse) {
            do {
                try response.status(HTTPStatusCode.OK).send("<!DOCTYPE html><html><body>Hi from Kitura!</body></html>\n\n").end()
            }
            catch {}

        }

        func callbackDefault(request: RouterRequest, response: RouterResponse) {
            do {
                response.headers["Content-Type"] = "text/plain; charset=utf-8"
                try response.status(HTTPStatusCode.OK).send("default").end()
            }
            catch {}

        }

        router.get("/format") { request, response, next in
            do {
                try response.format(callbacks: [
                                                   "text/plain" : callbackText,
                                                   "text/html" : callbackHtml,
                                                   "default" : callbackDefault])
            }
            catch {}
        }

        router.get("/single_link") { request, response, next in
            do {
                try response.link("https://developer.ibm.com/swift", rel: "root").status(.OK).end()
            } catch {}
        }

        router.get("/multiple_links") { request, response, next in
            do {
              try response
              .link("https://developer.ibm.com/swift/products/ibm-bluemix/", rel: "prev")
              .link("https://developer.ibm.com/swift/products/ibm-swift-sandbox/", rel: "next")
              .status(.OK).end()
            } catch {}
        }

        router.error { request, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            do {
                let errorDescription: String
                if let error = response.error {
                    errorDescription = "\(error)"
                }
                else {
                    errorDescription = ""
                }
                try response.send("Caught the error: \(errorDescription)").end()
            }
            catch {}
            next()
        }

	return router
    }
}
