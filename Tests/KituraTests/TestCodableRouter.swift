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

class TestCodableRouter: KituraTest {
    static var allTests: [(String, (TestCodableRouter) -> () throws -> Void)] {
        return [
            ("testBasicPost", testBasicPost),
            ("testBasicPostIdentifier", testBasicPostIdentifier),
            ("testBasicGetSingleton", testBasicGetSingleton),
            ("testBasicGetArray", testBasicGetArray),
            ("testBasicGetSingle", testBasicGetSingle),
            ("testBasicGetIdentifiersArray", testBasicGetIdentifiersArray),
            ("testBasicDelete", testBasicDelete),
            ("testBasicDeleteSingle", testBasicDeleteSingle),
            ("testBasicPut", testBasicPut),
            ("testBasicPatch", testBasicPatch),
            ("testJoinPath", testJoinPath),
            ("testRouteWithTrailingSlash", testRouteWithTrailingSlash),
            ("testErrorOverridesBody", testErrorOverridesBody),
            ("testRouteParameters", testRouteParameters),
            ("testCodableRoutesWithBodyParsingFail", testCodableRoutesWithBodyParsingFail),
            ("testCodableGetSingleQueryParameters", testCodableGetSingleQueryParameters),
            ("testCodableGetArrayQueryParameters", testCodableGetArrayQueryParameters),
            ("testCodableDeleteQueryParameters", testCodableDeleteQueryParameters),
            ("testCodablePostSuccessStatuses", testCodablePostSuccessStatuses),
            ("testNoDataCustomStatus", testNoDataCustomStatus),
            ("testNoDataDefaultStatus", testNoDataDefaultStatus)
        ]
    }

    // Need to initialise to avoid compiler error
    var router = Router()
    var userStore: [Int: User] = [:]

    // Reset for each test
    override func setUp() {
        super.setUp()           // Initialize logging
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

    struct MyQuery: QueryParams, Equatable {
        public let intField: Int
        public let optionalIntField: Int?
        public let stringField: String
        public let intArray: [Int]
        public let dateField: Date
        public let optionalDateField: Date?
        public let nested: Nested

        public static func ==(lhs: MyQuery, rhs: MyQuery) -> Bool {
            return  lhs.intField == rhs.intField &&
                lhs.optionalIntField == rhs.optionalIntField &&
                lhs.stringField == rhs.stringField &&
                lhs.intArray == rhs.intArray &&
                lhs.dateField.timeIntervalSince1970 == rhs.dateField.timeIntervalSince1970 &&
                lhs.optionalDateField?.timeIntervalSince1970 == rhs.optionalDateField?.timeIntervalSince1970 &&
                lhs.nested == rhs.nested
        }
    }

    struct Nested: Codable, Equatable {
        public let nestedIntField: Int
        public let nestedStringField: String

        public static func ==(lhs: Nested, rhs: Nested) -> Bool {
            return lhs.nestedIntField == rhs.nestedIntField && lhs.nestedStringField == rhs.nestedStringField
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
        router.post("/bodyerror/users") { (user: User, respondWith: (User?, RequestError?) -> Void) in
            print("POST on /bodyerror/users for user \(user)")
            respondWith(nil, RequestError(.conflict, body: Conflict(on: "id")))
        }
        router.post("/urlencoded") { (user: User, respondWith: (User?, RequestError?) -> Void) in
            print("POST on /urlencoded for user \(user)")
            respondWith(user, nil)
        }

        let user = User(id: 4, name: "David")
        buildServerTest(router, timeout: 30)
            .request("post", path: "/users", data: user)
            .hasStatus(.created)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .request("post", path: "/error/users", data: user)
            .hasStatus(.conflict)
            .hasNoData()

            .request("post", path: "/bodyerror/users", data: user)
            .hasStatus(.conflict)
            .hasContentType(withPrefix: "application/json")
            .hasData(Conflict(on: "id"))
            
            .request("post", path: "/urlencoded", urlEncodedString: "id=4&name=David")
            .hasStatus(.created)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)
            
            .request("post", path: "/urlencoded", urlEncodedString: "id=4&name=David&extra=yes")
            .hasStatus(.created)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)
            
            .request("post", path: "/urlencoded", urlEncodedString: "encoding=valid&failed=match")
            .hasStatus(.unprocessableEntity)
            .hasData()
            
            .request("post", path: "/urlencoded", urlEncodedString: "invalidEncoding")
            .hasStatus(.unprocessableEntity)
            .hasData()
            


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
        router.post("/bodyerror/users") { (user: User, respondWith: (Int?, User?, RequestError?) -> Void) in
            print("POST on /bodyerror/users for user \(user)")
            respondWith(nil, nil, RequestError(.conflict, body: Conflict(on: "id")))
        }

        let user = User(id: 4, name: "David")
        buildServerTest(router, timeout: 30)
            .request("post", path: "/users", data: user)
            .hasStatus(.created)
            .hasHeader("Location", only: String(user.id))
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .request("post", path: "/error/users", data: user)
            .hasStatus(.conflict)
            .hasNoData()

            .request("post", path: "/bodyerror/users", data: user)
            .hasStatus(.conflict)
            .hasContentType(withPrefix: "application/json")
            .hasData(Conflict(on: "id"))

            .run()
    }

    func testBasicGetSingleton() {
        router.get("/status") { (respondWith: (Status?, RequestError?) -> Void) in
            print("GET on /status")
            respondWith(Status("GOOD"), nil)
        }
        router.get("/error/status") { (respondWith: (Status?, RequestError?) -> Void) in
            print("GET on /error/status")
            respondWith(nil, .serviceUnavailable)
        }
        router.get("/bodyerror/status") { (respondWith: (Status?, RequestError?) -> Void) in
            print("GET on /bodyerror/status")
            respondWith(nil, RequestError(.serviceUnavailable, body: Status("BAD")))
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/status")
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(Status("GOOD"))

            .request("get", path: "/error/status")
            .hasStatus(.serviceUnavailable)
            .hasNoData()

            .request("get", path: "/bodyerror/status")
            .hasStatus(.serviceUnavailable)
            .hasContentType(withPrefix: "application/json")
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
        router.get("/bodyerror/users") { (respondWith: ([User]?, RequestError?) -> Void) in
            print("GET on /bodyerror/users")
            respondWith(nil, RequestError(.serviceUnavailable, body: Status("BAD")))
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/users")
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(self.userStore.map({ $0.value }))

            .request("get", path: "/error/users")
            .hasStatus(.serviceUnavailable)
            .hasNoData()

            .request("get", path: "/bodyerror/users")
            .hasStatus(.serviceUnavailable)
            .hasContentType(withPrefix: "application/json")
            .hasData(Status("BAD"))

            .run()
    }

    func testBasicGetIdentifiersArray() {
        var intTuple = [(Int, User)]()
        self.userStore.forEach { intTuple.append(($0.0, $0.1)) }
        let expectedIntData: [[String: User]] = intTuple.map({ [$0.value: $1] })
        
        var stringTuple = [(String, User)]()
        self.userStore.forEach { stringTuple.append((String($0.0), $0.1)) }
        let expectedStringData: [[String: User]] = stringTuple.map({ [$0.value: $1] })
        
        router.get("/int/users") { (respondWith: ([(Int, User)]?, RequestError?) -> Void) in
            print("GET on /int/users")
            respondWith(intTuple, nil)
        }
        
        router.get("/int/explicitStatus") { (respondWith: ([(Int, User)]?, RequestError?) -> Void) in
            print("GET on /int/explicitStatus")
            respondWith(intTuple, .ok)
        }
        
        router.get("/string/users") { (respondWith: ([(String, User)]?, RequestError?) -> Void) in
            print("GET on /string/users")
            respondWith(stringTuple, nil)
        }
        
        router.get("/error/users") { (respondWith: ([(String, User)]?, RequestError?) -> Void) in
            print("GET on /error/users")
            respondWith(nil, .serviceUnavailable)
        }
        
        buildServerTest(router, timeout: 30)
            .request("get", path: "/int/users")
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(expectedIntData)
        
            .request("get", path: "/int/explicitStatus")
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(expectedIntData)
        
            .request("get", path: "/string/users")
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(expectedStringData)
            
            .request("get", path: "/error/users")
            .hasStatus(.serviceUnavailable)
            .hasNoData()
            
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
        router.get("/bodyerror/users") { (id: Int, respondWith: (User?, RequestError?) -> Void) in
            print("GET on /bodyerror/users/\(id)")
            respondWith(nil, RequestError(.serviceUnavailable, body: Status("BAD: \(id)")))
        }

        guard let user = self.userStore[1] else {
            XCTFail("ERROR!!! Couldn't find user with id 1")
            return
        }
        buildServerTest(router, timeout: 30)
            .request("get", path: "/users/1")
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .request("get", path: "/error/users/1")
            .hasStatus(.serviceUnavailable)
            .hasNoData()

            .request("get", path: "/bodyerror/users/1")
            .hasStatus(.serviceUnavailable)
            .hasContentType(withPrefix: "application/json")
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
        router.delete("/bodyerror/users") { (respondWith: (RequestError?) -> Void) in
            print("DELETE on /bodyerror/users")
            respondWith(RequestError(.serviceUnavailable, body: Status("BAD")))
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
            .hasContentType(withPrefix: "application/json")
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
        router.delete("/bodyerror/users") { (id: Int, respondWith: (RequestError?) -> Void) in
            print("DELETE on /bodyerror/users/\(id)")
            respondWith(RequestError(.serviceUnavailable, body: Status("BAD: \(id)")))
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
            .hasContentType(withPrefix: "application/json")
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
        router.put("/bodyerror/users") { (id: Int, user: User, respondWith: (User?, RequestError?) -> Void) in
            print("PUT on /bodyerror/users/\(id)")
            respondWith(nil, RequestError(.serviceUnavailable, body: Status("BAD: \(id)")))
        }

        XCTAssertEqual(self.userStore[1]?.name, "Mike")

        let user = User(id: 1, name: "David")
        buildServerTest(router, timeout: 30)
            .request("put", path: "/users/1", data: user)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)
            .has { _ in XCTAssertEqual(self.userStore[1]?.name, "David") }

            .request("put", path: "/error/users/1", data: user)
            .hasStatus(.serviceUnavailable)
            .hasNoData()

            .request("put", path: "/bodyerror/users/1", data: user)
            .hasStatus(.serviceUnavailable)
            .hasContentType(withPrefix: "application/json")
            .hasData(Status("BAD: 1"))

            .run()
    }

    // Tests that a handler is able to return a nil response with a custom success status.
    func testNoDataCustomStatus() {
        router.put("/noBody") { (id: Int, data: User, respondWith: (User?, RequestError?) -> Void) in
            print("PUT on /noBody/\(id)")
            respondWith(nil, .noContent)
        }
        router.post("/noBody") { (data: User, respondWith: (Int?, User?, RequestError?) -> Void) in
            print("POST on /noBody")
            respondWith(1, nil, .noContent)
        }
        
        let user = User(id: 1, name: "David")
        buildServerTest(router, timeout: 30)

            .request("post", path: "/noBody", data: user)
            .hasStatus(.noContent)
            .hasHeader("Location", only: "1")
            .hasNoData()
            
            .request("put", path: "/noBody/1", data: user)
            .hasStatus(.noContent)
            .hasNoData()
            
            .run()
    }

    // Tests that a handler is able to return a nil response with the default success status
    // for that method.
    func testNoDataDefaultStatus() {
        router.put("/noBody") { (id: Int, data: User, respondWith: (User?, RequestError?) -> Void) in
            print("PUT on /noBody/\(id)")
            respondWith(nil, nil)
        }
        router.post("/noBody") { (data: User, respondWith: (Int?, User?, RequestError?) -> Void) in
            print("POST on /noBody")
            respondWith(1, nil, nil)
        }
        
        let user = User(id: 1, name: "David")
        buildServerTest(router, timeout: 30)

            .request("post", path: "/noBody", data: user)
            .hasStatus(.created)
            .hasHeader("Location", only: "1")
            .hasNoData()
            
            .request("put", path: "/noBody/1", data: user)
            .hasStatus(.OK)
            .hasNoData()
            
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
        router.patch("/bodyerror/users") { (id: Int, patchUser: OptionalUser, respondWith: (User?, RequestError?) -> Void) -> Void in
            print("PATCH on /bodyerror/users/\(id)")
            respondWith(nil, RequestError(.serviceUnavailable, body: Status("BAD: \(id)")))
        }

        XCTAssertEqual(self.userStore[2]?.name, "Chris")

        let user = User(id: 2, name: "David")
        buildServerTest(router, timeout: 30)
            .request("patch", path: "/users/2", data: user)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)
            .has { _ in XCTAssertEqual(self.userStore[2]?.name, "David") }

            .request("patch", path: "/error/users/2", data: user)
            .hasStatus(.serviceUnavailable)
            .hasNoData()

            .request("patch", path: "/bodyerror/users/2", data: user)
            .hasStatus(.serviceUnavailable)
            .hasContentType(withPrefix: "application/json")
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
            .request("get", path: "/status/1").hasStatus(.OK).hasContentType(withPrefix: "application/json").hasData(status)
            .request("put", path: "/status/1", data: status).hasStatus(.OK).hasContentType(withPrefix: "application/json").hasData(status)
            .request("patch", path: "/status/1", data: status).hasStatus(.OK).hasContentType(withPrefix: "application/json").hasData(status)
            .request("delete", path: "/status/1").hasStatus(.noContent).hasNoData()
            .run()
    }

    func testErrorOverridesBody() {
        let status = Status("This should not be sent")
        router.get("/status") { (id: Int, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, .conflict) }
        router.post("/status") { (status: Status, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, .conflict) }
        router.put("/status") { (id: Int, status: Status, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, .conflict) }
        router.patch("/status") { (id: Int, status: Status, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, .conflict) }

        let conflict = Conflict(on: "life")
        let bodyError = RequestError(.conflict, body: conflict)
        router.get("/bodyerror/status") { (id: Int, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, bodyError) }
        router.post("/bodyerror/status") { (status: Status, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, bodyError) }
        router.put("/bodyerror/status") { (id: Int, status: Status, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, bodyError) }
        router.patch("/bodyerror/status") { (id: Int, status: Status, respondWith: (Status?, RequestError?) -> Void) in respondWith(status, bodyError) }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/status/1")
            .hasStatus(.conflict)
            .hasNoData()

            .request("post", path: "/status", data: status)
            .hasStatus(.conflict)
            .hasNoData()

            .request("put", path: "/status/1", data: status)
            .hasStatus(.conflict)
            .hasNoData()

            .request("patch", path: "/status/1", data: status)
            .hasStatus(.conflict)
            .hasNoData()

            .request("get", path: "/bodyerror/status/1")
            .hasStatus(.conflict)
            .hasContentType(withPrefix: "application/json")
            .hasData(conflict)

            .request("post", path: "/bodyerror/status", data: status)
            .hasStatus(.conflict)
            .hasContentType(withPrefix: "application/json")
            .hasData(conflict)

            .request("put", path: "/bodyerror/status/1", data: status)
            .hasStatus(.conflict)
            .hasContentType(withPrefix: "application/json")
            .hasData(conflict)

            .request("patch", path: "/bodyerror/status/1", data: status)
            .hasStatus(.conflict)
            .hasContentType(withPrefix: "application/json")
            .hasData(conflict)

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
            .hasData()
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

    func testCodableGetSingleQueryParameters() {
        let date: Date = Coder().dateFormatter.date(from: Coder().dateFormatter.string(from: Date()))!

        let expectedQuery = MyQuery(intField: 23, optionalIntField: 282, stringField: "a string", intArray: [1, 2, 3], dateField: date, optionalDateField: date, nested: Nested(nestedIntField: 333, nestedStringField: "nested string"))

        guard let queryStr: String = try? QueryEncoder().encode(expectedQuery) else {
            XCTFail("ERROR!!! Could not encode query object to string")
            return
        }

        router.get("/query") { (query: MyQuery, respondWith: (MyQuery?, RequestError?) -> Void) in
            XCTAssertEqual(query, expectedQuery)
            respondWith(query, nil)
        }

        router.get("/optionalquery") { (query: MyQuery?, respondWith: (MyQuery?, RequestError?) -> Void) in
            if let query = query {
                XCTAssertEqual(query, expectedQuery)
                respondWith(query, nil)
            } else {
                respondWith(nil, nil)
            }
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/query\(queryStr)")
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(expectedQuery)

            .request("get", path: "/query?param=badRequest")
            .hasStatus(.badRequest)
            .hasNoData()

            .request("get", path: "/optionalquery\(queryStr)")
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(expectedQuery)

            .request("get", path: "/optionalquery")
            .hasStatus(.OK)
            .hasNoData()

            .request("get", path: "/optionalquery?param=badRequest")
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testCodableGetArrayQueryParameters() {
        /// Currently the milliseconds are cut off by our date formatter
        /// This synchronizes it for testing with the codable route
        let date: Date = Coder().dateFormatter.date(from: Coder().dateFormatter.string(from: Date()))!

        let expectedQuery = MyQuery(intField: 23, optionalIntField: 282, stringField: "a string", intArray: [1, 2, 3], dateField: date, optionalDateField: date, nested: Nested(nestedIntField: 333, nestedStringField: "nested string"))

        guard let queryStr: String = try? QueryEncoder().encode(expectedQuery) else {
            XCTFail("ERROR!!! Could not encode query object to string")
            return
        }

        router.get("/query") { (query: MyQuery, respondWith: ([MyQuery]?, RequestError?) -> Void) in
            XCTAssertEqual(query, expectedQuery)
            respondWith([query], nil)
        }

        router.get("/optionalquery") { (query: MyQuery?, respondWith: ([MyQuery]?, RequestError?) -> Void) in
            if let query = query {
                XCTAssertEqual(query, expectedQuery)
                respondWith([query], nil)
            } else {
                respondWith(nil, nil)
            }
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/query\(queryStr)")
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData([expectedQuery])

            .request("get", path: "/optionalquery\(queryStr)")
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData([expectedQuery])

            .request("get", path: "/optionalquery")
            .hasStatus(.OK)
            .hasNoData()

            .request("get", path: "/query?param=badRequest")
            .hasStatus(.badRequest)
            .hasNoData()

            .request("get", path: "/optionalquery?param=badRequest")
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testCodableDeleteQueryParameters() {
        /// Currently the milliseconds are cut off by our date formatter
        /// This synchronizes it for testing with the codable route
        let date: Date = Coder().dateFormatter.date(from: Coder().dateFormatter.string(from: Date()))!

        let expectedQuery = MyQuery(intField: 23, optionalIntField: 282, stringField: "a string", intArray: [1, 2, 3], dateField: date, optionalDateField: date, nested: Nested(nestedIntField: 333, nestedStringField: "nested string"))

        guard let queryStr: String = try? QueryEncoder().encode(expectedQuery) else {
            XCTFail("ERROR!!! Could not encode query object to string")
            return
        }

        router.delete("/query") { (query: MyQuery, respondWith: (RequestError?) -> Void) in
            XCTAssertEqual(query, expectedQuery)
            respondWith(nil)
        }

        router.delete("/optionalquery") { (query: MyQuery?, respondWith: (RequestError?) -> Void) in
            if let query = query {
                XCTAssertEqual(query, expectedQuery)
            }
            respondWith(nil)
        }

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/query\(queryStr)")
            .hasStatus(.noContent)
            .hasNoData()

            .request("delete", path: "/query?param=badRequest")
            .hasStatus(.badRequest)
            .hasNoData()

            .request("delete", path: "/optionalquery\(queryStr)")
            .hasStatus(.noContent)
            .hasNoData()

            .request("delete", path: "/optionalquery")
            .hasStatus(.noContent)
            .hasNoData()

            .request("delete", path: "/optionalquery?param=badRequest")
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testCodablePostSuccessStatuses() {
        // Test POST success statuses other than .created
        router.post("/ok") { (user: User, respondWith: (User?, RequestError?) -> Void) in
            print("POST on /ok for user \(user)")
            respondWith(user, .ok)
        }
        router.post("/partialContent") { (user: User, respondWith: (User?, RequestError?) -> Void) in
            print("POST on /partialContent for user \(user)")
            respondWith(user, .partialContent)
        }
        router.post("/okId") { (user: User, respondWith: (Int?, User?, RequestError?) -> Void) in
            print("POST on /okId for user \(user)")
            respondWith(user.id, user, .ok)
        }

        let user = User(id: 5, name: "Jane")
        buildServerTest(router, timeout: 30)//
            .request("post", path: "/ok", data: user)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .request("post", path: "/partialContent", data: user)
            .hasStatus(.partialContent)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .request("post", path: "/okId", data: user)
            .hasStatus(.OK)
            .hasHeader("Location", only: String(user.id))
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .run()
    }
}
