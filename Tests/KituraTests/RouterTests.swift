import XCTest
@testable import HTTP
@testable import Kitura

class RouterTests: XCTestCase {
    static var allTests = [
        ("testSimpleRoute", testSimpleRoute),
        ("testParamRoute", testParamRoute)
    ]

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
