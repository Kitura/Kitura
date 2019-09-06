/**
 * Copyright IBM Corporation 2017
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
import KituraContracts

@testable import Kitura

final class TestCodablePathParams: KituraTest, KituraTestSuite {
    static var allTests: [(String, (TestCodablePathParams) -> () throws -> Void)] {
        return [
            ("testJoinPath", testJoinPath),
            ("testRouteWithTrailingSlash", testRouteWithTrailingSlash),
            ("testInvalidRouteParameters", testInvalidRouteParameters),
            ("testIdentifierNotExpected", testIdentifierNotExpected),
            ("testPartialIdentifierSupplied", testPartialIdentifierSupplied),
            ("testIdentifierNotSupplied", testIdentifierNotSupplied),
            ("testIdentifierSupplied", testIdentifierSupplied),
        ]
    }

    // Need to initialise to avoid compiler error
    var router = Router()

    // Reset for each test
    override func setUp() {
        super.setUp()           // Initialize logging
        router = Router()
    }

    struct Fruit: Codable, Equatable {
        let name: String
        let id: Int

        static func == (lhs: Fruit, rhs: Fruit) -> Bool {
            return lhs.name == rhs.name && lhs.id == rhs.id
        }
    }

    func testJoinPath() {
        let router = Router()
        // Implicit append of :id
        XCTAssertEqual(router.appendId(path: "a"), "a/:id")
        XCTAssertEqual(router.appendId(path: "a/"), "a/:id")
        // User already specified :id
        XCTAssertEqual(router.appendId(path: "a/:id"), "a/:id")
        // User specified a different identifier name (not supported)
        XCTAssertEqual(router.appendId(path: "a/:foo"), "a/:foo")
    }

    // Test adding a trailing slash to your route when it has an implicit id parameter
    func testRouteWithTrailingSlash() {
        router.get("/fruit/") { (id: Int, respondWith: (Fruit?, RequestError?) -> Void) in
            respondWith(Fruit(name: "apple", id: id), nil)
        }
        router.put("/fruit/") { (id: Int, fruit: Fruit, respondWith: (Fruit?, RequestError?) -> Void) in
            respondWith(Fruit(name: fruit.name, id: id), nil)
        }
        router.patch("/fruit/") { (id: Int, fruit: Fruit, respondWith: (Fruit?, RequestError?) -> Void) in
            respondWith(Fruit(name: fruit.name, id: id), nil)
        }
        router.delete("/fruit/") { (id: Int, respondWith: (RequestError?) -> Void) in
            XCTAssertEqual(id, 1)
            respondWith(nil)
        }
        let apple = Fruit(name: "apple", id: 1)
        let banana = Fruit(name: "banana", id: 2)

        buildServerTest(router, timeout: 30)
            .request("get", path: "/fruit/1").hasStatus(.OK).hasContentType(withPrefix: "application/json").hasData(apple)
            .request("put", path: "/fruit/2", data: banana).hasStatus(.OK).hasContentType(withPrefix: "application/json").hasData(banana)
            .request("patch", path: "/fruit/2", data: banana).hasStatus(.OK).hasContentType(withPrefix: "application/json").hasData(banana)
            .request("delete", path: "/fruit/1").hasStatus(.noContent).hasNoData()
            .run()
    }

    // Test that routes containing a path parameter that is not `:id` are
    // correctly rejected.
    func testInvalidRouteParameters() {
        // These routes should fail to be registered.
        router.get("/fruit/:myid") { (id: Int, respondWith: (Fruit?, RequestError?) -> Void) in
            XCTFail("GET on /fruit/:myid that should not happen")
            let result = Fruit(name: "banana", id: 1)
            respondWith(result, nil)
        }
        router.delete("/fruit/:myid") { (id: Int, respondWith: (RequestError?) -> Void) in
            XCTFail("DELETE on /fruit/:myid that should not happen")
            respondWith(.badRequest)
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/fruit/1")
            .hasStatus(.notFound)
            .hasData()

            .request("delete", path: "/fruit/1")
            .hasStatus(.notFound)
            .hasData()

            .run()
    }

    // Test that routes with trailing :id for a DELETE (plural) or GET (plural)
    // handler are correctly rejected.
    func testIdentifierNotExpected() {
        // These routes should fail to be registered.
        router.delete("/fruit/:id") { (respondWith: (RequestError?) -> Void) in
            XCTFail("DELETE (plural) on /fruit/:id that should not happen")
            respondWith(.badRequest)
        }
        router.get("/fruit/:id") { (respondWith: ([Fruit]?, RequestError?) -> Void) in
            XCTFail("GET (plural) on /fruit/:id that should not happen")
        }

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/fruit/1")
            .hasStatus(.notFound)
            .hasData()

            .request("get", path: "/fruit/1")
            .hasStatus(.notFound)
            .hasData()

            .run()
    }

    // Test that a route with a partial identifier is rejected.
    func testPartialIdentifierSupplied() {
        // This route should fail to be registered.
        router.delete("/status/:") { (id: Int, respondWith: (RequestError?) -> Void) in
            XCTFail("DELETE on /status/: that should not happen")
            respondWith(.badRequest)
        }

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/status/1")
            .hasStatus(.notFound)
            .hasData()
            .run()
    }

    // A trailing :id parameter is allowed, but if not supplied will be added
    // implicitly (with a warning to signal to the user that this has occurred).
    func testIdentifierNotSupplied() {
        router.delete("/fruit/") { (id: Int, respondWith: (RequestError?) -> Void) in
            print("DELETE on /fruit/ (implicit :id)")
            XCTAssertEqual(id, 1)
            respondWith(nil)
        }
        router.get("/fruit") { (id: Int, respondWith: (Fruit?, RequestError?) -> Void) in
            print("GET on /fruit (implicit :id)")
            respondWith(Fruit(name: "banana", id: id), nil)
        }

        let banana = Fruit(name: "banana", id: 10)

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/fruit/1")
            .hasStatus(.noContent)
            .hasNoData()

            .request("get", path: "/fruit/10")
            .hasStatus(.OK)
            .hasData(banana)

            .run()
    }

    // Test added to address fix for https://github.com/IBM-Swift/Kitura/issues/1473
    // Tests that a GET (singular) or DELETE (singular) with explicit :id parameter
    // is successful.
    // A trailing :id parameter is allowed, and replaces the :id parameter that
    // would otherwise be added implicitly.
    func testIdentifierSupplied() {
        router.get("/fruit/:id") { (id: Int, respondWith: (Fruit?, RequestError?) -> Void) in
            print("GET on /fruit/:id")
            respondWith(Fruit(name: "banana", id: id), nil)
        }
        router.delete("/fruit/:id") { (id: Int, respondWith: (RequestError?) -> Void) in
            print("DELETE on /fruit/:id")
            XCTAssertEqual(id, 1)
            respondWith(nil)
        }
        let banana = Fruit(name: "banana", id: 20)

        buildServerTest(router, timeout: 30)
            .request("get", path: "/fruit/20")
            .hasStatus(.OK)
            .hasData(banana)

            .request("delete", path: "/fruit/1")
            .hasStatus(.noContent)
            .hasNoData()

            .run()
    }

}
