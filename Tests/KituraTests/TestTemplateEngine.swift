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
            ("testRenderWithServer", testRenderWithServer),
            ("testRenderWithOptionsWithServer", testRenderWithOptionsWithServer),
            ("testRenderWithServerAndSubRouter", testRenderWithServerAndSubRouter),
            ("testRenderWithExtensionAndWithoutDefaultTemplateEngine",
             testRenderWithExtensionAndWithoutDefaultTemplateEngine),
            ("testAddWithFileExtensions", testAddWithFileExtensions),
            ("testAddWithFileExtensionsWithoutTheDefaultOne",
             testAddWithFileExtensionsWithoutTheDefaultOne)
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

    func testRenderWithServer() {
        let router = Router()
        setupRouterForRendering(router)
        performRenderServerTest(withRouter: router, onPath: "/render")
    }

    func testRenderWithOptionsWithServer() {
        let router = Router()
        setupRouterForRendering(router, options: MockRenderingOptions())
        performRenderServerTest(withRouter: router, onPath: "/render")
    }

    func testRenderWithServerAndSubRouter() {
        //TODO enable this test once https://github.com/IBM-Swift/Kitura/issues/1070 is resolved
        /*

        let subRouter = Router()
        setupRouterForRendering(subRouter)

        let router = Router()
        router.all("/sub", middleware: subRouter)
        performRenderServerTest(withRouter: router, onPath: "/sub/render")
        */
    }

    private func setupRouterForRendering(_ router: Router, options: RenderingOptions? = nil) {
        router.setDefault(templateEngine: MockTemplateEngine())

        router.get("/render") { _, response, next in
            do {
               if let options = options {
                   try response.render("test.mock", context: [:], options: options)
               } else {
                   try response.render("test.mock", context: [:])
               }
	       next()
            } catch {
               response.status(HTTPStatusCode.internalServerError).send("Failed to render")
	       next()
            }
        }
    }

    private func performRenderServerTest(withRouter router: Router, onPath path: String) {
        performServerTest(router) { expectation in
            self.performRequest("get", path: path, callback: { response in
                guard let response = response else {
                    XCTFail("Got nil response")
                    expectation.fulfill()
                    return
                }
                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response.statusCode)")

                do {
                    let body = try response.readString()
                    XCTAssertEqual(body, "Hello World!")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
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
}

class MockTemplateEngine: TemplateEngine {

    public var fileExtension: String { return "mock" }

    public func render(filePath: String, context: [String: Any]) throws -> String {
        return "Hello World!"
    }
}

class MockRenderingOptions: RenderingOptions {
}
