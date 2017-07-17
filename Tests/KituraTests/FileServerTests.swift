import Foundation
import XCTest

import Kitura
@testable import HTTP

class FileServerTests: XCTestCase {
    static var allTests = [
        ("testFileServer", testFileServer),
        ("testFileNotFound", testFileNotFound),
        ("testFileNotReadable", testFileNotReadable)
    ]

    let testFolderURL = URL(fileURLWithPath: #file).appendingPathComponent("../Files").standardized

    // Mimic request to a valid file
    func testFileServer() {
        let request = HTTPRequest(method: .get, target: "/testFile.json", httpVersion: HTTPVersion(major: 1,minor: 1), headers: HTTPHeaders())
        let resolver = TestResponseResolver(request: request, requestBody: Data())
        var router = Router()
        router.setDefaultFileServer(FileServer(folderPath: testFolderURL.path), atPath: "/")
        let coordinator = RequestHandlingCoordinator(router: router)

        resolver.resolveHandler(coordinator.handle)

        //FIXME: XCTAssert(resolver.response?.headers["Content-Type"]?[0] == "application/json")

        guard let payload = resolver.responseBody else {
            XCTFail("Response body is empty")
            return
        }

        payload.withUnsafeBytes {
            let payloadData = Data($0)
            if let object = try? JSONSerialization.jsonObject(with: payloadData) {
                XCTAssert((object as? [String: String])?["foo"] == "bar")
            } else {
                XCTFail("Response body is not JSON")
            }
        }
    }

    // Mimic request to a nonexistent file
    func testFileNotFound() {
        let request = HTTPRequest(method: .get, target: "/does-not-exist.js", httpVersion: HTTPVersion(major: 1,minor: 1), headers: HTTPHeaders())
        let resolver = TestResponseResolver(request: request, requestBody: Data())
        var router = Router()
        router.setDefaultFileServer(FileServer(folderPath: testFolderURL.path), atPath: "/")
        let coordinator = RequestHandlingCoordinator(router: router)

        resolver.resolveHandler(coordinator.handle)

        XCTAssert(resolver.response?.status == .notFound)
    }

    // Mimic request to an unreadable file
    func testFileNotReadable() {
        let filePath = testFolderURL.appendingPathComponent("/unreadable.json").path

        // Get file permissions
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: filePath),
            let permissions = attributes[FileAttributeKey.posixPermissions] as? Int else {
                XCTFail("Unable to get file permissions")
                return
        }

        // Change file permission to be unreadable
        // 222 is -w--w--w-
        guard let _ = try? FileManager.default.setAttributes([FileAttributeKey.posixPermissions: 0o222], ofItemAtPath: filePath) else {
            XCTFail("Unable to set file permissions")
            return
        }

        let request = HTTPRequest(method: .get, target: "/unreadable.json", httpVersion: HTTPVersion(major: 1,minor: 1), headers: HTTPHeaders())
        let resolver = TestResponseResolver(request: request, requestBody: Data())
        var router = Router()
        router.setDefaultFileServer(FileServer(folderPath: testFolderURL.path), atPath: "/")
        let coordinator = RequestHandlingCoordinator(router: router)

        resolver.resolveHandler(coordinator.handle)

        XCTAssert(resolver.response?.status == .forbidden)

        // Reset file permission to previous value
        guard let _ = try? FileManager.default.setAttributes([FileAttributeKey.posixPermissions: permissions], ofItemAtPath: filePath) else {
            XCTFail("Unable to reset file permissions to \(String(permissions, radix: 8))")
            return
        }
    }
}
