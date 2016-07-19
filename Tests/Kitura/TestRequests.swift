/**
 * Copyright IBM Corporation 2016
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

@testable import Kitura
@testable import KituraNet

class TestRequest : XCTestCase {
    
    static var allTests : [(String, (TestRequest) -> () throws -> Void)] {
        return [
                   ("testURLParameters", testURLParameters)
        ]
    }
    
    override func tearDown() {
        doTearDown()
    }
    
    let router = TestRequest.setupRouter()
    
    func testURLParameters() {
        // Set up router for this test
        let router = Router()
        
        router.get("/zxcv/:p1") { request, _, next in
            let parameter = request.parameters["p1"]
            XCTAssertNotNil(parameter, "URL parameter p1 was nil")
            next()
        }
        router.get("/zxcv/ploni") { request, _, next in
            let parameter = request.parameters["p1"]
            XCTAssertNil(parameter, "URL parameter p1 was not nil, it's value was \(parameter!)")
            next()
        }
        router.all() { _, response, next in
            response.status(.OK).send("OK")
            next()
        }
        
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/zxcv/ploni", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        }
    }
    
    static func setupRouter() -> Router {
        let router = Router()
        
        router.get("/zxcv/:p1") { request, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            let p1 = request.parameters["p1"] ?? "(nil)"
            let q = request.queryParameters["q"] ?? "(nil)"
            let u1 = request.userInfo["u1"] as? NSString ?? "(nil)"
            do {
                try response.send("<!DOCTYPE html><html><body><b>Received /zxcv</b><p><p>p1=\(p1)<p><p>q=\(q)<p><p>u1=\(u1)</body></html>\n\n").end()
            }
            catch {}
            next()
        }
        
        
        
        return router
    }
}

