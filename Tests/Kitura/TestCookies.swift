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

import Foundation
import XCTest

@testable import Kitura
@testable import KituraNet

let cookie1Name = "KituraTest1"
let cookie1Value = "Testing-Testing-1-2-3"
let cookie2Name = "KituraTest2"
let cookie2Value = "Testing-Testing"
let cookie2ExpireExpected = NSDate(timeIntervalSinceNow: 600.0)
let cookie3Name = "KituraTest3"
let cookie3Value = "A-testing-we-go"

let cookieHost = "localhost"

class TestCookies : XCTestCase {

    static var allTests : [(String, TestCookies -> () throws -> Void)] {
        return [
            ("testCookieToServer", testCookieToServer),
            ("testCookieFromServer", testCookieFromServer)
        ]
    }

    override func tearDown() {
        doTearDown()
    }

    let router = TestCookies.setupRouter()

    func testCookieToServer() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/1/cookiedump", callback: {response in
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "cookiedump route did not match single path request")
                do {
                    let data = NSMutableData()
                    let count = try response!.readAllData(data)
                    XCTAssertEqual(count, 4, "Plover's value should have been four bytes")
                    if  let ploverValue = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        XCTAssertEqual(ploverValue.bridge(), "qwer")
                    }
                    else {
                        XCTFail("Plover's value wasn't an UTF8 string")
                    }
                }
                catch {
                    XCTFail("Failed reading the body of the response")
                }
                expectation.fulfill()
            }, headers: ["Cookie": "Plover=qwer; Zxcv=tyuiop"])
        })
    }

    func testCookieFromServer() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/1/sendcookie", callback: {response in
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "/1/sendcookie route did not match single path request")

                let (cookie1, cookie1Expire) = self.cookieFromResponse(response!, named: cookie1Name)
                XCTAssert(cookie1 != nil, "Cookie \(cookie1Name) wasn't found in the response.")
                XCTAssertEqual(cookie1!.value, cookie1Value, "Value of Cookie \(cookie1Name) is not \(cookie1Value), was \(cookie1!.value)")
                XCTAssertEqual(cookie1!.path, "/", "Path of Cookie \(cookie1Name) is not (/), was \(cookie1!.path)")
                XCTAssertEqual(cookie1!.domain, cookieHost, "Domain of Cookie \(cookie1Name) is not \(cookieHost), was \(cookie1!.domain)")
#if os(Linux)
                XCTAssertFalse(cookie1!.secure, "\(cookie1Name) was marked as secure. Should have not been marked so.")
#else
                XCTAssertFalse(cookie1!.isSecure, "\(cookie1Name) was marked as secure. Should have not been marked so.")
#endif
                XCTAssertNil(cookie1Expire, "\(cookie1Name) had an expiration date. It shouldn't have had one")

                let (cookie2, cookie2Expire) = self.cookieFromResponse(response!, named: cookie2Name)
                XCTAssert(cookie2 != nil, "Cookie \(cookie2Name) wasn't found in the response.")
                XCTAssertEqual(cookie2!.value, cookie2Value, "Value of Cookie \(cookie2Name) is not \(cookie2Value), was \(cookie2!.value)")
                XCTAssertEqual(cookie2!.path, "/", "Path of Cookie \(cookie2Name) is not (/), was \(cookie2!.path)")
                XCTAssertEqual(cookie2!.domain, cookieHost, "Domain of Cookie \(cookie2Name) is not \(cookieHost), was \(cookie2!.domain)")
#if os(Linux)
                XCTAssertFalse(cookie2!.secure, "\(cookie2Name) was marked as secure. Should have not been marked so.")
#else
                XCTAssertFalse(cookie2!.isSecure, "\(cookie2Name) was marked as secure. Should have not been marked so.")
#endif
                XCTAssertNotNil(cookie2Expire, "\(cookie2Name) had no expiration date. It should have had one")
                XCTAssertEqual(cookie2Expire!, SpiUtils.httpDate(cookie2ExpireExpected))
                expectation.fulfill()
            })
        },
        { expectation in
            self.performRequest("get", path: "/2/sendcookie", callback: { response in
                XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "/2/sendcookie route did not match single path request")

                let (cookie, cookieExpire) = self.cookieFromResponse(response!, named: cookie3Name)
                XCTAssertNotNil(cookie, "Cookie \(cookie3Name) wasn't found in the response.")
                XCTAssertEqual(cookie!.value, cookie3Value, "Value of Cookie \(cookie3Name) is not \(cookie3Value), was \(cookie!.value)")
                XCTAssertEqual(cookie!.path, "/", "Path of Cookie \(cookie3Name) is not (/), was \(cookie!.path)")
                XCTAssertEqual(cookie!.domain, cookieHost, "Domain of Cookie \(cookie3Name) is not \(cookieHost), was \(cookie!.domain)")
#if os(Linux)
                XCTAssertTrue(cookie!.secure, "\(cookie3Name) wasn't marked as secure. It should have been marked so.")
#else
                XCTAssertTrue(cookie!.isSecure, "\(cookie3Name) wasn't marked as secure. It should have been marked so.")
#endif
                XCTAssertNil(cookieExpire, "\(cookie3Name) had an expiration date. It shouldn't have had one")
                expectation.fulfill()
            })
        })
    }

    func cookieFromResponse(response: ClientResponse, named: String) -> (NSHTTPCookie?, String?) {
        var resultCookie: NSHTTPCookie? = nil
        var resultExpire: String?
        for (headerKey, headerValues) in response.headers.headers  {
#if os(Linux)
            let lowercaseHeaderKey = headerKey.bridge().lowercaseString
#else
            let lowercaseHeaderKey = headerKey.lowercased()
#endif
            if  lowercaseHeaderKey  ==  "set-cookie"  {
                for headerValue in headerValues {
#if os(Linux)
            let parts = headerValue.bridge().componentsSeparatedByString("; ")
            let nameValue = parts[0].bridge().componentsSeparatedByString("=")
#else
            let parts = headerValue.componentsSeparated(by: "; ")
            let nameValue = parts[0].componentsSeparated(by: "=")
#endif
                    XCTAssertEqual(nameValue.count, 2, "Malformed Set-Cookie header \(headerValue)")

                    if  nameValue[0] == named  {
                        #if os(Linux)
                            var properties = [String: Any]()
                        #else
                            var properties = [String: AnyObject]()
                        #endif

                        properties[NSHTTPCookieName]  =  nameValue[0]
                        properties[NSHTTPCookieValue] =  nameValue[1]

                        for  part in parts[1..<parts.count] {
#if os(Linux)
                            var pieces = part.bridge().componentsSeparatedByString("=")
                            let piece = pieces[0].bridge().lowercaseString
#else
                            var pieces = part.componentsSeparated(by: "=")
                            let piece = pieces[0].bridge().lowercased()
#endif
                            switch(piece) {
                                case "secure", "httponly":
                                    properties[NSHTTPCookieSecure] = "Yes"
                                case "path" where pieces.count == 2:
                                    properties[NSHTTPCookiePath] = pieces[1]
                                case "domain" where pieces.count == 2:
                                    properties[NSHTTPCookieDomain] = pieces[1]
                                case "expires" where pieces.count == 2:
                                    resultExpire = pieces[1]
                                default:
                                    XCTFail("Malformed Set-Cookie header \(headerValue)")
                            }
                        }

                        XCTAssertNotNil(properties[NSHTTPCookieDomain], "Malformed Set-Cookie header \(headerValue)")
                        resultCookie = NSHTTPCookie(properties: properties)
                        break
                    }
                }
            }
        }

        return (resultCookie, resultExpire)
    }


    static func setupRouter() -> Router {
        let router = Router()

        router.get("/1/cookiedump") {request, response, next in
            response.status(HttpStatusCode.OK)
            if  let ploverCookie = request.cookies["Plover"]  {
                response.send(ploverCookie.value)
            }

            next()
        }

        router.get("/1/sendcookie") {request, response, next in
            response.status(HttpStatusCode.OK)

            let cookie1 = NSHTTPCookie(properties: [NSHTTPCookieName: cookie1Name,
                                                NSHTTPCookieValue: cookie1Value,
                                                NSHTTPCookieDomain: cookieHost,
                                                NSHTTPCookiePath: "/"])
            response.cookies[cookie1!.name] = cookie1
            let cookie2 = NSHTTPCookie(properties: [NSHTTPCookieName: cookie2Name,
                                                NSHTTPCookieValue: cookie2Value,
                                                NSHTTPCookieDomain: cookieHost,
                                                NSHTTPCookiePath: "/",
                                                NSHTTPCookieExpires: cookie2ExpireExpected])
            response.cookies[cookie2!.name] = cookie2

            next()
        }

        router.get("/2/sendcookie") {request, response, next in
            response.status(HttpStatusCode.OK)

            let cookie = NSHTTPCookie(properties: [NSHTTPCookieName: cookie3Name,
                                                NSHTTPCookieValue: cookie3Value,
                                                NSHTTPCookieDomain: cookieHost,
                                                NSHTTPCookiePath: "/",
                                                NSHTTPCookieSecure: "Yes"])
            response.cookies[cookie!.name] = cookie

            next()
        }

        return router
    }
}
