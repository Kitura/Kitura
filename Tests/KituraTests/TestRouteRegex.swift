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

class TestRouteRegex: XCTestCase {

    static var allTests: [(String, (TestRouteRegex) -> () throws -> Void)] {
        return [
            ("testBuildRegexFromPattern", testBuildRegexFromPattern)
        ]
    }

    override func setUp() {
        doSetUp()
    }

    override func tearDown() {
        doTearDown()
    }

    static let helloworld = "Hello world"

    static let handler = { (req: RouterRequest, res: RouterResponse, next: () -> Void) throws in
        try res.send(helloworld).end()
    }

    static let mountpath = "/helloworld"

    static let subrouter = { () -> Router in
        let subrouter = Router()
        subrouter.all(mountpath, handler: handler)

        return subrouter
    }()

    func testBuildRegexFromPattern() {
        #if os(Linux)
            var regex: RegularExpression?
        #else
            var regex: NSRegularExpression?
        #endif
        var strings: [String]?
        var path: String
        var range: NSRange

        // Partial match false adds '$' end of string special character
        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test", allowPartialMatch: false)
        path = "/test"
        range = regex!.rangeOfFirstMatch(in: path, options: [], range: NSMakeRange(0, path.characters.count))
        XCTAssertEqual(regex!.pattern, "^/test/?$")
        XCTAssertTrue(strings!.isEmpty)
        XCTAssertEqual(range.location, 0)
        XCTAssertEqual(range.length, 5)


        // Partial match true does not include '$' end of string special character
        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test", allowPartialMatch: true)
        path = "/test/hello/world"
        range = regex!.rangeOfFirstMatch(in: path, options: [], range: NSMakeRange(0, path.characters.count))
        XCTAssertEqual(regex!.pattern, "^/test/?(?=/|$)")
        XCTAssertTrue(strings!.isEmpty)
        XCTAssertEqual(range.location, 0)
        XCTAssertEqual(range.length, 5)

        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/:id", allowPartialMatch: true)
        path = "/test/123/hello/world"
        range = regex!.rangeOfFirstMatch(in: path, options: [], range: NSMakeRange(0, path.characters.count))
        XCTAssertEqual(regex!.pattern, "^/test/(?:([^/]+?))/?(?=/|$)")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "id")
        XCTAssertEqual(range.location, 0)
        XCTAssertEqual(range.length, 9)

        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/:id+", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern, "^/test/([^/]+?(?:/[^/]+?)*)/?$")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "id")

        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/:id*", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern, "^/test(?:/([^/]+?(?:/[^/]+?)*))?/?$")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "id")

        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/:id(\\d*)", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern, "^/test/(?:(\\d*))/?$")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "id")

        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/:id(Kitura\\d*)", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern, "^/test/(?:(Kitura\\d*))/?$")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "id")

        (regex, strings) = RouteRegex.sharedInstance.buildRegex(fromPattern: "test/(Kitura\\d*)", allowPartialMatch: false)
        XCTAssertEqual(regex!.pattern, "^/test/(?:(Kitura\\d*))/?$")
        XCTAssertFalse(strings!.isEmpty)
        XCTAssertEqual(strings![0], "0")
    }

    func testSimplePaths() {
        var router = Router()

        router.all("", handler: TestRouteRegex.handler)

        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "", callback: { response in
                XCTAssertEqual(response?.statusCode, .OK)

                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, TestRouteRegex.helloworld)
                }
                catch {
                    XCTFail()
                }

                expectation.fulfill()
            })
        })

        // This test is broken
        // Skip for now
//        router = Router()
//
//        router.all("", middleware: TestRouteRegex.subrouter)
//
//        performServerTest(router, asyncTasks: { expectation in
//            self.performRequest("get", path: "/helloworld", callback: { response in
//                XCTAssertEqual(response?.statusCode, .OK)
//
//                do {
//                    let body = try response?.readString()
//                    XCTAssertEqual(body, TestRouteRegex.helloworld)
//                }
//                catch {
//                    XCTFail()
//                }
//
//                expectation.fulfill()
//            })
//        })

        router = Router()

        router.all("/", handler: TestRouteRegex.handler)

        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "", callback: { response in
                XCTAssertEqual(response?.statusCode, .OK)

                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, TestRouteRegex.helloworld)
                }
                catch {
                    XCTFail()
                }

                expectation.fulfill()
            })
        })

        // This test is broken
        // Skip for now
//        router = Router()
//
//        router.all("/", middleware: TestRouteRegex.subrouter)
//
//        performServerTest(router, asyncTasks: { expectation in
//            self.performRequest("get", path: TestRouteRegex.mountpath, callback: { response in
//                XCTAssertEqual(response?.statusCode, .OK)
//
//                do {
//                    let body = try response?.readString()
//                    XCTAssertEqual(body, TestRouteRegex.helloworld)
//                }
//                catch {
//                    XCTFail()
//                }
//
//                expectation.fulfill()
//            })
//        })

        router = Router()

        router.all("/*", handler: TestRouteRegex.handler)

        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "", callback: { response in
                XCTAssertEqual(response?.statusCode, .OK)

                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, TestRouteRegex.helloworld)
                }
                catch {
                    XCTFail()
                }

                expectation.fulfill()
            })
        })

        router = Router()

        router.all("/*", middleware: TestRouteRegex.subrouter)

        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: TestRouteRegex.mountpath, callback: { response in
                XCTAssertEqual(response?.statusCode, .notFound)

                expectation.fulfill()
            })
        })
    }
}
