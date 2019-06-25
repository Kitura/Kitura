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

final class TestCodableRouter: KituraTest, KituraTestSuite {
    static var allTests: [(String, (TestCodableRouter) -> () throws -> Void)] {
        return [
            ("testBasicPost", testBasicPost),  // Slow compile on 5.1
        ]
    }

    // Need to initialise to avoid compiler error
    var router = Router()

    // Reset for each test
    override func setUp() {
        super.setUp()           // Initialize logging
        router = Router()
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

    // This takes a very long time to compile on Swift 5.1 snapshots
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

}
