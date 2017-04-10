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

#if os(OSX)
    import XCTest
    
    class TestSafeguard: XCTestCase {
        func testVerifyLinuxTestCount() {
            var linuxCount: Int
            var darwinCount: Int
            
            // MiscellaneousTests
            linuxCount = MiscellaneousTests.allTests.count
            darwinCount = Int(MiscellaneousTests.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationManagerTest.allTests")
            
            // TestContentType
            linuxCount = TestContentType.allTests.count
            darwinCount = Int(TestContentType.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
            
            // TestCookies
            linuxCount = TestCookies.allTests.count
            darwinCount = Int(TestCookies.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
            
            // TestErrors
            linuxCount = TestErrors.allTests.count
            darwinCount = Int(TestErrors.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
            
            // TestMultiplicity
            linuxCount = TestMultiplicity.allTests.count
            darwinCount = Int(TestMultiplicity.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
            
            // TestRequests
            linuxCount = TestRequests.allTests.count
            darwinCount = Int(TestRequests.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
            
            // TestResponse
            linuxCount = TestResponse.allTests.count
            darwinCount = Int(TestResponse.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
            
            // TestRouteRegex
            linuxCount = TestRouteRegex.allTests.count
            darwinCount = Int(TestRouteRegex.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
            
            // TestRouterHTTPVerbs_generated
            linuxCount = TestRouterHTTPVerbs_generated.allTests.count
            darwinCount = Int(TestRouterHTTPVerbs_generated.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
            
            // TestServer
            linuxCount = TestServer.allTests.count
            darwinCount = Int(TestServer.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
            
            // TestStaticFileServer
            linuxCount = TestStaticFileServer.allTests.count
            darwinCount = Int(TestStaticFileServer.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
            
            // TestSubrouter
            linuxCount = TestSubrouter.allTests.count
            darwinCount = Int(TestSubrouter.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
            
            // TestTemplateEngine
            linuxCount = TestTemplateEngine.allTests.count
            darwinCount = Int(TestTemplateEngine.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from ConfigurationNodeTest.allTests")
        }
    }
#endif
