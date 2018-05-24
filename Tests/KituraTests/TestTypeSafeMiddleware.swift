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
    
    // Tests that routes with single TypeSafeMiddlewares respond appropriately
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
    
    // Tests that routes with multiple TypeSafeMiddlewares respond appropriately
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
    
    static func describe() -> String {
        return "TestMiddleware"
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
    
    static func describe() -> String {
        return "TestMiddleware2"
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
    
    static func describe() -> String {
        return "TestMiddleware3"
    }
}
