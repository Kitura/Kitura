/**
 * Copyright IBM Corporation 2016
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

import XCTest

@testable import KituraTests

XCTMain([
    testCase(MiscellaneousTests.allTests.shuffled()),
    testCase(TestContentType.allTests.shuffled()),
    testCase(TestCookies.allTests.shuffled()),
    testCase(TestErrors.allTests.shuffled()),
    testCase(TestMultiplicity.allTests.shuffled()),
    testCase(TestRequests.allTests.shuffled()),
    testCase(TestResponse.allTests.shuffled()),
    testCase(TestRouteRegex.allTests.shuffled()),
    testCase(TestRouterHTTPVerbs_generated.allTests.shuffled()),
    testCase(TestServer.allTests.shuffled()),
    testCase(TestSubrouter.allTests.shuffled()),
    testCase(TestStaticFileServer.allTests.shuffled()),
    testCase(TestTemplateEngine.allTests.shuffled())
])
