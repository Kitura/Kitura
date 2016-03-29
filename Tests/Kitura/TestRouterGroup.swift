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

class TestRouterGroup : KituraTest {
    #if os(Linux)
        override var allTests : [(String, () throws -> Void)] {
            return [
                ("testRouterGroupGet", testRouterGroupGet),
                ("testRouterGroupPost", testRouterGroupPost)
            ]
        }
    #endif

    let router = TestRouterGroup.setupRouter()

    func testRouterGroupGet() {
    	performServerTest(router) {
            self.performRequest("get", path:"/group", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                XCTAssertNotNil(response!.headers["Date"], "There was No Date header in the response")
                // XCTAssertEqual(response!.method, "GET", "The request wasn't recognized as a get")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Received GET</b><p>u1=Ploni Almoni</p></body></html>\n\n")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        }
    }

    func testRouterGroupPost() {
      performServerTest(router) {
            self.performRequest("post", path:"/group", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                XCTAssertNotNil(response!.headers["Date"], "There was No Date header in the response")
                // XCTAssertEqual(response!.method, "POST", "The request wasn't recognized as a post")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Received POST</b><p>u1=Ploni Almoni</p></body></html>\n\n")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        }
    }

    static func setupRouter() -> Router {
        let router = Router()

        router.group("/group")
        .all { request, _, next in
            request.userInfo["u1"] = "Ploni Almoni".bridge()
            next()
        }
        .get { request, response, next in
            response.setHeader("Content-Type", value: "text/html; charset=utf-8")
            let u1 = request.userInfo["u1"] as? NSString ?? "(nil)"
            do {
                try response.status(HttpStatusCode.OK).send("<!DOCTYPE html><html><body><b>Received GET</b><p>u1=\(u1)</p></body></html>\n\n").end()
            }
            catch {}
            next()
        }
        .post { request, response, next in
            response.setHeader("Content-Type", value: "text/html; charset=utf-8")
            let u1 = request.userInfo["u1"] as? NSString ?? "(nil)"
            do {
                try response.status(HttpStatusCode.OK).send("<!DOCTYPE html><html><body><b>Received POST</b><p>u1=\(u1)</p></body></html>\n\n").end()
            }
            catch {}
            next()
        }

	      return router
    }
}
