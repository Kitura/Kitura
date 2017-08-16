import XCTest
@testable import HTTP
@testable import Kitura

class RouterTests: XCTestCase {
    static var allTests = [
        ("testIsPathParameter", testIsPathParameter),
        ("testParameterName", testParameterName),
        ("testParseBadURL", testParseBadURL),
        ("testParseRequestURLTooFewComponents", testParseRequestURLTooFewComponents),
        ("testParseURLComponentsCountMismatch", testParseURLComponentsCountMismatch),
        ("testParsePathComponentsMismatch", testParsePathComponentsMismatch),
        ("testSimpleRoute", testSimpleRoute),
        ("testParamRoute", testParamRoute),
        ("testRequestContextSubscript", testRequestContextSubscript),
        ("testRequestContextAdding", testRequestContextAdding)
    ]
}

// Parameters
extension RouterTests {
    func testIsPathParameter() {
        var param: String

        param = ""
        XCTAssertFalse(param.isPathParameter)

        param = "a"
        XCTAssertFalse(param.isPathParameter)

        param = "{"
        XCTAssertFalse(param.isPathParameter)

        param = "}"
        XCTAssertFalse(param.isPathParameter)

        param = "{}"
        XCTAssert(param.isPathParameter)

        param = "{a}"
        XCTAssert(param.isPathParameter)

        param = "{{}}"
        XCTAssert(param.isPathParameter)
    }

    func testParameterName() {
        var param: String

        param = ""
        XCTAssertNil(param.parameterName)

        param = "a"
        XCTAssertNil(param.parameterName)

        param = "{a}"
        XCTAssertEqual(param.parameterName, "a")

        param = "{{}}"
        XCTAssertEqual(param.parameterName, "{}")
    }
}

// URLParameterParser
extension RouterTests {
    func testParseBadURL() {
        let parser = URLParameterParser(path: "")
        XCTAssertNil(parser.parse("bad url"))
    }

    func testParseRequestURLTooFewComponents() {
        let parser = URLParameterParser(path: "/home", partialMatch: true)
        XCTAssertNil(parser.parse("/"))
    }

    func testParseURLComponentsCountMismatch() {
        let parser = URLParameterParser(path: "/home")
        XCTAssertNil(parser.parse("/home/again"))
    }

    func testParsePathComponentsMismatch() {
        let parser = URLParameterParser(path: "/home")
        XCTAssertNil(parser.parse("/imlost"))
    }
}

// Router
extension RouterTests {
    func testSimpleRoute() {
        let resCreator = EchoWebApp()
        var router = Router()
        router.add(verb: .GET, path: "/foobar", responseCreator: resCreator)
        let request = HTTPRequest(method: .get, target: "/foobar?foo=bar&hello=world", httpVersion: HTTPVersion(major: 1,minor: 1), headers: HTTPHeaders())

        guard let (components, _) = router.route(request: request) else {
            XCTFail("No match found")

            return
        }

        XCTAssert(components?.parameters?.isEmpty == true)
        XCTAssertNotNil(components?.queries)
    }

    func testParamRoute() {
        let resCreator = EchoWebApp()
        var router = Router()
        router.add(verb: .GET, path: "/users/{id}", responseCreator: resCreator)
        let request = HTTPRequest(method: .get, target: "/users/123?foo=bar&hello=world", httpVersion: HTTPVersion(major: 1,minor: 1), headers: HTTPHeaders())

        guard let (components, _) = router.route(request: request) else {
            XCTFail("No match found")

            return
        }

        XCTAssert(components?.parameters?["id"] == "123")
        XCTAssertNotNil(components?.queries)
    }
}

// Request Context
extension RouterTests {
    func testRequestContextSubscript() {
        let requestContext = RequestContext(dict: ["hello": "world"])
        XCTAssertEqual(requestContext["hello"] as? String, "world")
    }

    func testRequestContextAdding() {
        let requestContext = RequestContext()
        XCTAssertEqual(requestContext.adding(dict: ["hello": "world"])["hello"] as? String, 
                       RequestContext(dict: ["hello": "world"])["hello"] as? String)
    }
}
