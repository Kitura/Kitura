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

#if swift(>=4.0)

class TestBasicTypeRouter: KituraTest {
    static var allTests: [(String, (TestBasicTypeRouter) -> () throws -> Void)] {
        return [
            ("testBasicPost", testBasicPost),
        ]
    }
    
    let router = Router()
    
    struct User: Codable {
        let id: Int
        let name: String
        init(id: Int, name: String) {
            self.id = id
            self.name = name
        }        
    }
    
    var userStore: [Int: User] = [1: User(id: 1, name: "Mike"), 2: User(id: 2, name: "Chris"), 3: User(id: 3, name: "Ricardo")]
    
    func testBasicPost() {

        router.post("/users") { (user: User, respondWith: (User) -> Void) in
            print("POST on /users for user \(user)")
            // Let's keep the test simple
            // We just want to test that we can register a handler that 
            // receives and sends back a Codable instance
            self.userStore[user.id] = user            
            respondWith(user)
        }
        performServerTest(router, timeout: 30) { expectation in
            // Let's create a User instance
            let expectedUser = User(id: 4, name: "David")
            // Create JSON representation of User instance
            guard let userData = try? JSONEncoder().encode(expectedUser) else {
                XCTFail("Could not generate user data from string!")
                return
            }
            
            self.performRequest("post", path: "/users", callback: { response in
                guard let response = response else {
                    XCTFail("ERROR!!! ClientRequest response object was nil")
                    return
                }               
               
                XCTAssertEqual(response.statusCode, HTTPStatusCode.created, "HTTP Status code was \(String(describing: response.statusCode))")
                var data = Data()
                guard let length = try? response.readAllData(into: &data) else {
                    XCTFail("Error reading response length!")
                    return
                }
                
                XCTAssert(length > 0, "Expected some bytes, received \(String(describing: length)) bytes.")
                    guard let user = try? JSONDecoder().decode(User.self, from: data) else {
                    XCTFail("Could not decode response! Expected response decodable to User, but got \(String(describing: String(data: data, encoding: .utf8)))")
                    return
                }

                // Validate the data we got back from the server
                XCTAssertEqual(user.name, expectedUser.name)
                XCTAssertEqual(user.id, expectedUser.id)
                     
                expectation.fulfill()
            }, requestModifier: { request in
                request.write(from: userData)
            })
        }
    }
}

#endif

