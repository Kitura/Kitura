import Foundation
import XCTest

import K2Spike
@testable import SwiftServerHttp

class FileServerTests: XCTestCase {
    static var allTests = [
        ("testFileServer", testFileServer),
        ("testFileNotFound", testFileNotFound),
        ("testFileNotReadable", testFileNotReadable)
    ]

    let testFolderURL = URL(fileURLWithPath: #file).appendingPathComponent("../Files").standardized

    // Mimic request to a valid file
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

    // Mimic request to a nonexistent file
    func testFileNotFound() {
        let request = HTTPRequest(method: .GET, target: "/does-not-exist.js", httpVersion: (1, 1), headers: HTTPHeaders())
        let resolver = TestResponseResolver(request: request, requestBody: Data())
        var router = Router()
        router.setDefaultFileServer(FileServer(folderPath: testFolderURL.path), atPath: "/")
        let coordinator = RequestHandlingCoordinator(router: router)

        resolver.resolveHandler(coordinator.handle)

        XCTAssert(resolver.response?.status == .notFound)
    }

    // Mimic request to an unreadable file
    func testFileNotReadable() {
        let filePath = testFolderURL.appendingPathComponent("/testFile.json").path

        // Get file permissions
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: filePath),
            let permissions = attributes[FileAttributeKey.posixPermissions] else {
                XCTFail("Unable to get file permissions")
                return
        }

        // Change file permission to be unreadable
        // 222 is -w--w--w-
        guard let _ = try? FileManager.default.setAttributes([FileAttributeKey.posixPermissions: 0o222], ofItemAtPath: filePath) else {
            XCTFail("Unable to set file permissions")
            return
        }

        let request = HTTPRequest(method: .GET, target: "/testFile.json", httpVersion: (1, 1), headers: HTTPHeaders())
        let resolver = TestResponseResolver(request: request, requestBody: Data())
        var router = Router()
        router.setDefaultFileServer(FileServer(folderPath: testFolderURL.path), atPath: "/")
        let coordinator = RequestHandlingCoordinator(router: router)

        resolver.resolveHandler(coordinator.handle)

        XCTAssert(resolver.response?.status == .forbidden)

        // Reset file permission to previous value
        try? FileManager.default.setAttributes([FileAttributeKey.posixPermissions: permissions], ofItemAtPath: filePath)
    }
}
