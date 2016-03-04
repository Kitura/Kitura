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

@testable import KituraRouter
@testable import KituraNet

class TestMultiplicity : KituraTest {
    #if os(Linux)
        override var allTests : [(String, () throws -> Void)] {
            return [
                ("testPlus", testPlus),
                ("testStar", testStar),
                ("testQuestion", testQuestion),
                ("testCombined", testCombined)
            ]
        }
    #endif

    let router = TestMultiplicity.setupRouter()

    func testPlus() {
        performServerTest(router, asyncTasks: {
            self.performRequest("get", path: "/1/plus") {response in
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Plus route did not match single path request")
            }
        }, {
            self.performRequest("get", path: "/1/plus/plus") {response in
                    XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Plus route did not match multiple path request")
                }
        }, {
            self.performRequest("get", path: "/1") {response in
                    XCTAssertEqual(response!.statusCode, HttpStatusCode.NOT_FOUND, "Plus route did not miss empty path request")
                }
        })
    }

	func testStar() {
		performServerTest(router, asyncTasks: {
            self.performRequest("get", path: "/2/star") {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Star route did not match single path request")
            }
        }, {
            self.performRequest("get", path: "/2/star/star") {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Star route did not match multiple path request")
                }
        }, {
            self.performRequest("get", path: "/2") {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Star route did not match empty path request")
                }
        })
	}

	func testQuestion() {
		performServerTest(router, asyncTasks: {
            self.performRequest("get", path: "/3/question") {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Question route did not match single path request")
                }
        }, {
            self.performRequest("get", path: "/3/question/question") {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.NOT_FOUND, "Question route did not miss multiple path request")
                }
        }, {
            self.performRequest("get", path: "/3") {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Question route did not match empty path request")
                }
        })
	}

	func testCombined() {
        performServerTest(router, asyncTasks: {
            self.performRequest("get", path: "/4/question/plus") {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Complex route did not match dropped star ending")
                }
        }, {
            self.performRequest("get", path: "/4/plus/plus/star") {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Complex route did not match dropped beginning with extra middle")
                }
        }, {
            self.performRequest("get", path: "/4/question/plusssssss/plus/pluss/star/star") {response in
                	XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "Complex route did not match internal extra plus signs with multiple extras")
                }
        })
	}

    static func setupRouter() -> Router {
    	let router = Router()

    	router.get("/1/(plus)+") {_, response, next in 
    		do {
    			try response.status(HttpStatusCode.OK).end()
    		}
    		catch {}

    		next()	
    	}

    	router.get("/2/(star)*") {_, response, next in
    		do {
    			try response.status(HttpStatusCode.OK).end()
    		}
    		catch {}
    		next()
    	}

    	router.get("/3/(question)?") {_, response, next in
    		do {
    			try response.status(HttpStatusCode.OK).end()
    		}
    		catch {}

    		next()
    	}

    	router.get ("/4/(question)?/(plus+)+/(star)*") {_, response, next in
    		do {
    			try response.status(HttpStatusCode.OK).end()
    		}
    		catch {}

    		next()
    	}

    	return router
    }
}
