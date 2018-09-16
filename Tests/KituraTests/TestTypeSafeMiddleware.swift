/**
 * Copyright IBM Corporation 2018
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

class TestTypeSafeMiddleware: KituraTest {
    static var allTests: [(String, (TestTypeSafeMiddleware) -> () throws -> Void)] {
        return [
            ("testSingleMiddlewareGetSingleton", testSingleMiddlewareGetSingleton),
            ("testMultipleMiddlewareGetSingleton", testMultipleMiddlewareGetSingleton),
            ("testSingleMiddlewareGetArray", testSingleMiddlewareGetArray),
            ("testMultipleMiddlewareGetArray", testMultipleMiddlewareGetArray),
            ("testSingleMiddlewareGetIdentifier", testSingleMiddlewareGetIdentifier),
            ("testMultipleMiddlewareGetIdentifier", testMultipleMiddlewareGetIdentifier),
            ("testSingleMiddlewareGetIdentifierCodableArray", testSingleMiddlewareGetIdentifierCodableArray),
            ("testMultipleMiddlewareGetIdentifierCodableArray", testMultipleMiddlewareGetIdentifierCodableArray),
            ("testSingleMiddlewareGetSingletonParameters", testSingleMiddlewareGetSingletonParameters),
            ("testMultipleMiddlewareGetSingletonParameters", testMultipleMiddlewareGetSingletonParameters),
            ("testSingleMiddlewareGetArrayParameters", testSingleMiddlewareGetArrayParameters),
            ("testSingleMiddlewareGetArrayOptionalParameters", testSingleMiddlewareGetArrayOptionalParameters),
            ("testMultipleMiddlewareGetArrayParameters", testMultipleMiddlewareGetArrayParameters),
            ("testMultipleMiddlewareGetArrayOptionalParameters", testMultipleMiddlewareGetArrayOptionalParameters),
            ("testSingleMiddlewareDelete", testSingleMiddlewareDelete),
            ("testMultipleMiddlewareDelete", testMultipleMiddlewareDelete),
            ("testSingleMiddlewareDeleteIdentifier", testSingleMiddlewareDeleteIdentifier),
            ("testMultipleMiddlewareDeleteIdentifier", testMultipleMiddlewareDeleteIdentifier),
            ("testSingleMiddlewareDeleteParameters", testSingleMiddlewareDeleteParameters),
            ("testSingleMiddlewareDeleteOptionalParameters", testSingleMiddlewareDeleteOptionalParameters),
            ("testMultipleMiddlewareDeleteParameters", testMultipleMiddlewareDeleteParameters),
            ("testMultipleMiddlewareDeleteOptionalParameters", testMultipleMiddlewareDeleteOptionalParameters),
            ("testSingleMiddlewarePost", testSingleMiddlewarePost),
            ("testMultipleMiddlewarePost", testMultipleMiddlewarePost),
            ("testSingleMiddlewarePostIdentifier", testSingleMiddlewarePostIdentifier),
            ("testMultipleMiddlewarePostIdentifier", testMultipleMiddlewarePostIdentifier),
            ("testSingleMiddlewarePut", testSingleMiddlewarePut),
            ("testMultipleMiddlewarePut", testMultipleMiddlewarePut),
            ("testSingleMiddlewarePatch", testSingleMiddlewarePatch),
            ("testMultipleMiddlewarePatch", testMultipleMiddlewarePatch),
            ("testCustomCoder", testCustomCoder),
            ("testCustomCoderGet", testCustomCoderGet),
        ]
    }

    // Need to initialise to avoid compiler error
    var router = Router()
    var userStore: [Int: User] = [:]

    // Reset for each test
    override func setUp() {
        router = Router()
        userStore = [1: User(id: 1, name: "Andy"), 2: User(id: 2, name: "Dave"), 3: User(id: 3, name: "Ian")]
    }

    struct User: Codable, Equatable {
        let id: Int
        let name: String

        init(id: Int, name: String) {
            self.id = id
            self.name = name
        }

        static func == (lhs: User, rhs: User) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
        }
    }
    
    struct CodableDate: Codable, Equatable {
        let date: Date
        
        init(date: Date) {
            self.date = date
        }
        static func == (lhs: CodableDate, rhs: CodableDate) -> Bool {
            return lhs.date == rhs.date
        }
    }

    struct MyQuery: QueryParams {
        let id: Int

        init(id: Int) {
            self.id = id
        }

        static func == (lhs: MyQuery, rhs: MyQuery) -> Bool {
            return lhs.id == rhs.id
        }
    }

    // A user-defined structure that can be used in a TypeSafeMiddleware context
    struct UserMiddleware: TestMiddleware {
        let header: String
    }

    // A user-defined structure that can be used in a TypeSafeMiddleware context
    struct UserMiddleware2: TestMiddleware2 {
        let header: String
    }

    // A user-defined structure that can be used in a TypeSafeMiddleware context
    struct UserMiddleware3: TestMiddleware3 {
        let header: String
    }

    func testSingleMiddlewareGetSingleton() {
        let user = User(id: 4, name: "Matt")

        router.get("/userMiddleware") { (middleware: UserMiddleware, respondWith: (User?, RequestError?) -> Void) in
            print("GET on /userMiddleware - received header \(middleware.header)")
            respondWith(user, nil)
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/userMiddleware", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .request("get", path: "/userMiddleware")
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testMultipleMiddlewareGetSingleton() {
        let user = User(id: 5, name: "Neil")

        router.get("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, respondWith: (User?, RequestError?) -> Void) in
            print("GET on /userMultiMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            respondWith(user, nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("get", path: "/userMultiMiddleware", headers: goodHeaders)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("get", path: "/userMultiMiddleware", headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("get", path: "/userMultiMiddleware", headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testSingleMiddlewareGetArray() {
        let userArray = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave")]

        router.get("/userMiddleware") { (middleware: UserMiddleware, respondWith: ([User]?, RequestError?) -> Void) in
            print("GET on /userMiddleware - received header \(middleware.header)")
            respondWith(userArray, nil)
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/userMiddleware", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(userArray)

            .request("get", path: "/userMiddleware")
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testMultipleMiddlewareGetArray() {
        let userArray = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave")]

        router.get("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, respondWith: ([User]?, RequestError?) -> Void) in
            print("GET on /userMultiMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            respondWith(userArray, nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("get", path: "/userMultiMiddleware", headers: goodHeaders)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(userArray)

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("get", path: "/userMultiMiddleware", headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("get", path: "/userMultiMiddleware", headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testSingleMiddlewareGetIdentifier() {
        // Expected user: User(id: 1, name: "Andy")
        guard let user = userStore[1] else {
            XCTFail("no value found for userStore[1]")
            return
        }

        router.get("/userMiddleware") { (middleware: UserMiddleware, id: Int, respondWith: (User?, RequestError?) -> Void) in
            print("GET with identifier on /userMiddleware - received header \(middleware.header)")
            let user = self.userStore[id]
            respondWith(user, nil)
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/userMiddleware/1", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .request("get", path: "/userMiddleware/1")
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testMultipleMiddlewareGetIdentifier() {
        // Expected user: User(id: 1, name: "Andy")
        guard let user = userStore[1] else {
            XCTFail("no value found for userStore[1]")
            return
        }

        router.get("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, id: Int, respondWith: (User?, RequestError?) -> Void) in
            print("GET with identifier: \(id) on /userMultiMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            respondWith(user, nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("get", path: "/userMultiMiddleware/1", headers: goodHeaders)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("get", path: "/userMultiMiddleware/1", headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("get", path: "/userMultiMiddleware/1", headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testSingleMiddlewareGetIdentifierCodableArray() {
        // Expected tuples [[1: User(id: 1, name: "Andy")], [2: User(id: 2, name: "Dave")], [3: User(id: 3, name: "Ian")]]
        var intTuple = [(Int, User)]()
        self.userStore.forEach { intTuple.append(($0.0, $0.1)) }
        let expectedIntData: [[String: User]] = intTuple.map({ [$0.value: $1] })

        router.get("/userMiddleware") { (middleware: UserMiddleware, respondWith: ([(Int, User)]?, RequestError?) -> Void) in
            print("GET Identifier Codable tuple on /userMiddleware - received header \(middleware.header)")
            var intTuple = [(Int, User)]()
            self.userStore.forEach { intTuple.append(($0.0, $0.1)) }
            respondWith(intTuple, nil)
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/userMiddleware", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(expectedIntData)

            .request("get", path: "/userMiddleware")
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testMultipleMiddlewareGetIdentifierCodableArray() {
        // Expected tuples [[1: User(id: 1, name: "Andy")], [2: User(id: 2, name: "Dave")], [3: User(id: 3, name: "Ian")]]
        var intTuple = [(Int, User)]()
        self.userStore.forEach { intTuple.append(($0.0, $0.1)) }
        let expectedIntData: [[String: User]] = intTuple.map({ [$0.value: $1] })

        router.get("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, respondWith: ([(Int, User)]?, RequestError?) -> Void) in
            print("GET Identifier Codable on /userMultiMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            var intTuple = [(Int, User)]()
            self.userStore.forEach { intTuple.append(($0.0, $0.1)) }
            respondWith(intTuple, nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("get", path: "/userMultiMiddleware", headers: goodHeaders)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(expectedIntData)

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("get", path: "/userMultiMiddleware", headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("get", path: "/userMultiMiddleware", headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testSingleMiddlewareGetSingletonParameters() {
        // Expected user: User(id: 1, name: "Andy")
        guard let user = userStore[1] else {
            XCTFail("no value found for userStore[1]")
            return
        }

        router.get("/userMiddleware") { (middleware: UserMiddleware, query: MyQuery, respondWith: (User?, RequestError?) -> Void) in
            print("GET single with parameters on /userMiddleware - received header \(middleware.header)")
            let user = self.userStore[query.id]
            respondWith(user, nil)
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/userMiddleware?id=1", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)
            
            .request("get", path: "/userMiddleware?id=1")
            .hasStatus(.badRequest)
            .hasNoData()
            
            .run()
    }

    func testMultipleMiddlewareGetSingletonParameters() {
        // Expected user: User(id: 1, name: "Andy")
        guard let user = userStore[1] else {
            XCTFail("no value found for userStore[1]")
            return
        }

        router.get("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, query: MyQuery, respondWith: (User?, RequestError?) -> Void) in
            print("GET single with parameters: \(query) on /userMultiMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            respondWith(user, nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("get", path: "/userMultiMiddleware?id=1", headers: goodHeaders)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("get", path: "/userMultiMiddleware?id=1", headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("get", path: "/userMultiMiddleware?id=1", headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testSingleMiddlewareGetArrayParameters() {
        let userArray = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave"), User(id: 3, name: "Ian")]
        let expectedArray = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave")]

        router.get("/userMiddleware") { (middleware: UserMiddleware, query: MyQuery, respondWith: ([User]?, RequestError?) -> Void) in
            print("GET array with parameters on /userMiddleware - received header \(middleware.header)")
            let matchedUsers = userArray.filter { $0.id <=  query.id }
            respondWith(matchedUsers, nil)
        }

        buildServerTest(router, timeout: 30)
            .request("get", path: "/userMiddleware?id=2", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(expectedArray)

            .request("get", path: "/userMiddleware?id=2")
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }
    
    func testSingleMiddlewareGetArrayOptionalParameters() {
        let userArray = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave"), User(id: 3, name: "Ian")]
        let expectedArray = [User(id: 2, name: "Dave")]
        
        router.get("/userMiddleware") { (middleware: UserMiddleware, query: MyQuery?, respondWith: ([User]?, RequestError?) -> Void) in
            print("GET array with optional parameters on /userMiddleware - received header \(middleware.header)")
            if let query = query {
                let matchedUsers = userArray.filter { $0.id == query.id }
                respondWith(matchedUsers, nil)
            } else {
                respondWith(userArray, nil)
            }
        }
        
        buildServerTest(router, timeout: 30)
            .request("get", path: "/userMiddleware?id=2", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(expectedArray)
            
            .request("get", path: "/userMiddleware", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(userArray)
            
            .request("get", path: "/userMiddleware?id=2")
            .hasStatus(.badRequest)
            .hasNoData()
            
            .run()
    }

    func testMultipleMiddlewareGetArrayParameters() {
        let userArray = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave"), User(id: 3, name: "Ian")]
        let expectedArray = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave")]

        router.get("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, query: MyQuery, respondWith: ([User]?, RequestError?) -> Void) in
            print("GET array with parameters on /userMultiMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            let matchedUsers = userArray.filter { $0.id <=  query.id }
            respondWith(matchedUsers, nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("get", path: "/userMultiMiddleware?id=2", headers: goodHeaders)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(expectedArray)

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("get", path: "/userMultiMiddleware?id=2", headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("get", path: "/userMultiMiddleware?id=2", headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }
    
    func testMultipleMiddlewareGetArrayOptionalParameters() {
        let userArray = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave"), User(id: 3, name: "Ian")]
        let expectedArray = [User(id: 2, name: "Dave")]
        
        router.get("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, query: MyQuery?, respondWith: ([User]?, RequestError?) -> Void) in
            print("GET array with optional parameters on /userMultiMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            if let query = query {
                let matchedUsers = userArray.filter { $0.id == query.id }
                respondWith(matchedUsers, nil)
            } else {
                respondWith(userArray, nil)
            }
        }
        
        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        
        buildServerTest(router, timeout: 30)
            .request("get", path: "/userMultiMiddleware?id=2", headers: goodHeaders)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(expectedArray)
            
            .request("get", path: "/userMultiMiddleware", headers: goodHeaders)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(userArray)
            
            .request("get", path: "/userMultiMiddleware?id=2")
            .hasStatus(.badRequest)
            .hasNoData()
            
            .run()
    }

    func testSingleMiddlewareDelete() {

        router.delete("/userMiddleware") { (middleware: UserMiddleware, respondWith: (RequestError?) -> Void) in
            print("DELETE on /userMiddleware - received header \(middleware.header)")
            self.userStore.removeAll()
            respondWith(nil)
        }

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/userMiddleware", headers: ["TestHeader": "Hello"])
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertEqual(self.userStore.count, 0) }

            .request("delete", path: "/userMiddleware")
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testMultipleMiddlewareDelete() {

        router.delete("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, respondWith: (RequestError?) -> Void) in
            print("DELETE on /userMultiMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            self.userStore.removeAll()
            respondWith(nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("delete", path: "/userMultiMiddleware", headers: goodHeaders)
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertEqual(self.userStore.count, 0) }

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("delete", path: "/userMultiMiddleware", headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("delete", path: "/userMultiMiddleware", headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testSingleMiddlewareDeleteIdentifier() {

        router.delete("/userMiddleware") { (middleware: UserMiddleware, id: Int, respondWith: (RequestError?) -> Void) in
            print("DELETE on /userMiddleware - received header \(middleware.header)")
            guard self.userStore.removeValue(forKey: id) != nil else {
                respondWith(.notFound)
                return
            }
            respondWith(nil)
        }

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/userMiddleware/1", headers: ["TestHeader": "Hello"])
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertNil(self.userStore[1]) }

            .request("delete", path: "/userMiddleware/1")
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testMultipleMiddlewareDeleteIdentifier() {

        router.delete("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, id: Int, respondWith: (RequestError?) -> Void) in
            print("DELETE on /userMultiMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            guard self.userStore.removeValue(forKey: id) != nil else {
                respondWith(.notFound)
                return
            }
            respondWith(nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("delete", path: "/userMultiMiddleware/1", headers: goodHeaders)
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertNil(self.userStore[1]) }

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("delete", path: "/userMultiMiddleware/1", headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("delete", path: "/userMultiMiddleware/1", headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testSingleMiddlewareDeleteParameters() {

        router.delete("/userMiddleware") { (middleware: UserMiddleware, query: MyQuery, respondWith: (RequestError?) -> Void) in
            print("DELETE on /userMiddleware - received header \(middleware.header)")
            guard self.userStore.removeValue(forKey: query.id) != nil else {
                respondWith(.notFound)
                return
            }
            respondWith(nil)
        }

        buildServerTest(router, timeout: 30)
            .request("delete", path: "/userMiddleware?id=1", headers: ["TestHeader": "Hello"])
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertNil(self.userStore[1]) }

            .request("delete", path: "/userMiddleware?id=1")
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }
    
    func testSingleMiddlewareDeleteOptionalParameters() {
        var userArray1 = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave"), User(id: 3, name: "Ian")]
        var userArray2 = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave"), User(id: 3, name: "Ian")]
        
        router.delete("/userMiddleware") { (middleware: UserMiddleware, query: MyQuery?, respondWith: (RequestError?) -> Void) in
            print("MY DELETE on /userMiddleware - received header \(middleware.header)")
            if let query = query {
                userArray1 = userArray1.filter { $0.id != query.id }
                respondWith(nil)
            } else {
                userArray2 = []
                respondWith(nil)
            }
        }
        
        buildServerTest(router, timeout: 30)
            .request("delete", path: "/userMiddleware?id=1", headers: ["TestHeader": "Hello"])
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertEqual(0, userArray1.filter { $0.id == 1 }.count) }
            .has { _ in XCTAssertEqual(1, userArray1.filter { $0.id == 2 }.count) }
            .has { _ in XCTAssertEqual(1, userArray1.filter { $0.id == 3 }.count) }
            
            .request("delete", path: "/userMiddleware", headers: ["TestHeader": "Hello"])
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertEqual(0, userArray2.filter { $0.id == 2 }.count) }
            .has { _ in XCTAssertEqual(0, userArray2.filter { $0.id == 3 }.count) }
            
            .run()
    }

    func testMultipleMiddlewareDeleteParameters() {

        router.delete("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, query: MyQuery, respondWith: (RequestError?) -> Void) in
            print("DELETE on /userMultiMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            guard self.userStore.removeValue(forKey: query.id) != nil else {
                respondWith(.notFound)
                return
            }
            respondWith(nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("delete", path: "/userMultiMiddleware?id=1", headers: goodHeaders)
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertNil(self.userStore[1]) }

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("delete", path: "/userMultiMiddleware?id=1", headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("delete", path: "/userMultiMiddleware?id=1", headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }
    
    func testMultipleMiddlewareDeleteOptionalParameters() {
        var userArray1 = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave"), User(id: 3, name: "Ian")]
        var userArray2 = [User(id: 1, name: "Andy"), User(id: 2, name: "Dave"), User(id: 3, name: "Ian")]
        
        router.delete("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, query: MyQuery?, respondWith: (RequestError?) -> Void) in
            print("DELETE on /userMultiMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            if let query = query {
                userArray1 = userArray1.filter { $0.id != query.id }
                respondWith(nil)
            } else {
                userArray2 = []
                respondWith(nil)
            }
        }
        
        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        
        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("delete", path: "/userMultiMiddleware?id=1", headers: goodHeaders)
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertEqual(0, userArray1.filter { $0.id == 1 }.count) }
            .has { _ in XCTAssertEqual(1, userArray1.filter { $0.id == 2 }.count) }
            .has { _ in XCTAssertEqual(1, userArray1.filter { $0.id == 3 }.count) }
            
            .request("delete", path: "/userMultiMiddleware", headers: goodHeaders)
            .hasStatus(.noContent)
            .hasNoData()
            .has { _ in XCTAssertEqual(0, userArray2.filter { $0.id == 2 }.count) }
            .has { _ in XCTAssertEqual(0, userArray2.filter { $0.id == 3 }.count) }
            
            .run()
    }

    func testSingleMiddlewarePost() {
        router.post("/userMiddleware") { (middleware: UserMiddleware, user: User, respondWith: (User?, RequestError?) -> Void) in
            print("POST on /userMiddleware for user \(user) - received header \(middleware.header)")
            self.userStore[user.id] = user
            respondWith(user, nil)
        }

        let user = User(id: 4, name: "Matt")

        buildServerTest(router, timeout: 30)
            .request("post", path: "/userMiddleware", data: user, headers: ["TestHeader": "Hello"])
            .hasStatus(.created)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .request("post", path: "/userMiddleware", data: user)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testMultipleMiddlewarePost() {
        router.post("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, user: User, respondWith: (User?, RequestError?) -> Void) in
            print("POST on /userMultiMiddleware for user \(user) - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            self.userStore[user.id] = user
            respondWith(user, nil)
        }

        let user = User(id: 5, name: "Neil")
        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("post", path: "/userMultiMiddleware", data: user, headers: goodHeaders)
            .hasStatus(.created)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("post", path: "/userMultiMiddleware", data: user, headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("post", path: "/userMultiMiddleware", data: user, headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testSingleMiddlewarePostIdentifier() {
        // Expected user: User(id: 1, name: "Andy")
        guard let user = userStore[1] else {
            XCTFail("no value found for userStore[1]")
            return
        }

        router.post("/userMiddleware") { (middleware: UserMiddleware, user: User, respondWith: (Int?, User?, RequestError?) -> Void) in
            print("POST with identifier on /userMiddleware for user \(user) - received header \(middleware.header)")
            let id = 1
            self.userStore[id] = user
            respondWith(id, user, nil)
        }

        buildServerTest(router, timeout: 30)
            .request("post", path: "/userMiddleware", data: user, headers: ["TestHeader": "Hello"])
            .hasStatus(.created)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .request("post", path: "/userMiddleware", data: user)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testMultipleMiddlewarePostIdentifier() {
        // Expected user: User(id: 1, name: "Andy")
        guard let user = userStore[1] else {
            XCTFail("no value found for userStore[1]")
            return
        }

        router.post("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, user: User, respondWith: (Int?, User?, RequestError?) -> Void) in
            print("POST on /userMultiMiddleware for user \(user) - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            let id = 1
            self.userStore[id] = user
            respondWith(id, user, nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("post", path: "/userMultiMiddleware", data: user, headers: goodHeaders)
            .hasStatus(.created)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("post", path: "/userMultiMiddleware", data: user, headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("post", path: "/userMultiMiddleware", data: user, headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testSingleMiddlewarePut() {
        let user = User(id: 1, name: "NewUser")

        router.put("/userMiddleware") { (middleware: UserMiddleware, id: Int, user: User, respondWith: (User?, RequestError?) -> Void) in
            print("PUT on /userMiddleware for user \(user) - received header \(middleware.header)")
            self.userStore[user.id] = user
            respondWith(user, nil)
        }

        buildServerTest(router, timeout: 30)
            .request("put", path: "/userMiddleware/1", data: user, headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .request("put", path: "/userMiddleware/1", data: user)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testMultipleMiddlewarePut() {
        let user = User(id: 1, name: "NewUser")

        router.put("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, id: Int, user: User, respondWith: (User?, RequestError?) -> Void) in
            print("PUT on /userMultiMiddleware for user \(user) - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            self.userStore[user.id] = user
            respondWith(user, nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("put", path: "/userMultiMiddleware/1", data: user, headers: goodHeaders)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("put", path: "/userMultiMiddleware/1", data: user, headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("put", path: "/userMultiMiddleware/1", data: user, headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testSingleMiddlewarePatch() {
        let user = User(id: 1, name: "NewUser")

        router.patch("/userMiddleware") { (middleware: UserMiddleware, id: Int, user: User, respondWith: (User?, RequestError?) -> Void) in
            print("PATCH on /userMiddleware for user \(user) - received header \(middleware.header)")
            self.userStore[user.id] = user
            respondWith(user, nil)
        }

        buildServerTest(router, timeout: 30)
            .request("patch", path: "/userMiddleware/1", data: user, headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            .request("patch", path: "/userMiddleware/1", data: user)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }

    func testMultipleMiddlewarePatch() {
        let user = User(id: 1, name: "NewUser")

        router.patch("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, id: Int, user: User, respondWith: (User?, RequestError?) -> Void) in
            print("PATCH on /userMultiMiddleware for user \(user) - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
            self.userStore[user.id] = user
            respondWith(user, nil)
        }

        let goodHeaders = ["TestHeader": "Foo", "TestHeader2": "Bar", "TestHeader3": "Baz"]
        let missing2ndHeader = ["TestHeader": "Foo", "TestHeader3": "Baz"]
        let missing3rdHeader = ["TestHeader": "Foo", "TestHeader2": "Bar"]

        buildServerTest(router, timeout: 30)
            // Test that handler is invoked successfully when all middlewares are satisfied
            .request("patch", path: "/userMultiMiddleware/1", data: user, headers: goodHeaders)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(user)

            // Test that Middleware2 fails when its header is missing, by examining the status (.notAcceptable)
            .request("patch", path: "/userMultiMiddleware/1", data: user, headers: missing2ndHeader)
            .hasStatus(.notAcceptable)
            .hasNoData()

            // Test that Middleware3 fails when its header is missing, by examining the status (.badRequest)
            .request("patch", path: "/userMultiMiddleware/1", data: user, headers: missing3rdHeader)
            .hasStatus(.badRequest)
            .hasNoData()

            .run()
    }
    
    func testCustomCoderGet() {
        struct SimpleQuery: QueryParams {
            let string: String
        }
        let jsonEncoder: () -> BodyEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            return encoder
        }
        let jsonDecoder: () -> BodyDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return decoder
        }
        let customRouter = Router()
        customRouter.decoders[.json] = jsonDecoder
        customRouter.encoders[.json] = jsonEncoder

        let date = Date(timeIntervalSince1970: 1519206456)
        let codableDate = CodableDate(date: date)

        customRouter.get("/customCoder2") { (middleware: UserMiddleware, middleware2: UserMiddleware, respondWith: (CodableDate?, RequestError?) -> Void) in
        print("GET on /customCoder")
        respondWith(codableDate, nil)
        }
        customRouter.get("/customCoderArray2") { (middleware: UserMiddleware, middleware2: UserMiddleware, respondWith: ([CodableDate]?, RequestError?) -> Void) in
        print("GET on /customCoderArray")
        respondWith([codableDate], nil)
        }
        customRouter.get("/customCoderTuple2") { (middleware: UserMiddleware, middleware2: UserMiddleware, respondWith: ([(Int, CodableDate)]?, RequestError?) -> Void) in
        print("GET on /customCoderTuple")
        respondWith([(1, codableDate)], nil)
        }
        customRouter.get("/customCoderQuery2") { (middleware: UserMiddleware, middleware2: UserMiddleware, query: SimpleQuery, respondWith: (CodableDate?, RequestError?) -> Void) in
        print("GET on /customCoderQuery")
        respondWith(codableDate, nil)
        }
        customRouter.get("/customCoderQueryArray2") { (middleware: UserMiddleware, middleware2: UserMiddleware, query: SimpleQuery, respondWith: ([CodableDate]?, RequestError?) -> Void) in
        print("GET on /customCoderQueryArray")
        respondWith([codableDate], nil)
        }

        
        buildServerTest(customRouter, timeout: 30)

            .request("get", path: "/customCoder2", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(codableDate, customDecoder: jsonDecoder)

            .request("get", path: "/customCoderArray2", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData([codableDate], customDecoder: jsonDecoder)

            .request("get", path: "/customCoderTuple2", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData([["1": codableDate]], customDecoder: jsonDecoder)

            .request("get", path: "/customCoderQuery2?string=hello", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(codableDate, customDecoder: jsonDecoder)

            .request("get", path: "/customCoderQueryArray2?string=hello", headers: ["TestHeader": "Hello"])
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData([codableDate], customDecoder: jsonDecoder)

            .run()
    }
    
    func testCustomCoder() {
        struct SimpleQuery: QueryParams {
            let string: String
        }
        let jsonEncoder: () -> BodyEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            return encoder
        }
        let jsonDecoder: () -> BodyDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return decoder
        }
        let customRouter = Router()
        customRouter.decoders[.json] = jsonDecoder
        customRouter.encoders[.json] = jsonEncoder
        
        let date = Date(timeIntervalSince1970: 1519206456)
        let codableDate = CodableDate(date: date)

        customRouter.post("/customCoder2") { (middleware: UserMiddleware, middleware2: UserMiddleware, inDate: CodableDate, respondWith: (CodableDate?, RequestError?) -> Void) in
            print("POST on /customCoder for date \(inDate)")
            XCTAssertEqual(inDate, codableDate)
            respondWith(codableDate, nil)
        }
        customRouter.post("/customCoderId2") { (middleware: UserMiddleware, middleware2: UserMiddleware, inDate: CodableDate, respondWith: (Int?, CodableDate?, RequestError?) -> Void) in
            print("POST on /customCoderId for user \(inDate)")
            XCTAssertEqual(inDate, codableDate)
            respondWith(1, codableDate, nil)
        }
        customRouter.put("/customCoder2") { (middleware: UserMiddleware, middleware2: UserMiddleware, id: Int, inDate: CodableDate, respondWith: (CodableDate?, RequestError?) -> Void) in
            print("PUT on /customCoder/\(id)")
            XCTAssertEqual(inDate, codableDate)
            respondWith(codableDate, nil)
        }
        customRouter.patch("/customCoder2") { (middleware: UserMiddleware, middleware2: UserMiddleware, id: Int, inDate: CodableDate, respondWith: (CodableDate?, RequestError?) -> Void) in
            print("PATCH on /customCoder/\(id)")
            XCTAssertEqual(inDate, codableDate)
            respondWith(codableDate, nil)
        }
        
        buildServerTest(customRouter, timeout: 30)

            .request("post", path: "/customCoder2", data: codableDate, headers: ["TestHeader": "Hello"], encoder: jsonEncoder)
            .hasStatus(.created)
            .hasContentType(withPrefix: "application/json")
            .hasData(codableDate, customDecoder: jsonDecoder)

            .request("post", path: "/customCoderId2", data: codableDate, headers: ["TestHeader": "Hello"], encoder: jsonEncoder)
            .hasStatus(.created)
            .hasContentType(withPrefix: "application/json")
            .hasData(codableDate, customDecoder: jsonDecoder)

            .request("put", path: "/customCoder2/1", data: codableDate, headers: ["TestHeader": "Hello"], encoder: jsonEncoder)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(codableDate, customDecoder: jsonDecoder)

            .request("patch", path: "/customCoder2/1", data: codableDate, headers: ["TestHeader": "Hello"], encoder: jsonEncoder)
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(codableDate, customDecoder: jsonDecoder)

            .run()
    }
}

protocol TestMiddleware: TypeSafeMiddleware {
    var header: String { get }
    init(header: String)
}

extension TestMiddleware {
    static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (Self?, RequestError?) -> Void) {
        guard let expectedHeader = request.headers["TestHeader"] else {
            return completion(nil, .badRequest)
        }
        let selfInstance: Self = Self(header: expectedHeader)
        completion(selfInstance, nil)
    }
}

protocol TestMiddleware2: TypeSafeMiddleware {
    var header: String { get }
    init(header: String)
}

extension TestMiddleware2 {
    static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (Self?, RequestError?) -> Void) {
        guard let expectedHeader = request.headers["TestHeader2"] else {
            return completion(nil, .notAcceptable)
        }
        let selfInstance: Self = Self(header: expectedHeader)
        completion(selfInstance, nil)
    }
}

protocol TestMiddleware3: TypeSafeMiddleware {
    var header: String { get }
    init(header: String)
}

extension TestMiddleware3 {
    static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (Self?, RequestError?) -> Void) {
        guard let expectedHeader = request.headers["TestHeader3"] else {
            return completion(nil, .badRequest)
        }
        let selfInstance: Self = Self(header: expectedHeader)
        completion(selfInstance, nil)
    }
}
