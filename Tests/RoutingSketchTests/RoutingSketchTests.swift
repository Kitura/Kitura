import XCTest
@testable import HTTPSketch
@testable import K2Spike
@testable import RoutingSketch

class RouterTests: XCTestCase {
    static var allTests = [
        ("testRouting", testRouting),
    ]

    func testRouting() {
        let path = Path(path: "/users/{id}", verb: .GET)
        let resCreator = EchoWebApp()
        let router = Router(map: [path: resCreator])
        let request = HTTPRequest(method: .GET, target: "/users/123?foo=bar&hello=world", httpVersion: (1, 1), headers: HTTPHeaders())

        guard let (components, _) = router.route(request: request) else {
            XCTFail("No match found")

            return
        }

        XCTAssert(components.parameters?["id"] == "123")
        XCTAssertNotNil(components.queries)
    }
}
