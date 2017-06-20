import Foundation
import XCTest

import K2Spike
@testable import SwiftServerHttp

class FileServerTests: XCTestCase {
    static var allTests = [
        ("testFileServer", testFileServer),
        ("testFileNotFound", testFileNotFound)
    ]

    let testFolderURL = URL(fileURLWithPath: #file).appendingPathComponent("../Files").standardized

    func testFileServer() {
        let request = HTTPRequest(method: .GET, target: "/testFile.json", httpVersion: (1, 1), headers: HTTPHeaders())
        let resolver = TestResponseResolver(request: request, requestBody: Data())
        var router = Router()
        router.setDefaultFileServer(FileServer(folderPath: testFolderURL.path), atPath: "/")
        let coordinator = RequestHandlingCoordinator(router: router)

        resolver.resolveHandler(coordinator.handle)

        XCTAssert(resolver.response?.headers["Content-Type"][0] == "application/json")

        guard let payload = resolver.responseBody else {
            XCTFail("Response body is empty")
            return
        }

        guard let object = try? JSONSerialization.jsonObject(with: payload) else {
            XCTFail("Response body is not JSON")
            return
        }

        XCTAssert((object as? [String: String])?["foo"] == "bar")
    }

    func testFileNotFound() {
        let request = HTTPRequest(method: .GET, target: "/does-not-exist.js", httpVersion: (1, 1), headers: HTTPHeaders())
        let resolver = TestResponseResolver(request: request, requestBody: Data())
        var router = Router()
        router.setDefaultFileServer(FileServer(folderPath: testFolderURL.path), atPath: "/")
        let coordinator = RequestHandlingCoordinator(router: router)

        resolver.resolveHandler(coordinator.handle)

        XCTAssert(resolver.response?.status == .notFound)
    }
}
