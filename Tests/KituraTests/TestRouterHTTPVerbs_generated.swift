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

@testable import Kitura
@testable import KituraNet

#if os(Linux)
import Glibc
#else
import Darwin
#endif

class TestRouterHTTPVerbsGenerated: KituraTest {

    static var allTests: [(String, (TestRouterHTTPVerbsGenerated) -> () throws -> Void)] {
        return [
            ("testFirstTypeVerbsAdded", testFirstTypeVerbsAdded),
            ("testSecondTypeVerbsAdded", testSecondTypeVerbsAdded),
            ("testThirdTypeVerbsAdded", testThirdTypeVerbsAdded),
            ("testFourthTypeVerbsAdded", testFourthTypeVerbsAdded)
        ]
    }

    let bodyTestHandler: RouterHandler = { request, response, next in
        guard let requestBody = request.body else {
            next ()
            return
        }
        next()
    }

    // check that all verbs with bodyTestHandler parameter was added to elements array
    func testFirstTypeVerbsAdded() {
            let router = Router()
            var verbsArray: [String] = []
            verbsArray.append("ALL")
            router.all("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("GET")
            router.get("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("HEAD")
            router.head("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("POST")
            router.post("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("PUT")
            router.put("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("DELETE")
            router.delete("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("OPTIONS")
            router.options("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("TRACE")
            router.trace("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("COPY")
            router.copy("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("LOCK")
            router.lock("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("MKCOL")
            router.mkCol("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("MOVE")
            router.move("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("PURGE")
            router.purge("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("PROPFIND")
            router.propFind("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("PROPPATCH")
            router.propPatch("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("UNLOCK")
            router.unlock("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("REPORT")
            router.report("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("MKACTIVITY")
            router.mkActivity("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("CHECKOUT")
            router.checkout("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("MERGE")
            router.merge("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("MSEARCH")
            router.mSearch("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("NOTIFY")
            router.notify("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("SUBSCRIBE")
            router.subscribe("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("UNSUBSCRIBE")
            router.unsubscribe("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("PATCH")
            router.patch("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("SEARCH")
            router.search("/bodytest", handler: self.bodyTestHandler)
            verbsArray.append("CONNECT")
            router.connect("/bodytest", handler: self.bodyTestHandler)

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
    }

    func testSecondTypeVerbsAdded() {
            let router = Router()
            var verbsArray: [String] = []
            verbsArray.append("ALL")
            router.all("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("GET")
            router.get("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("HEAD")
            router.head("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("POST")
            router.post("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("PUT")
            router.put("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("DELETE")
            router.delete("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("OPTIONS")
            router.options("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("TRACE")
            router.trace("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("COPY")
            router.copy("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("LOCK")
            router.lock("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("MKCOL")
            router.mkCol("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("MOVE")
            router.move("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("PURGE")
            router.purge("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("PROPFIND")
            router.propFind("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("PROPPATCH")
            router.propPatch("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("UNLOCK")
            router.unlock("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("REPORT")
            router.report("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("MKACTIVITY")
            router.mkActivity("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("CHECKOUT")
            router.checkout("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("MERGE")
            router.merge("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("MSEARCH")
            router.mSearch("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("NOTIFY")
            router.notify("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("SUBSCRIBE")
            router.subscribe("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("UNSUBSCRIBE")
            router.unsubscribe("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("PATCH")
            router.patch("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("SEARCH")
            router.search("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])
            verbsArray.append("CONNECT")
            router.connect("/bodytest", handler: [self.bodyTestHandler, self.bodyTestHandler])

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
    }

    func testThirdTypeVerbsAdded() {
            let router = Router()
            var verbsArray: [String] = []
            let bodyParser = BodyParser()
            verbsArray.append("ALL")
            router.all("/bodytest", middleware: bodyParser)
            verbsArray.append("GET")
            router.get("/bodytest", middleware: bodyParser)
            verbsArray.append("HEAD")
            router.head("/bodytest", middleware: bodyParser)
            verbsArray.append("POST")
            router.post("/bodytest", middleware: bodyParser)
            verbsArray.append("PUT")
            router.put("/bodytest", middleware: bodyParser)
            verbsArray.append("DELETE")
            router.delete("/bodytest", middleware: bodyParser)
            verbsArray.append("OPTIONS")
            router.options("/bodytest", middleware: bodyParser)
            verbsArray.append("TRACE")
            router.trace("/bodytest", middleware: bodyParser)
            verbsArray.append("COPY")
            router.copy("/bodytest", middleware: bodyParser)
            verbsArray.append("LOCK")
            router.lock("/bodytest", middleware: bodyParser)
            verbsArray.append("MKCOL")
            router.mkCol("/bodytest", middleware: bodyParser)
            verbsArray.append("MOVE")
            router.move("/bodytest", middleware: bodyParser)
            verbsArray.append("PURGE")
            router.purge("/bodytest", middleware: bodyParser)
            verbsArray.append("PROPFIND")
            router.propFind("/bodytest", middleware: bodyParser)
            verbsArray.append("PROPPATCH")
            router.propPatch("/bodytest", middleware: bodyParser)
            verbsArray.append("UNLOCK")
            router.unlock("/bodytest", middleware: bodyParser)
            verbsArray.append("REPORT")
            router.report("/bodytest", middleware: bodyParser)
            verbsArray.append("MKACTIVITY")
            router.mkActivity("/bodytest", middleware: bodyParser)
            verbsArray.append("CHECKOUT")
            router.checkout("/bodytest", middleware: bodyParser)
            verbsArray.append("MERGE")
            router.merge("/bodytest", middleware: bodyParser)
            verbsArray.append("MSEARCH")
            router.mSearch("/bodytest", middleware: bodyParser)
            verbsArray.append("NOTIFY")
            router.notify("/bodytest", middleware: bodyParser)
            verbsArray.append("SUBSCRIBE")
            router.subscribe("/bodytest", middleware: bodyParser)
            verbsArray.append("UNSUBSCRIBE")
            router.unsubscribe("/bodytest", middleware: bodyParser)
            verbsArray.append("PATCH")
            router.patch("/bodytest", middleware: bodyParser)
            verbsArray.append("SEARCH")
            router.search("/bodytest", middleware: bodyParser)
            verbsArray.append("CONNECT")
            router.connect("/bodytest", middleware: bodyParser)

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
    }

    func testFourthTypeVerbsAdded() {
            let router = Router()
            var verbsArray: [String] = []
            let bodyParser = BodyParser()
            verbsArray.append("ALL")
            router.all("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("GET")
            router.get("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("HEAD")
            router.head("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("POST")
            router.post("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("PUT")
            router.put("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("DELETE")
            router.delete("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("OPTIONS")
            router.options("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("TRACE")
            router.trace("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("COPY")
            router.copy("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("LOCK")
            router.lock("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("MKCOL")
            router.mkCol("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("MOVE")
            router.move("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("PURGE")
            router.purge("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("PROPFIND")
            router.propFind("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("PROPPATCH")
            router.propPatch("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("UNLOCK")
            router.unlock("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("REPORT")
            router.report("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("MKACTIVITY")
            router.mkActivity("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("CHECKOUT")
            router.checkout("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("MERGE")
            router.merge("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("MSEARCH")
            router.mSearch("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("NOTIFY")
            router.notify("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("SUBSCRIBE")
            router.subscribe("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("UNSUBSCRIBE")
            router.unsubscribe("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("PATCH")
            router.patch("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("SEARCH")
            router.search("/bodytest", middleware: [bodyParser, bodyParser])
            verbsArray.append("CONNECT")
            router.connect("/bodytest", middleware: [bodyParser, bodyParser])

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
    }
}
