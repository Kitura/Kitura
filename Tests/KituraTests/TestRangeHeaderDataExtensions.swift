/**
 * Copyright IBM Corporation 2017
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
