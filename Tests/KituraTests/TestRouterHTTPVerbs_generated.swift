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
import Foundation
import SwiftyJSON

@testable import Kitura
@testable import KituraNet

#if os(Linux)
import Glibc
#else
import Darwin
#endif

class TestRouterHTTPVerbs_generated: XCTestCase {

    static var allTests: [(String, (TestRouterHTTPVerbs_generated) -> () throws -> Void)] {
        return [
            ("testFirstTypeVerbsAdded", testFirstTypeVerbsAdded),
            ("testSecondTypeVerbsAdded", testSecondTypeVerbsAdded),
            ("testThirdTypeVerbsAdded", testThirdTypeVerbsAdded),
            ("testFourthTypeVerbsAdded", testFourthTypeVerbsAdded)
        ]
    }

    let BodyTestHandler: RouterHandler = { request, response, next in
        guard let requestBody = request.body else {
            next ()
            return
        }
        next()
    }

    // check that all verbs with BodyTestHandler parameter was added to elements array
    func testFirstTypeVerbsAdded() {
        let router = Router()
        performServerTest(router) { expectation in
            var verbsArray: [String] = []
            verbsArray.append("ALL")
            router.all("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("GET")
            router.get("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("HEAD")
            router.head("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("POST")
            router.post("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("PUT")
            router.put("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("DELETE")
            router.delete("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("OPTIONS")
            router.options("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("TRACE")
            router.trace("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("COPY")
            router.copy("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("LOCK")
            router.lock("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("MKCOL")
            router.mkCol("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("MOVE")
            router.move("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("PURGE")
            router.purge("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("PROPFIND")
            router.propFind("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("PROPPATCH")
            router.propPatch("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("UNLOCK")
            router.unlock("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("REPORT")
            router.report("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("MKACTIVITY")
            router.mkActivity("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("CHECKOUT")
            router.checkout("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("MERGE")
            router.merge("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("MSEARCH")
            router.mSearch("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("NOTIFY")
            router.notify("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("SUBSCRIBE")
            router.subscribe("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("UNSUBSCRIBE")
            router.unsubscribe("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("PATCH")
            router.patch("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("SEARCH")
            router.search("/bodytest", handler: self.BodyTestHandler)
            verbsArray.append("CONNECT")
            router.connect("/bodytest", handler: self.BodyTestHandler)

            // check all verbs added
            let elements = router.elements
            guard elements.count == 27 else {
                XCTFail("didn't add all verbs")
                return
            }
            // check right verbs added
            for index in 0...elements.count - 1 {
                guard elements[index].method.description == verbsArray[index] else {
                    XCTFail("didn't add all verbs")
                    return
                }
            }
            expectation.fulfill()
        }
    }

    func testSecondTypeVerbsAdded() {
        let router = Router()
        performServerTest(router) { expectation in
            var verbsArray: [String] = []
            verbsArray.append("ALL")
            router.all("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("GET")
            router.get("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("HEAD")
            router.head("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("POST")
            router.post("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("PUT")
            router.put("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("DELETE")
            router.delete("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("OPTIONS")
            router.options("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("TRACE")
            router.trace("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("COPY")
            router.copy("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("LOCK")
            router.lock("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("MKCOL")
            router.mkCol("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("MOVE")
            router.move("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("PURGE")
            router.purge("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("PROPFIND")
            router.propFind("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("PROPPATCH")
            router.propPatch("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("UNLOCK")
            router.unlock("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("REPORT")
            router.report("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("MKACTIVITY")
            router.mkActivity("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("CHECKOUT")
            router.checkout("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("MERGE")
            router.merge("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("MSEARCH")
            router.mSearch("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("NOTIFY")
            router.notify("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("SUBSCRIBE")
            router.subscribe("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("UNSUBSCRIBE")
            router.unsubscribe("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("PATCH")
            router.patch("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("SEARCH")
            router.search("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])
            verbsArray.append("CONNECT")
            router.connect("/bodytest", handler: [self.BodyTestHandler, self.BodyTestHandler])

            // check all verbs added
            let elements = router.elements
            guard elements.count == 27 else {
                XCTFail("didn't add all verbs")
                return
            }
            // check right verbs added
            for index in 0...elements.count - 1 {
                guard elements[index].method.description == verbsArray[index] else {
                    XCTFail("didn't add all verbs")
                    return
                }
            }
            expectation.fulfill()
        }
    }

    func testThirdTypeVerbsAdded() {
        let router = Router()
        performServerTest(router) { expectation in
            var verbsArray: [String] = []
            verbsArray.append("ALL")
            router.all("/bodytest", middleware: BodyParser())
            verbsArray.append("GET")
            router.get("/bodytest", middleware: BodyParser())
            verbsArray.append("HEAD")
            router.head("/bodytest", middleware: BodyParser())
            verbsArray.append("POST")
            router.post("/bodytest", middleware: BodyParser())
            verbsArray.append("PUT")
            router.put("/bodytest", middleware: BodyParser())
            verbsArray.append("DELETE")
            router.delete("/bodytest", middleware: BodyParser())
            verbsArray.append("OPTIONS")
            router.options("/bodytest", middleware: BodyParser())
            verbsArray.append("TRACE")
            router.trace("/bodytest", middleware: BodyParser())
            verbsArray.append("COPY")
            router.copy("/bodytest", middleware: BodyParser())
            verbsArray.append("LOCK")
            router.lock("/bodytest", middleware: BodyParser())
            verbsArray.append("MKCOL")
            router.mkCol("/bodytest", middleware: BodyParser())
            verbsArray.append("MOVE")
            router.move("/bodytest", middleware: BodyParser())
            verbsArray.append("PURGE")
            router.purge("/bodytest", middleware: BodyParser())
            verbsArray.append("PROPFIND")
            router.propFind("/bodytest", middleware: BodyParser())
            verbsArray.append("PROPPATCH")
            router.propPatch("/bodytest", middleware: BodyParser())
            verbsArray.append("UNLOCK")
            router.unlock("/bodytest", middleware: BodyParser())
            verbsArray.append("REPORT")
            router.report("/bodytest", middleware: BodyParser())
            verbsArray.append("MKACTIVITY")
            router.mkActivity("/bodytest", middleware: BodyParser())
            verbsArray.append("CHECKOUT")
            router.checkout("/bodytest", middleware: BodyParser())
            verbsArray.append("MERGE")
            router.merge("/bodytest", middleware: BodyParser())
            verbsArray.append("MSEARCH")
            router.mSearch("/bodytest", middleware: BodyParser())
            verbsArray.append("NOTIFY")
            router.notify("/bodytest", middleware: BodyParser())
            verbsArray.append("SUBSCRIBE")
            router.subscribe("/bodytest", middleware: BodyParser())
            verbsArray.append("UNSUBSCRIBE")
            router.unsubscribe("/bodytest", middleware: BodyParser())
            verbsArray.append("PATCH")
            router.patch("/bodytest", middleware: BodyParser())
            verbsArray.append("SEARCH")
            router.search("/bodytest", middleware: BodyParser())
            verbsArray.append("CONNECT")
            router.connect("/bodytest", middleware: BodyParser())

            // check all verbs added
            let elements = router.elements
            guard elements.count == 27 else {
                XCTFail("didn't add all verbs")
                return
            }
            // check right verbs added
            for index in 0...elements.count - 1 {
                guard elements[index].method.description == verbsArray[index] else {
                    XCTFail("didn't add all verbs")
                    return
                }
            }
            expectation.fulfill()
        }
    }

    func testFourthTypeVerbsAdded() {
        let router = Router()
        performServerTest(router) { expectation in
            var verbsArray: [String] = []
            verbsArray.append("ALL")
            router.all("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("GET")
            router.get("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("HEAD")
            router.head("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("POST")
            router.post("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("PUT")
            router.put("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("DELETE")
            router.delete("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("OPTIONS")
            router.options("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("TRACE")
            router.trace("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("COPY")
            router.copy("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("LOCK")
            router.lock("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("MKCOL")
            router.mkCol("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("MOVE")
            router.move("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("PURGE")
            router.purge("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("PROPFIND")
            router.propFind("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("PROPPATCH")
            router.propPatch("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("UNLOCK")
            router.unlock("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("REPORT")
            router.report("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("MKACTIVITY")
            router.mkActivity("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("CHECKOUT")
            router.checkout("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("MERGE")
            router.merge("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("MSEARCH")
            router.mSearch("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("NOTIFY")
            router.notify("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("SUBSCRIBE")
            router.subscribe("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("UNSUBSCRIBE")
            router.unsubscribe("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("PATCH")
            router.patch("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("SEARCH")
            router.search("/bodytest", middleware: [BodyParser(), BodyParser()])
            verbsArray.append("CONNECT")
            router.connect("/bodytest", middleware: [BodyParser(), BodyParser()])

            // check all verbs added
            let elements = router.elements
            guard elements.count == 27 else {
                XCTFail("didn't add all verbs")
                return
            }
            // check right verbs added
            for index in 0...elements.count - 1 {
                guard elements[index].method.description == verbsArray[index] else {
                    XCTFail("didn't add all verbs")
                    return
                }
            }
            expectation.fulfill()
        }
    }
}
