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

class TestSubrouter : KituraTest {
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
    
    let router = TestSubrouter.setupRouter()
    
    func testSimpleSub() {
        performServerTest(router, asyncTasks: {
            self.performRequest("get", path:"/sub", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                XCTAssertNotNil(response!.headers["Date"], "There was No Date header in the response")
                //XCTAssertEqual(response!.method, "GET", "The request wasn't recognized as a get")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"hello from the sub")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        }, {
        	self.performRequest("get", path:"/sub/sub1", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"sub1")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        	})
    }
    
    static func setupRouter() -> Router {
        let subRouter = Router()
        subRouter.get("/") { request, response, next in
            response.status(HttpStatusCode.OK).send("hello from the sub")
            next()
        }
        subRouter.get("/sub1") { request, response, next in
            response.status(HttpStatusCode.OK).send("sub1")
            next()
        }
        
        let router = Router()
        router.all("/sub", middleware: subRouter)
        
        return router
    }
}