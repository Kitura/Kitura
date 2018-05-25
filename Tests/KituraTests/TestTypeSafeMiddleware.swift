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
            ("testSingleMiddlewarePost", testSingleMiddlewarePost),
            ("testMultipleMiddlewarePost", testMultipleMiddlewarePost),
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

        static func ==(lhs: User, rhs: User) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
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
            print("GET on /userMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
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
            print("GET on /userMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
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
    
    func testIdentifierSingleMiddlewareGetSingleton() {
        // Expected user: User(id: 1, name: "Andy")
        guard let user = userStore[1] else {
            print("no value found for userStore[1]")
            XCTFail()
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
    
    func testIdentifierMultipleMiddlewareGetSingleton() {
        // Expected user: User(id: 1, name: "Andy")
        guard let user = userStore[1] else {
            print("no value found for userStore[1]")
            XCTFail()
            return
        }
        
        router.get("/userMultiMiddleware") { (middleware: UserMiddleware, middleware2: UserMiddleware2, middleware3: UserMiddleware3, id: Int, respondWith: (User?, RequestError?) -> Void) in
            print("GET with identifier on /userMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
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
            print("GET Identifier Codable on /userMiddleware - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
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
            print("POST on /userMiddleware for user \(user) - received headers \(middleware.header), \(middleware2.header), \(middleware3.header)")
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
