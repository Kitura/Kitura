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
                ("testSimpleSub", testSimpleSub),
                ("testExternSub", testExternSub),
                ("testSubSubs", testSubSubs),
                ("testMultipleMiddleware", testMultipleMiddleware)
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

    func testExternSub() {
        router.all("/extern", middleware: ExternSubrouter.getRouter())

        performServerTest(router, asyncTasks: {
            self.performRequest("get", path:"/extern", callback: {response in
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
            self.performRequest("get", path:"/extern/sub1", callback: {response in
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

    func testSubSubs() {
        performServerTest(router, asyncTasks: {
            self.performRequest("get", path:"/sub/sub2", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                XCTAssertNotNil(response!.headers["Date"], "There was No Date header in the response")
                //XCTAssertEqual(response!.method, "GET", "The request wasn't recognized as a get")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"hello from the sub sub")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        }, {
            self.performRequest("get", path:"/sub/sub2/sub1", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"subsub1")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        })
    }

    func testMultipleMiddleware() {
        performServerTest(router) {
            self.performRequest("get", path:"/middle/sub1", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                XCTAssertNotNil(response!.headers["Date"], "There was No Date header in the response")
                //XCTAssertEqual(response!.method, "GET", "The request wasn't recognized as a get")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"first middle\nsub1lastmiddle\n")
                }
                catch{
                    XCTFail("No respose body")
                }
            })
        }
    }
    
    static func setupRouter() -> Router {
        let subsubRouter = Router()
        subsubRouter.get("/") { request, response, next in
            response.status(HttpStatusCode.OK).send("hello from the sub sub")
            next()
        }
        subsubRouter.get("/sub1") { request, response, next in
            response.status(HttpStatusCode.OK).send("subsub1")
            next()
        }

        let subRouter = Router()
        subRouter.get("/") { request, response, next in
            response.status(HttpStatusCode.OK).send("hello from the sub")
            next()
        }
        subRouter.get("/sub1") { request, response, next in
            response.status(HttpStatusCode.OK).send("sub1")
            next()
        }

        subRouter.all("/sub2", middleware: subsubRouter)
        
        let router = Router()
        let middleware = RouterMiddlewareGenerator { (request: RouterRequest, response: RouterResponse, next: () -> Void) in
            response.status(HttpStatusCode.OK).send("first middle\n")
            next()
        }
        let middleware2 = RouterMiddlewareGenerator { (request: RouterRequest, response: RouterResponse, next: () -> Void) in
            response.status(HttpStatusCode.OK).send("last middle\n")
            next()
        }
        router.all("/middle", middleware: middleware)
        router.all("/middle", middleware: subRouter)
        router.all("/middle", middleware: middleware2)

        router.all("/sub", middleware: subRouter)
        
        return router
    }
}