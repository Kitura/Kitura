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
            ("testInvalidIdentifierSupplied", testInvalidIdentifierSupplied),
            ("testIdentifierNotExpected", testIdentifierNotExpected),
            ("testPartialIdentifierSupplied", testPartialIdentifierSupplied),
            ("testIdentifierNotSupplied", testIdentifierNotSupplied),
            ("testGetIdentifierNotSupplied", testGetIdentifierNotSupplied),
            ("testGetIdentifierSupplied", testGetIdentifierSupplied),
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

    func testInvalidRouteParameters() {
        //Add this erroneous route which should not be hit by the test, should log an error but we can't test the log so we check for a 404 not found.
        let result = Fruit(name: "banana", id: 1)
        router.get("/status/:notId") { (id: Int, respondWith: (Fruit?, RequestError?) -> Void) in
            XCTFail("GET on /status/:notId that should not happen")
            respondWith(result, nil)
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/status/1")
            .hasStatus(.notFound)
            .hasData()
            .run()
    }

    func testInvalidIdentifierSupplied() {
        //Add this erroneous route with invalid identifier, should log an error but we can't test the log so we check for a 404 not found.
        router.delete("/status/:myid") { (id: Int, respondWith: (RequestError?) -> Void) in
            XCTFail("DELETE on /status/:myid that should not happen")
            respondWith(.badRequest)
        }

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/status/1")
            .hasStatus(.notFound)
            .hasData()
            .run()
    }

    func testIdentifierNotExpected() {
        //Add this erroneous route which should not be hit by the test, should log an error but we can't test the log so we check for a 404 not found.
        router.delete("/users/:id") { (respondWith: (RequestError?) -> Void) in
            print("DELETE on /users")
            respondWith(.badRequest)
        }

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/users/1")
            .hasStatus(.notFound)
            .hasData()
            .run()
    }

    func testPartialIdentifierSupplied() {
        //Add this route with partial identifier. should log an error but we can't test the log so we check for a 404 not found.
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

    func testIdentifierNotSupplied() {
        router.delete("/status/") { (id: Int, respondWith: (RequestError?) -> Void) in
            print("DELETE on /status")
            respondWith(nil)
        }

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/status/1")
            .hasStatus(.noContent)
            .hasNoData()
            .run()
    }

    // A trailing :id parameter is allowed, but if not supplied will be added
    // implicitly (with a warning to signal to the user that this has occurred).
    func testGetIdentifierNotSupplied() {
        router.get("/banana") { (id: Int, respondWith: (Fruit?, RequestError?) -> Void) in
            print("GET on /banana")
            respondWith(Fruit(name: "banana", id: id), nil)
        }

        let banana = Fruit(name: "banana", id: 10)

        buildServerTest(router, timeout: 30)
            .request("get", path: "/banana/10")
            .hasStatus(.OK)
            .hasData(banana)
            .run()
    }

    // Test added to address fix for https://github.com/IBM-Swift/Kitura/issues/1473
    // A trailing :id parameter is allowed, and replaces the :id parameter that
    // would otherwise be added implicitly.
    func testGetIdentifierSupplied() {
        router.get("/banana/:id") { (id: Int, respondWith: (Fruit?, RequestError?) -> Void) in
            print("GET on /banana/:id")
            respondWith(Fruit(name: "banana", id: id), nil)
        }

        let banana = Fruit(name: "banana", id: 20)

        buildServerTest(router, timeout: 30)
            .request("get", path: "/banana/20")
            .hasStatus(.OK)
            .hasData(banana)
            .run()
    }

}
