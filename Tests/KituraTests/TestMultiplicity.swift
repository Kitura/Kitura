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

@testable import Kitura
@testable import KituraNet

class TestMultiplicity: KituraTest {

    static var allTests: [(String, (TestMultiplicity) -> () throws -> Void)] {
        return [
            ("testPlus", testPlus),
            ("testStar", testStar),
            ("testQuestion", testQuestion),
            ("testCombined", testCombined)
        ]
    }

    let router = TestMultiplicity.setupRouter()

    func testPlus() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/1/plus", callback: {response in
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "Plus route did not match single path request")
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/1/plus/plus", callback: {response in
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "Plus route did not match multiple path request")
                    expectation.fulfill()
                })
        }, { expectation in
            self.performRequest("get", path: "/1", callback: {response in
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "Plus route did not miss empty path request")
                    expectation.fulfill()
                })
        })
    }

    func testStar() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/2/star", callback: {response in
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "Star route did not match single path request")
                  expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/2/star/star", callback: {response in
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "Star route did not match multiple path request")
                  expectation.fulfill()
                })
        }, { expectation in
            self.performRequest("get", path: "/2", callback: {response in
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "Star route did not match empty path request")
                  expectation.fulfill()
                })
        })
    }

    func testQuestion() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/3/question", callback: {response in
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "Question route did not match single path request")
                  expectation.fulfill()
                })
        }, { expectation in
            self.performRequest("get", path: "/3/question/question", callback: {response in
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "Question route did not miss multiple path request")
                  expectation.fulfill()
                })
        }, { expectation in
            self.performRequest("get", path: "/3", callback: {response in
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "Question route did not match empty path request")
                  expectation.fulfill()
                })
        })
    }

    func testCombined() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/4/question/plus", callback: {response in
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "Complex route did not match dropped star ending")
                  expectation.fulfill()
                })
        }, { expectation in
            self.performRequest("get", path: "/4/plus/plus/star", callback: {response in
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "Complex route did not match dropped beginning with extra middle")
                  expectation.fulfill()
                })
        }, { expectation in
            self.performRequest("get", path: "/4/question/plusssssss/plus/pluss/star/star", callback: {response in
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "Complex route did not match internal extra plus signs with multiple extras")
                  expectation.fulfill()
                })
        })
    }

    static func setupRouter() -> Router {
        let router = Router()

        router.get("/1/(plus)+") {_, response, next in
            do {
                try response.status(HTTPStatusCode.OK).end()
            } catch {}

            next()
        }

        router.get("/2/(star)*") {_, response, next in
            do {
                try response.status(HTTPStatusCode.OK).end()
            } catch {}
            next()
        }

        router.get("/3/(question)?") {_, response, next in
            do {
                try response.status(HTTPStatusCode.OK).end()
            } catch {}

            next()
        }

        router.get ("/4/(question)?/(plus+)+/(star)*") {_, response, next in
            do {
                try response.status(HTTPStatusCode.OK).end()
            } catch {}

            next()
        }

        return router
    }
}
