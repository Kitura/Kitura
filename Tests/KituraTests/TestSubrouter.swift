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

#if os(Linux)
    import Foundation
    import Glibc
#else
    import Darwin
#endif

class TestSubrouter: KituraTest {

    static var allTests: [(String, (TestSubrouter) -> () throws -> Void)] {
        return [
            ("testSimpleSub", testSimpleSub),
            ("testExternSub", testExternSub),
            ("testSubSubs", testSubSubs),
            ("testMultipleMiddleware", testMultipleMiddleware),
            ("testMergeParams", testMergeParams)
        ]
    }

    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    let router = TestSubrouter.setupRouter()

    func testSimpleSub() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path:"/sub", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                //XCTAssertEqual(response?.method, "GET", "The request wasn't recognized as a get")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "hello from the sub")
                } catch {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }, { expectation in
        	self.performRequest("get", path:"/sub/sub1", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "sub1")
                } catch {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        })
    }

    func testExternSub() {
        router.all("/extern", middleware: ExternSubrouter.getRouter())

        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path:"/extern", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                //XCTAssertEqual(response?.method, "GET", "The request wasn't recognized as a get")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "hello from the sub")
                } catch {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path:"/extern/sub1", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "sub1")
                } catch {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        })
    }

    func testSubSubs() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path:"/sub/sub2", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                //XCTAssertEqual(response?.method, "GET", "The request wasn't recognized as a get")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "hello from the sub sub")
                } catch {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path:"/sub/sub2/sub1", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "subsub1")
                } catch {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        })
    }

    func testMultipleMiddleware() {
        performServerTest(router) { expectation in
            self.performRequest("get", path:"/middle/sub1", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                //XCTAssertEqual(response?.method, "GET", "The request wasn't recognized as a get")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "first middle\nsub1last middle\n")
                } catch {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }
    }

    func testMergeParams() {
        let simpleHandler = { (req: RouterRequest, res: RouterResponse, next: () -> Void) throws in
            next()
        }

        let handler: RouterHandler = { (req: RouterRequest, res: RouterResponse, next: () -> Void) throws in
            res.send(json: req.parameters)
        }

        let router = Router()
        let subsubRouter1 = router.route("/root1/:root1").route("/sub1/:sub1", mergeParameters: true)

        subsubRouter1.all("/subsub1/:subsub1", handler: handler)
        subsubRouter1.all("/subsub2/:subsub2", handler: simpleHandler)
        subsubRouter1.all("/subsub2/passthrough", handler: handler)

        router.route("/root2/:root2", mergeParameters: true).all { req, res, _ in
            res.send(json: req.parameters)
        }

        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/root1/123/sub1/456/subsub1/789", callback: { response in
                XCTAssertEqual(response?.statusCode, .OK)

                var data = Data()

                do {
                    try response?.readAllData(into: &data)
                    let dict = try TestRouteRegex.decoder.decode([String: String].self, from: data)
                    XCTAssertEqual(dict["root1"], nil)
                    XCTAssertEqual(dict["sub1"], "456")
                    XCTAssertEqual(dict["subsub1"], "789")

                } catch {
                    XCTFail()
                }

                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/root1/123/sub1/456/subsub2/passthrough", callback: { response in
                XCTAssertEqual(response?.statusCode, .OK)

                var data = Data()

                do {
                    try response?.readAllData(into: &data)
                    let dict = try TestRouteRegex.decoder.decode([String: String].self, from: data)
                    XCTAssertEqual(dict["root1"], nil)
                    XCTAssertEqual(dict["sub1"], "456")
                    XCTAssertEqual(dict["subsub2"], nil)

                } catch {
                    XCTFail()
                }

                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/root2/123", callback: { response in
                XCTAssertEqual(response?.statusCode, .OK)

                var data = Data()

                do {
                    try response?.readAllData(into: &data)
                    let dict = try TestRouteRegex.decoder.decode([String: String].self, from: data)
                    XCTAssertEqual(dict["root2"], "123")

                } catch {
                    XCTFail()
                }

                expectation.fulfill()
            })
        })
    }

    static func setupRouter() -> Router {
        let subsubRouter = Router()
        subsubRouter.get("/") { _, response, next in
            response.status(HTTPStatusCode.OK).send("hello from the sub sub")
            next()
        }
        subsubRouter.get("/sub1") { _, response, next in
            response.status(HTTPStatusCode.OK).send("subsub1")
            next()
        }

        let subRouter = Router()
        subRouter.get("/") { _, response, next in
            response.status(HTTPStatusCode.OK).send("hello from the sub")
            next()
        }
        subRouter.get("/sub1") { _, response, next in
            response.status(HTTPStatusCode.OK).send("sub1")
            next()
        }

        subRouter.all("/sub2", middleware: subsubRouter)

        let router = Router()
        let middleware = RouterMiddlewareGenerator { _, response, next in
            response.status(HTTPStatusCode.OK).send("first middle\n")
            next()
        }
        let middleware2 = RouterMiddlewareGenerator { _, response, next in
            response.status(HTTPStatusCode.OK).send("last middle\n")
            next()
        }
        router.all("/middle", middleware: middleware)
        router.all("/middle", middleware: subRouter)
        router.all("/middle", middleware: middleware2)

        router.all("/sub", middleware: subRouter)

        return router
    }
}
