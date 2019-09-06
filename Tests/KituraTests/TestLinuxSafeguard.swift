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

// Test requires Swift 4.1 or higher due to
// https://bugs.swift.org/browse/SR-5684
#if os(OSX) && swift(>=4.1)
    import XCTest

    class TestLinuxSafeguard: XCTestCase {

        func verifyCount<T: KituraTestSuite>(_ testSuite: T.Type) {
            let linuxCount = T.allTests.count
            let darwinCount = Int(T.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from \(T.self).allTests")
        }

        func testVerifyLinuxTestCount() {
            verifyCount(MiscellaneousTests.self)
            verifyCount(TestBridgingHTTPStatusCode.self)
            verifyCount(TestBridgingRequestError.self)
            verifyCount(TestCodablePathParams.self)
            verifyCount(TestCodableRouter.self)
            verifyCount(TestContentType.self)
            verifyCount(TestCookies.self)
            verifyCount(TestCustomCoders.self)
            verifyCount(TestDecodingErrorExtension.self)
            verifyCount(TestErrors.self)
            verifyCount(TestMediaType.self)
            verifyCount(TestMultiplicity.self)
            verifyCount(TestRangeHeaderDataExtensions.self)
            verifyCount(TestRangeHeaderParser.self)
            verifyCount(TestRequests.self)
            verifyCount(TestResponse.self)
            verifyCount(TestRouteRegex.self)
            verifyCount(TestRouterHTTPVerbsGenerated.self)
            verifyCount(TestServer.self)
            verifyCount(TestStack.self)
            verifyCount(TestStaticFileServer.self)
            verifyCount(TestSubrouter.self)
            verifyCount(TestSwaggerGeneration.self)
            verifyCount(TestTemplateEngine.self)
            verifyCount(TestTypeSafeMiddleware.self)
        }
    }
  #endif
