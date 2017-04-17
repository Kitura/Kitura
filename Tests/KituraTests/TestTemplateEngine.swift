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

class TestTemplateEngine: KituraTest {

    static var allTests: [(String, (TestTemplateEngine) -> () throws -> Void)] {
        return [
            ("testEmptyTemplateName", testEmptyTemplateName),
            ("testMissingExtension", testMissingExtension),
            ("testNoDefaultEngine", testNoDefaultEngine),
            ("testRender", testRender),
            ("testRenderWithExtensionAndWithoutDefaultTemplateEngine",
             testRenderWithExtensionAndWithoutDefaultTemplateEngine),
            ("testAddWithFileExtensions", testAddWithFileExtensions),
            ("testAddWithFileExtensionsWithoutTheDefaultOne",
             testAddWithFileExtensionsWithoutTheDefaultOne),
            ("testEmptyTemplateNameWithOptions", testEmptyTemplateNameWithOptions),
            ("testMissingExtensionWithOptions", testMissingExtensionWithOptions),
            ("testNoDefaultEngineWithOptions", testNoDefaultEngineWithOptions),
            ("testRenderWithOptions", testRenderWithOptions),
            ("testRenderWithExtensionAndWithoutDefaultTemplateEngineWithOptions",
             testRenderWithExtensionAndWithoutDefaultTemplateEngineWithOptions),
            ("testAddWithFileExtensionsWithOptions", testAddWithFileExtensionsWithOptions),
            ("testAddWithFileExtensionsWithoutTheDefaultOneWithOptions",
             testAddWithFileExtensionsWithoutTheDefaultOneWithOptions)
        ]
    }

    func testEmptyTemplateName() {
        let router = Router()
        router.setDefault(templateEngine: MockTemplateEngine())

        do {
            _ = try router.render(template: "", context: [:])
        } catch TemplatingError.noTemplateEngineForExtension {
            //Expect this error to be thrown
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testEmptyTemplateNameWithOptions() {
        let router = Router()
        router.setDefault(templateEngine: MockTemplateEngine())

        do {
            _ = try router.render(template: "", context: [:], options: [:])
        } catch TemplatingError.noTemplateEngineForExtension {
            //Expect this error to be thrown
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testMissingExtension() {
        let router = Router()
        router.setDefault(templateEngine: MockTemplateEngine())

        do {
            _ = try router.render(template: "index.html", context: [:])
        } catch TemplatingError.noTemplateEngineForExtension {
            //Expect this error to be thrown
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testMissingExtensionWithOptions() {
        let router = Router()
        router.setDefault(templateEngine: MockTemplateEngine())

        do {
            _ = try router.render(template: "index.html", context: [:], options: [:])
        } catch TemplatingError.noTemplateEngineForExtension {
            //Expect this error to be thrown
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testNoDefaultEngine() {
        let router = Router()

        do {
            let _ = try router.render(template: "test", context: [:])
        } catch TemplatingError.noDefaultTemplateEngineAndNoExtensionSpecified {
            //Expect this error to be thrown
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testNoDefaultEngineWithOptions() {
        let router = Router()

        do {
            let _ = try router.render(template: "test", context: [:], options: [:])
        } catch TemplatingError.noDefaultTemplateEngineAndNoExtensionSpecified {
            //Expect this error to be thrown
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testRender() {
        let router = Router()
        router.setDefault(templateEngine: MockTemplateEngine())

        do {
            let content = try router.render(template: "test.mock", context: [:])
            XCTAssertEqual(content, "Hello World!")
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testRenderWithOptions() {
        let router = Router()
        router.setDefault(templateEngine: MockTemplateEngine())

        do {
            let content = try router.render(template: "test.mock", context: [:], options: [:])
            XCTAssertEqual(content, "Hello World with options!")
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testRenderWithExtensionAndWithoutDefaultTemplateEngine() {
        let router = Router()
        router.add(templateEngine: MockTemplateEngine())

        do {
            let content = try router.render(template: "test.mock", context: [:])
            XCTAssertEqual(content, "Hello World!")
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testRenderWithExtensionAndWithoutDefaultTemplateEngineWithOptions() {
        let router = Router()
        router.add(templateEngine: MockTemplateEngine())

        do {
            let content = try router.render(template: "test.mock", context: [:], options: [:])
            XCTAssertEqual(content, "Hello World with options!")
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testAddWithFileExtensions() {
        let router = Router()
        router.add(templateEngine: MockTemplateEngine(), forFileExtensions: ["htm", "html"])

        do {
            let content = try router.render(template: "test.mock", context: [:])
            XCTAssertEqual(content, "Hello World!")
        } catch {
            XCTFail("Error during render \(error)")
        }

        do {
            let content = try router.render(template: "test.html", context: [:])
            XCTAssertEqual(content, "Hello World!")
        } catch {
            XCTFail("Error during render \(error)")
        }

        do {
            let content = try router.render(template: "test.htm", context: [:])
            XCTAssertEqual(content, "Hello World!")
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testAddWithFileExtensionsWithOptions() {
        let router = Router()
        router.add(templateEngine: MockTemplateEngine(), forFileExtensions: ["htm", "html"])

        do {
            let content = try router.render(template: "test.mock", context: [:], options: [:])
            XCTAssertEqual(content, "Hello World with options!")
        } catch {
            XCTFail("Error during render \(error)")
        }

        do {
            let content = try router.render(template: "test.html", context: [:], options: [:])
            XCTAssertEqual(content, "Hello World with options!")
        } catch {
            XCTFail("Error during render \(error)")
        }

        do {
            let content = try router.render(template: "test.htm", context: [:], options: [:])
            XCTAssertEqual(content, "Hello World with options!")
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testAddWithFileExtensionsWithoutTheDefaultOne() {
        let router = Router()
        router.add(templateEngine: MockTemplateEngine(), forFileExtensions: ["htm", "html"],
                   useDefaultFileExtension: false)

        do {
            _ = try router.render(template: "test.mock", context: [:])
        } catch TemplatingError.noTemplateEngineForExtension {
            //Expect this error to be thrown
        } catch {
            XCTFail("Error during render \(error)")
        }

        do {
            let content = try router.render(template: "test.html", context: [:])
            XCTAssertEqual(content, "Hello World!")
        } catch {
            XCTFail("Error during render \(error)")
        }

        do {
            let content = try router.render(template: "test.htm", context: [:])
            XCTAssertEqual(content, "Hello World!")
        } catch {
            XCTFail("Error during render \(error)")
        }
    }

    func testAddWithFileExtensionsWithoutTheDefaultOneWithOptions() {
        let router = Router()
        router.add(templateEngine: MockTemplateEngine(), forFileExtensions: ["htm", "html"],
                   useDefaultFileExtension: false)

        do {
            _ = try router.render(template: "test.mock", context: [:], options: [:])
        } catch TemplatingError.noTemplateEngineForExtension {
            //Expect this error to be thrown
        } catch {
            XCTFail("Error during render \(error)")
        }

        do {
            let content = try router.render(template: "test.html", context: [:], options: [:])
            XCTAssertEqual(content, "Hello World with options!")
        } catch {
            XCTFail("Error during render \(error)")
        }

        do {
            let content = try router.render(template: "test.htm", context: [:], options: [:])
            XCTAssertEqual(content, "Hello World with options!")
        } catch {
            XCTFail("Error during render \(error)")
        }
    }
}

class MockTemplateEngine: TemplateEngine {

    public var fileExtension: String { return "mock" }

    public func render(filePath: String, context: [String: Any]) throws -> String {
        return "Hello World!"
    }

    public func render(filePath: String, context: [String: Any], options: [String: Any]) throws -> String {
        return "Hello World with options!"
    }
}
