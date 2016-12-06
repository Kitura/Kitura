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
import SwiftyJSON
import KituraTemplateEngine

@testable import Kitura
@testable import KituraNet

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

class TestTemplateEngine : XCTestCase {
    
    static var allTests : [(String, (TestTemplateEngine) -> () throws -> Void)] {
        return [
            ("testNoTemplateEngineForExtension", testNoTemplateEngineForExtension),
            ("testRender", testRender)
        ]
    }
    
    override func setUp() {
        doSetUp()
    }
    
    override func tearDown() {
        doTearDown()
    }
    
    let router = TestTemplateEngine.setupRouter()
    
    func testNoTemplateEngineForExtension() {
        do {
            _ = try router.render(template: "wrong_extension", context: [:])
        }
        catch TemplatingError.noTemplateEngineForExtension {
            //Expect this error to be thrown
        }
        catch {
            XCTFail("Error during render \(error)")
        }
    }
    
    func testRender() {
        do {
            let content = try router.render(template: "test.mock", context: [:])
            XCTAssertEqual(content,"Hello World!")
        } catch {
            XCTFail("Error during render \(error)")
        }
    }
    
    static func setupRouter() -> Router {
        let router = Router()
        router.setDefault(templateEngine: MockTemplateEngine())
        return router
    }
}

class MockTemplateEngine: TemplateEngine {
    
    public var fileExtension: String { return "mock" }

    public func render(filePath: String, context: [String: Any]) throws -> String {
        return "Hello World!"
    }
}
