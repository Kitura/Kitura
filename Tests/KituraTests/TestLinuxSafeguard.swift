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

// Test disabled on Swift 4 for now due to
// https://bugs.swift.org/browse/SR-5684
// We will need to renable this once the bug is addressed in Swift
// TODO: Enable this test case (see above)
#if os(OSX) && !swift(>=4.0)
    import XCTest

    class TestLinuxSafeguard: XCTestCase {
        func testVerifyLinuxTestCount() {
            var linuxCount: Int
            var darwinCount: Int

            // MiscellaneousTests
            linuxCount = MiscellaneousTests.allTests.count
            darwinCount = Int(MiscellaneousTests.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from MiscellaneousTests.allTests")

            // TestContentType
            linuxCount = TestContentType.allTests.count
            darwinCount = Int(TestContentType.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestContentType.allTests")

            // TestCookies
            linuxCount = TestCookies.allTests.count
            darwinCount = Int(TestCookies.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestCookies.allTests")

            // TestDecodeErrorExtensions
            linuxCount = TestDecodingErrorExtension.allTests.count
            darwinCount = Int(TestDecodingErrorExtension.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestDecodingErrorExtension.allTests")

            // TestErrors
            linuxCount = TestErrors.allTests.count
            darwinCount = Int(TestErrors.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestErrors.allTests")

            // TestMultiplicity
            linuxCount = TestMultiplicity.allTests.count
            darwinCount = Int(TestMultiplicity.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestMultiplicity.allTests")

            // TestRequests
            linuxCount = TestRequests.allTests.count
            darwinCount = Int(TestRequests.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestRequests.allTests")

            // TestResponse
            linuxCount = TestResponse.allTests.count
            darwinCount = Int(TestResponse.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestResponse.allTests")

            // TestRouteRegex
            linuxCount = TestRouteRegex.allTests.count
            darwinCount = Int(TestRouteRegex.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestRouteRegex.allTests")

            // TestRouterHTTPVerbsGenerated
            linuxCount = TestRouterHTTPVerbsGenerated.allTests.count
            darwinCount = Int(TestRouterHTTPVerbsGenerated.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestRouterHTTPVerbsGenerated.allTests")

            // TestServer
            linuxCount = TestServer.allTests.count
            darwinCount = Int(TestServer.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestServer.allTests")

            // TestStaticFileServer
            linuxCount = TestStaticFileServer.allTests.count
            darwinCount = Int(TestStaticFileServer.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestStaticFileServer.allTests")

            // TestRangeHeader
            linuxCount = TestRangeHeaderParser.allTests.count
            darwinCount = Int(TestRangeHeaderParser.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestRangeHeaderParser.allTests")

            // TestSubrouter
            linuxCount = TestSubrouter.allTests.count
            darwinCount = Int(TestSubrouter.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestSubrouter.allTests")

            // TestTemplateEngine
            linuxCount = TestTemplateEngine.allTests.count
            darwinCount = Int(TestTemplateEngine.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from TestTemplateEngine.allTests")
        }
    }
  #endif
