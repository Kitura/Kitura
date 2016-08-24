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
import Foundation

@testable import Kitura
@testable import KituraNet

class TestRequests: XCTestCase {

    static var allTests: [(String, (TestRequests) -> () throws -> Void)] {
        return [
                   ("testURLParameters", testURLParameters),
                   ("testCustomMiddlewareURLParameter", testCustomMiddlewareURLParameter),
                   ("testCustomMiddlewareURLParameterWithQueryParam", testCustomMiddlewareURLParameterWithQueryParam)
        ]
    }

    override func setUp() {
        doSetUp()
    }

    override func tearDown() {
        doTearDown()
    }

    let router = TestRequests.setupRouter()

    func testURLParameters() {
        // Set up router for this test
        let router = Router()

        router.get("/zxcv/:p1") { request, _, next in
            let parameter = request.parameters["p1"]
            XCTAssertNotNil(parameter, "URL parameter p1 was nil")
            next()
        }
        router.get("/zxcv/ploni") { request, _, next in
            let parameter = request.parameters["p1"]
            XCTAssertNil(parameter, "URL parameter p1 was not nil, it's value was \(parameter!)")
            next()
        }
        router.all() { _, response, next in
            response.status(.OK).send("OK")
            next()
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/zxcv/ploni", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        }
    }

    private func runMiddlewareTest(path: String) {
        class CustomMiddleware: RouterMiddleware {
            func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
                let id = request.parameters["id"]
                XCTAssertNotNil(id, "URL parameter 'id' in custom middleware was nil")
                XCTAssertEqual("my_custom_id", id, "URL parameter 'id' in custom middleware was wrong")
                response.status(.OK)
                next()
            }
        }

        let router = Router()

        router.get("/user/:id", allowPartialMatch: false, middleware: CustomMiddleware())
        router.get("/user/:id") { request, response, next in
            let id = request.parameters["id"]
            XCTAssertNotNil(id, "URL parameter 'id' in middleware handler was nil")
            XCTAssertEqual("my_custom_id", id, "URL parameter 'id' in middleware handler was wrong")
            response.status(.OK)
            next()
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: path, callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        }
    }

    func testCustomMiddlewareURLParameter() {
        runMiddlewareTest(path: "/user/my_custom_id")
    }

    func testCustomMiddlewareURLParameterWithQueryParam() {
        runMiddlewareTest(path: "/user/my_custom_id?some_param=value")
    }

    static func setupRouter() -> Router {
        let router = Router()

        router.get("/zxcv/:p1") { request, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            let p1 = request.parameters["p1"] ?? "(nil)"
            let q = request.queryParameters["q"] ?? "(nil)"
            let u1 = request.userInfo["u1"] as? NSString ?? "(nil)"
            do {
                try response.send("<!DOCTYPE html><html><body><b>Received /zxcv</b><p><p>p1=\(p1)<p><p>q=\(q)<p><p>u1=\(u1)</body></html>\n\n").end()
            } catch {}
            next()
        }



        return router
    }
}
