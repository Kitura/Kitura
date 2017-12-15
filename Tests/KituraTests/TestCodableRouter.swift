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
@testable import KituraNet

class TestCodableRouter: KituraTest {
    static var allTests: [(String, (TestCodableRouter) -> () throws -> Void)] {
        return [
            ("testBasicPost", testBasicPost),
            ("testBasicPostIdentifier", testBasicPostIdentifier),
            ("testBasicGetSingleton", testBasicGetSingleton),
            ("testBasicGetArray", testBasicGetArray),
            ("testBasicGetSingle", testBasicGetSingle),
            ("testBasicDelete", testBasicDelete),
            ("testBasicDeleteSingle", testBasicDeleteSingle),
            ("testBasicPut", testBasicPut),
            ("testBasicPatch", testBasicPatch),
            ("testJoinPath", testJoinPath),
            ("testRouteWithTrailingSlash", testRouteWithTrailingSlash),
            ("testRouteParameters", testRouteParameters),
            ("testCodableRoutesWithBodyParsingFail", testCodableRoutesWithBodyParsingFail),
        ]
    }

    // Need to initialise to avoid compiler error
    var router = Router()
    var userStore: [Int: User] = [:]

    // Reset for each test
    override func setUp() {
        router = Router()
        userStore = [1: User(id: 1, name: "Mike"), 2: User(id: 2, name: "Chris"), 3: User(id: 3, name: "Ricardo")]
    }

    struct Conflict: Codable, Equatable {
        let field: String

        init(on field: String) {
            self.field = field
        }

        static func ==(lhs: Conflict, rhs: Conflict) -> Bool {
            return lhs.field == rhs.field
        }
    }

    struct User: Codable, Equatable {
        let id: Int
        let name: String

        init(id: Int, name: String) {
            self.id = id
            self.name = name
        }

        static func ==(lhs: User, rhs: User) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
        }
    }

    struct OptionalUser: Codable, Equatable {
        let id: Int?
        let name: String?

        init(id: Int?, name: String?) {
            self.id = id
            self.name = name
        }

        static func ==(lhs: OptionalUser, rhs: OptionalUser) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
        }
    }

    struct Status: Codable, Equatable {
        let description: String
        init(_ desc: String) {
            description = desc
        }

        static func ==(lhs: Status, rhs: Status) -> Bool {
            return lhs.description == rhs.description
        }
    }

    func testBasicPost() {
        router.post("/users") { (user: User, respondWith: (User?, RequestError?) -> Void) in
            print("POST on /users for user \(user)")
            respondWith(user, nil)
        }
        router.post("/error/users") { (user: User, respondWith: (User?, RequestError?) -> Void) in
            print("POST on /error/users for user \(user)")
            respondWith(nil, .conflict)
        }
        router.post("/bodyerror/users") { (user: User, respondWith: (User?, RequestErrorWithBody<Conflict>?) -> Void) in
            print("POST on /bodyerror/users for user \(user)")
            respondWith(user, RequestErrorWithBody(.conflict, body: Conflict(on: "id")))
        }

        let user = User(id: 4, name: "David")
        buildServerTest(router, timeout: 30)
            .request("post", path: "/users", data: user)
            .hasStatus(.created)
            .hasData(user)

            .request("post", path: "/error/users", data: user)
            .hasStatus(.conflict)

            .request("post", path: "/bodyerror/users", data: user)
            .hasStatus(.conflict)
            .hasData(Conflict(on: "id"))

            .run()
    }

    func testBasicPostIdentifier() {
        router.post("/users") { (user: User, respondWith: (Int?, User?, RequestError?) -> Void) in
            print("POST on /users for user \(user)")
            respondWith(user.id, user, nil)
        }
        router.post("/error/users") { (user: User, respondWith: (Int?, User?, RequestError?) -> Void) in
            print("POST on /error/users for user \(user)")
            respondWith(nil, nil, .conflict)
        }
        router.post("/bodyerror/users") { (user: User, respondWith: (Int?, User?, RequestErrorWithBody<Conflict>?) -> Void) in
            print("POST on /bodyerror/users for user \(user)")
            respondWith(nil, nil, RequestErrorWithBody(.conflict, body: Conflict(on: "id")))
        }

        let user = User(id: 4, name: "David")
        buildServerTest(router, timeout: 30)
            .request("post", path: "/users", data: user)
            .hasStatus(.created)
            .hasHeader("Location", only: String(user.id))
            .hasData(user)

            .request("post", path: "/error/users", data: user)
            .hasStatus(.conflict)

            .request("post", path: "/bodyerror/users", data: user)
            .hasStatus(.conflict)
            .hasData(Conflict(on: "id"))

            .run()
    }

    func testBasicGetSingleton() {
        router.get("/status") { (respondWith: (Status?, RequestError?) -> Void) in
            print("GET on /status")
            respondWith(Status("GOOD"), nil)
        }
        router.get("/error/status") { (respondWith: (Status?, RequestError?) -> Void) in
            print("GET on /status")
            respondWith(nil, .serviceUnavailable)
        }
        router.get("/bodyerror/status") { (respondWith: (Status?, RequestErrorWithBody<Status>?) -> Void) in
            print("GET on /status")
            respondWith(nil, RequestErrorWithBody(.serviceUnavailable, body: Status("BAD")))
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/status")
            .hasStatus(.OK)
            .hasData(Status("GOOD"))

            .request("get", path: "/error/status")
            .hasStatus(.serviceUnavailable)

            .request("get", path: "/bodyerror/status")
            .hasStatus(.serviceUnavailable)
            .hasData(Status("BAD"))

            .run()
    }

    func testBasicGetArray() {
        router.get("/users") { (respondWith: ([User]?, RequestError?) -> Void) in
            print("GET on /users")
            respondWith(self.userStore.map({ $0.value }), nil)
        }
        router.get("/error/users") { (respondWith: ([User]?, RequestError?) -> Void) in
            print("GET on /error/users")
            respondWith(nil, .serviceUnavailable)
        }
        router.get("/bodyerror/users") { (respondWith: ([User]?, RequestErrorWithBody<Status>?) -> Void) in
            print("GET on /bodyerror/users")
            respondWith(nil, RequestErrorWithBody(.serviceUnavailable, body: Status("BAD")))
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/users")
            .hasStatus(.OK)
            .hasData(self.userStore.map({ $0.value }))

            .request("get", path: "/error/users")
            .hasStatus(.serviceUnavailable)
            .hasNoData()

            .request("get", path: "/bodyerror/users")
            .hasStatus(.serviceUnavailable)
            .hasData(Status("BAD"))

            .run()
    }

    func testBasicGetSingle() {
        router.get("/users") { (id: Int, respondWith: (User?, RequestError?) -> Void) in
            print("GET on /users/\(id)")
            guard let user = self.userStore[id] else {
                XCTFail("ERROR!!! Couldn't find user with id \(id)")
                respondWith(nil, .notFound)
                return
            }
            respondWith(user, nil)
        }
        router.get("/error/users") { (id: Int, respondWith: (User?, RequestError?) -> Void) in
            print("GET on /error/users/\(id)")
            respondWith(nil, .serviceUnavailable)
        }
        router.get("/bodyerror/users") { (id: Int, respondWith: (User?, RequestErrorWithBody<Status>?) -> Void) in
            print("GET on /bodyerror/users/\(id)")
            respondWith(nil, RequestErrorWithBody(.serviceUnavailable, body: Status("BAD: \(id)")))
        }

        guard let user = self.userStore[1] else {
            XCTFail("ERROR!!! Couldn't find user with id 1")
            return
        }
        buildServerTest(router, timeout: 30)
            .request("get", path: "/users/1")
            .hasStatus(.OK)
            .hasData(user)

            .request("get", path: "/error/users/1")
            .hasStatus(.serviceUnavailable)
            .hasNoData()

            .request("get", path: "/bodyerror/users/1")
            .hasStatus(.serviceUnavailable)
            .hasData(Status("BAD: 1"))

            .run()
    }

    func testBasicDelete() {
        router.delete("/users") { (respondWith: (RequestError?) -> Void) in
            print("DELETE on /users")
            self.userStore.removeAll()
            respondWith(nil)
        }
        router.delete("/error/users") { (respondWith: (RequestError?) -> Void) in
            print("DELETE on /error/users")
            respondWith(.serviceUnavailable)
        }
        router.delete("/bodyerror/users") { (respondWith: (RequestErrorWithBody<Status>?) -> Void) in
            print("DELETE on /bodyerror/users")
            respondWith(RequestErrorWithBody(.serviceUnavailable, body: Status("BAD")))
        }

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/users")
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertEqual(self.userStore.count, 0) }

            .request("delete", path: "/error/users")
            .hasStatus(.serviceUnavailable)
            .hasNoData()

            .request("delete", path: "/bodyerror/users")
            .hasStatus(.serviceUnavailable)
            .hasData(Status("BAD"))

            .run()
    }

    func testBasicDeleteSingle() {
        router.delete("/users") { (id: Int, respondWith: (RequestError?) -> Void) in
            print("DELETE on /users/\(id)")
            guard let _ = self.userStore.removeValue(forKey: id) else {
                respondWith(.notFound)
                return
            }
            respondWith(nil)
        }
        router.delete("/error/users") { (id: Int, respondWith: (RequestError?) -> Void) in
            print("DELETE on /error/users/\(id)")
            respondWith(.serviceUnavailable)
        }
        router.delete("/bodyerror/users") { (id: Int, respondWith: (RequestErrorWithBody<Status>?) -> Void) in
            print("DELETE on /bodyerror/users/\(id)")
            respondWith(RequestErrorWithBody(.serviceUnavailable, body: Status("BAD: \(id)")))
        }

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/users/1")
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertNil(self.userStore[1]) }

            .request("delete", path: "/error/users/1")
            .hasStatus(.serviceUnavailable)
            .hasNoData()

            .request("delete", path: "/bodyerror/users/1")
            .hasStatus(.serviceUnavailable)
            .hasData(Status("BAD: 1"))

            .run()
    }

    func testBasicPut() {
        router.put("/users") { (id: Int, user: User, respondWith: (User?, RequestError?) -> Void) in
            print("PUT on /users/\(id)")
            self.userStore[id] = user
            respondWith(user, nil)
        }
        router.put("/error/users") { (id: Int, user: User, respondWith: (User?, RequestError?) -> Void) in
            print("PUT on /error/users/\(id)")
            respondWith(nil, .serviceUnavailable)
        }
        router.put("/bodyerror/users") { (id: Int, user: User, respondWith: (User?, RequestErrorWithBody<Status>?) -> Void) in
            print("PUT on /bodyerror/users/\(id)")
            respondWith(nil, RequestErrorWithBody(.serviceUnavailable, body: Status("BAD: \(id)")))
        }

        XCTAssertEqual(self.userStore[1]?.name, "Mike")

        let user = User(id: 1, name: "David")
        buildServerTest(router, timeout: 30)
            .request("put", path: "/users/1", data: user)
            .hasStatus(.OK)
            .hasData(user)
            .has { _ in XCTAssertEqual(self.userStore[1]?.name, "David") }

            .request("put", path: "/error/users/1", data: user)
            .hasStatus(.serviceUnavailable)
            .hasNoData()

            .request("put", path: "/bodyerror/users/1", data: user)
            .hasStatus(.serviceUnavailable)
            .hasData(Status("BAD: 1"))

            .run()
    }

    func testBasicPatch() {
        router.patch("/users") { (id: Int, patchUser: OptionalUser, respondWith: (User?, RequestError?) -> Void) -> Void in
            print("PATCH on /users/\(id)")
            guard let existingUser = self.userStore[id] else {
                respondWith(nil, .notFound)
                return
            }
            if let patchUserName = patchUser.name {
                let updatedUser = User(id: id, name: patchUserName)
                self.userStore[id] = updatedUser
                respondWith(updatedUser, nil)
            } else {
                respondWith(existingUser, nil)
            }
        }
        router.patch("/error/users") { (id: Int, patchUser: OptionalUser, respondWith: (User?, RequestError?) -> Void) -> Void in
            print("PATCH on /error/users/\(id)")
            respondWith(nil, .serviceUnavailable)
        }
        router.patch("/bodyerror/users") { (id: Int, patchUser: OptionalUser, respondWith: (User?, RequestErrorWithBody<Status>?) -> Void) -> Void in
            print("PATCH on /bodyerror/users/\(id)")
            respondWith(nil, RequestErrorWithBody(.serviceUnavailable, body: Status("BAD: \(id)")))
        }

        XCTAssertEqual(self.userStore[2]?.name, "Chris")

        let user = User(id: 2, name: "David")
        buildServerTest(router, timeout: 30)
            .request("patch", path: "/users/2", data: user)
            .hasStatus(.OK)
            .hasData(user)
            .has { _ in XCTAssertEqual(self.userStore[2]?.name, "David") }

            .request("patch", path: "/error/users/2", data: user)
            .hasStatus(.serviceUnavailable)
            .hasNoData()

            .request("patch", path: "/bodyerror/users/2", data: user)
            .hasStatus(.serviceUnavailable)
            .hasData(Status("BAD: 2"))

            .run()
    }

    func testJoinPath() {
        let router = Router()
        XCTAssertEqual(router.join(path: "a", with: "b"), "a/b")
        XCTAssertEqual(router.join(path: "a/", with: "/b"), "a/b")
        XCTAssertEqual(router.join(path: "a", with: "/b"), "a/b")
        XCTAssertEqual(router.join(path: "a/", with: "b"), "a/b")
    }

    // Test adding a trailing slash to your route when it has an implicit id parameter
    func testRouteWithTrailingSlash() {
        let status = Status("Slashes work as expected")
        router.get("/status/") { (id: Int, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, nil) }
        router.put("/status/") { (id: Int, status: Status, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, nil) }
        router.patch("/status/") { (id: Int, status: Status, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, nil) }
        router.delete("/status/") { (id: Int, respondWith: (RequestError?) -> Void) in respondWith(nil) }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/status/1").hasStatus(.OK).hasData(status)
            .request("put", path: "/status/1", data: status).hasStatus(.OK).hasData(status)
            .request("patch", path: "/status/1", data: status).hasStatus(.OK).hasData(status)
            .request("delete", path: "/status/1").hasStatus(.noContent).hasNoData()
            .run()
    }

    func testRouteParameters() {
        //Add this erroneous route which should not be hit by the test, should log an error but we can't test the log so we check for a 404 not found.
        let status = Status("Should not be seen")
        router.get("/status/:id") { (id: Int, respondWith: (Status?, RequestError?) -> Void) in
            print("GET on /status/:id that should not happen")
            respondWith(status, nil)
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/status/1")
            .hasStatus(.notFound)
            .hasData("Cannot GET /status/1.")
            .run()
    }

    // Test that we get an internalServerError when using BodyParser with a Codable route
    func testCodableRoutesWithBodyParsingFail() {
        // Add a BodyParser that covers everything
        router.all(middleware: BodyParser())

        let status = Status("Should not be seen")
        router.put("/status") { (id: Int, status: Status, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, nil) }
        router.patch("/status") { (id: Int, status: Status, respondWith: (Status?, RequestError?) -> Void) -> Void in respondWith(status, nil) }
        router.post("/status") { (status: Status, respondWith: (Status?, RequestError?) -> Void) -> Void in respondWith(status, nil) }

        buildServerTest(router, timeout: 30)
            .request("put", path: "/status/2", data: status).hasStatus(.internalServerError).hasNoData()
            .request("patch", path: "/status/2", data: status).hasStatus(.internalServerError).hasNoData()
            .request("post", path: "/status", data: status).hasStatus(.internalServerError).hasNoData()
            .run()
    }
}
