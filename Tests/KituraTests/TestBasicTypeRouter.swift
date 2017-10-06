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
import Dispatch

@testable import Kitura
@testable import KituraNet

class TestBasicTypeRouter: KituraTest {
    static var allTests: [(String, (TestBasicTypeRouter) -> () throws -> Void)] {
        return [
            //("testBasicPost", testBasicPost),
        ]
    }
    
    let router = Router()
    
    struct User: Codable {
        let id: Int?
        let name: String
        init(id: Int, name: String) {
            self.id = id
            self.name = name
        }
        
    }
    
    var nextID: Int = 4
    var userStore: [Int: User] = [1: User(id: 1, name: "Mike"), 2: User(id: 2, name: "Chris"), 3: User(id: 3, name: "Ricardo")]
    
    func testBasicPost() {

        router.post("/users") { (user: User, respondWith: (User) -> Void) in

            print("POST on /users for user \(user)")
            let id = self.nextID
            self.nextID += 1
            self.userStore[id] = user
            
            respondWith(User(id: id, name: user.name))
        }
        performServerTest(router, timeout: 30) { expectation in
            let userString = "{\"name\": \"David\"}"
            let userData = userString.data(using: .utf8)!
            
            self.performRequest("post", path: "/users", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                if let response = response {
                    XCTAssertEqual(response.statusCode, HTTPStatusCode.created, "HTTP Status code was \(String(describing: response.statusCode))")
                
                    do {
                        var data = Data()
                        let length = try response.readAllData(into: &data)
                        XCTAssert(length > 0, "Expected some bytes, received \(String(describing: length)) bytes.")
                        XCTAssertNoThrow(try JSONDecoder().decode(User.self, from: data), "Expected response decodable to User, got \(String(describing: String(data: data, encoding: .utf8)))")
                    } catch {
                        XCTFail("Error reading body")
                    }
                }
                expectation.fulfill()
            }, requestModifier: { request in
                request.write(from: userData)
            })
        }
    }
}

