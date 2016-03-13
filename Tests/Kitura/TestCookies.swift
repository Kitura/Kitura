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

class TestCookies : KituraTest {
    #if os(Linux)
        override var allTests : [(String, () throws -> Void)] {
            return [
                ("testCookieToServer", testCookieToServer)
            ]
        }
    #endif

    let router = TestCookies.setupRouter()

    func testCookieToServer() {
        performServerTest(router, asyncTasks: {
            self.performRequest("get", path: "/1/cookiedump", callback: {response in
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "cookiedump route did not match single path request")
                do {
                    let data = NSMutableData()
                    let count = try response!.readAllData(data)
                    XCTAssertEqual(count, 4, "Plover's value should have been four bytes")
                    if  let ploverValue = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        XCTAssertEqual(ploverValue.bridge(), "qwer")
                    }
                    else {
                        XCTFail("Plover's value wasn't an UTF8 string")
                    }
                }
                catch {
                    XCTFail("Failed reading the body of the response")
                }
            }, headers: ["Cookie": "Plover=qwer; Zxcv=tyuiop"])
        })
    }

    static func setupRouter() -> Router {
        let router = Router()

        router.get("/1/cookiedump") {request, response, next in
            response.status(HttpStatusCode.OK)
            if  let ploverCookie = request.cookies["Plover"]  {
                response.send(ploverCookie.value)
            }

            next()
        }

        return router
    }
}
