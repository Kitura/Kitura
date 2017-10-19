//
//  TestRangeHeaderDataExtensions.swift
//  KituraPackageDescription
//
//  Created by Ignacio on 2017/10/16.
//

import Foundation
import XCTest

@testable import Kitura

class TestRangeHeaderDataExtensions: XCTestCase {

    var fileUrl: URL!

    var testData = "SomeTest\nData\n1234567890\nKitura is a web framework and web server that is created for web services written in Swift. "

    override func setUp() {
        super.setUp()
        // Prepare temporary file url
        var counter = 0
        repeat {
            counter += 1
            fileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("dataRange\(counter).txt")
        } while FileManager.default.fileExists(atPath: fileUrl.path)
        // Write temporary file
        try? testData.write(to: fileUrl, atomically: true, encoding: .utf8)
    }

    override func tearDown() {
        super.tearDown()
        // Remove temporary file
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            _ = try? FileManager.default.removeItem(at: fileUrl)
        }
    }

    func assertFileExists(file: StaticString = #file, line: UInt = #line) {
        let exists = FileManager.default.fileExists(atPath: fileUrl.path)
        XCTAssertTrue(exists, "test file does not exist", file: file, line: line)
    }

    func testPartialDataReadWithErrorFileNotFound() {
        let data = StaticFileServer.FileServer.read(contentsOfFile: "file/does/not/exists/here.txt", inRange: 0..<5)
        XCTAssertNil(data)
    }

    func testPartialDataRead() {
        assertFileExists()
        let data = StaticFileServer.FileServer.read(contentsOfFile: fileUrl.path, inRange: 0..<9)
        XCTAssertNotNil(data)
        XCTAssertEqual(data?.count, 10)
    }

    func testPartialDataReadEntireFile() {
        assertFileExists()
        let data = StaticFileServer.FileServer.read(contentsOfFile: fileUrl.path, inRange: 0..<100000)
        XCTAssertNotNil(data)

        let fullCount = testData.data(using: .utf8)?.count ?? 0
        XCTAssertTrue(fullCount > 0, "testData is of length 0. unusable for next testing")
        XCTAssertEqual(data?.count, fullCount)
    }
}
