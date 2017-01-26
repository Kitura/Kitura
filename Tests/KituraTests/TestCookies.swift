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

let cookie1Name = "KituraTest1"
let cookie1Value = "Testing-Testing-1-2-3"
let cookie2Name = "KituraTest2"
let cookie2Value = "Testing-Testing"
let cookie2ExpireExpected = Date(timeIntervalSinceNow: 600.0)
let cookie3Name = "KituraTest3"
let cookie3Value = "A-testing-we-go"
let cookieHost = "localhost"

let responseBodySeparator = "RESPONSE-BODY-SEPARATOR"

class TestCookies: KituraTest {

    static var allTests: [(String, (TestCookies) -> () throws -> Void)] {
        return [
            ("testCookieToServerWithSemiColonSeparator", testCookieToServerWithSemiColonSeparator),
            ("testCookieToServerWithSemiColonSpaceSeparator", testCookieToServerWithSemiColonSpaceSeparator),
            ("testCookieToServerWithSemiColonWhitespacesSeparator", testCookieToServerWithSemiColonWhitespacesSeparator),
            ("testCookieFromServer", testCookieFromServer),
            ("testNoCookies", testNoCookies)
        ]
    }

    let router = TestCookies.setupRouter()

    func testCookieToServerWithSemiColonSeparator() {
        cookieToServer(separator: ";", quoteValue: false)
    }

    func testCookieToServerWithSemiColonSpaceSeparator() {
        cookieToServer(separator: "; ", quoteValue: true)
    }

    func testCookieToServerWithSemiColonWhitespacesSeparator() {
        cookieToServer(separator: "; \t ", quoteValue: true)
    }

    private func cookieToServer(separator: String, quoteValue: Bool) {
        performServerTest(router, asyncTasks: { expectation in
            let cookieMap = [" Plover ": " value with spaces ",
                           "Zxcv": "(E = mc^2)",
                           "value with one quote": "\"",
                           "empty value": "",
                           "value with embedded quotes": "x\"=\"y",
                           "name with spaces and values with equals": "=====",
                           "unicode values": "x (\u{1f3c8}) = (\u{1f37a}) y"]
            var rawCookies = [String]()
            var parsedCookies = [String]()
            for (name, value) in cookieMap {
                let name = name.trimmingCharacters(in: .whitespaces)
                if quoteValue {
                    rawCookies.append(name + "=\"" + value + "\"")
                    parsedCookies.append(name + "=" + value)
                } else {
                    rawCookies.append(name + "=" + value)
                    parsedCookies.append(name + "=" + value.trimmingCharacters(in: .whitespaces))
                }
            }

            self.performRequest("get", path: "/1/cookiedump", callback: {response in
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "cookiedump route did not match single path request")
                do {
                    var data = Data()
                    try response?.readAllData(into: &data)

                    let responseBody = String(data: data as Data, encoding: .utf8)
                    if  let responseBody = responseBody {
                        XCTAssertEqual(responseBody.components(separatedBy: responseBodySeparator).sorted(),
                                       parsedCookies.sorted())
                    } else {
                        XCTFail("Response body wasn't an UTF8 string")
                    }
                } catch {
                    XCTFail("Failed reading the body of the response")
                }
                expectation.fulfill()
            }, headers: ["Cookie": rawCookies.joined(separator: separator)])
        })
    }

    func testCookieFromServer() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/1/sendcookie", callback: {response in
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "/1/sendcookie route did not match single path request")

                let (cookie1, cookie1Expire) = self.cookieFrom(response: response, named: cookie1Name as String)
                XCTAssertNotNil(cookie1, "Cookie \(cookie1Name) wasn't found in the response.")
                if let cookie1 = cookie1 {
                    XCTAssertEqual(cookie1.value, cookie1Value as String, "Value of Cookie \(cookie1Name) is not \(cookie1Value), was \(cookie1.value)")
                    XCTAssertEqual(cookie1.path, "/", "Path of Cookie \(cookie1Name) is not (/), was \(cookie1.path)")
                    XCTAssertEqual(cookie1.domain, cookieHost as String, "Domain of Cookie \(cookie1Name) is not \(cookieHost), was \(cookie1.domain)")
                    XCTAssertFalse(cookie1.isSecure, "\(cookie1Name) was marked as secure. Should have not been marked so.")
                    XCTAssertNil(cookie1Expire, "\(cookie1Name) had an expiration date. It shouldn't have had one")
                }

                let (cookie2, cookie2Expire) = self.cookieFrom(response: response, named: cookie2Name as String)
                XCTAssertNotNil(cookie2, "Cookie \(cookie2Name) wasn't found in the response.")
                if let cookie2 = cookie2 {
                    XCTAssertEqual(cookie2.value, cookie2Value as String, "Value of Cookie \(cookie2Name) is not \(cookie2Value), was \(cookie2.value)")
                    XCTAssertEqual(cookie2.path, "/", "Path of Cookie \(cookie2Name) is not (/), was \(cookie2.path)")
                    XCTAssertEqual(cookie2.domain, cookieHost as String, "Domain of Cookie \(cookie2Name) is not \(cookieHost), was \(cookie2.domain)")
                    XCTAssertFalse(cookie2.isSecure, "\(cookie2Name) was marked as secure. Should have not been marked so.")
                    XCTAssertNotNil(cookie2Expire, "\(cookie2Name) had no expiration date. It should have had one")
                    XCTAssertEqual(cookie2Expire, SPIUtils.httpDate(cookie2ExpireExpected))
                }
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/2/sendcookie", callback: { response in
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "/2/sendcookie route did not match single path request")

                let (cookie, cookieExpire) = self.cookieFrom(response: response, named: cookie3Name as String)
                XCTAssertNotNil(cookie, "Cookie \(cookie3Name) wasn't found in the response.")
                if let cookie = cookie {
                    XCTAssertEqual(cookie.value, cookie3Value as String, "Value of Cookie \(cookie3Name) is not \(cookie3Value), was \(cookie.value)")
                    XCTAssertEqual(cookie.path, "/", "Path of Cookie \(cookie3Name) is not (/), was \(cookie.path)")
                    XCTAssertEqual(cookie.domain, cookieHost as String, "Domain of Cookie \(cookie3Name) is not \(cookieHost), was \(cookie.domain)")
                    XCTAssertTrue(cookie.isSecure, "\(cookie3Name) wasn't marked as secure. It should have been marked so.")
                    XCTAssertNil(cookieExpire, "\(cookie3Name) had an expiration date. It shouldn't have had one")
                }
                expectation.fulfill()
            })
        })
    }

    func cookieFrom(response: ClientResponse?, named: String) -> (HTTPCookie?, String?) {
        guard let response = response else {
            return (nil, nil)
        }
        var resultCookie: HTTPCookie? = nil
        var resultExpire: String?
        for (headerKey, headerValues) in response.headers {
            let lowercaseHeaderKey = headerKey.lowercased()
            if  lowercaseHeaderKey  ==  "set-cookie" {
                for headerValue in headerValues {
                    let parts = headerValue.components(separatedBy: "; ")
                    let nameValue = parts[0].components(separatedBy: "=")
                    XCTAssertEqual(nameValue.count, 2, "Malformed Set-Cookie header \(headerValue)")

                    if  nameValue[0] == named {
                        var properties = [HTTPCookiePropertyKey: Any]()
                        let cookieName = nameValue[0]
                        let cookieValue = nameValue[1]
                        properties[HTTPCookiePropertyKey.name]  =  cookieName
                        properties[HTTPCookiePropertyKey.value] =  cookieValue

                        for  part in parts[1..<parts.count] {
                            var pieces = part.components(separatedBy: "=")
                            let piece = pieces[0].lowercased()
                            switch piece {
                            case "secure", "httponly":
                                let secureValue = "Yes"
                                properties[HTTPCookiePropertyKey.secure] = secureValue
                            case "path" where pieces.count == 2:
                                let path = pieces[1]
                                properties[HTTPCookiePropertyKey.path] = path
                           case "domain" where pieces.count == 2:
                                let domain = pieces[1]
                                properties[HTTPCookiePropertyKey.domain] = domain
                            case "expires" where pieces.count == 2:
                                resultExpire = pieces[1]
                            default:
                                XCTFail("Malformed Set-Cookie header \(headerValue)")
                            }
                        }
                        XCTAssertNotNil(properties[HTTPCookiePropertyKey.domain], "Malformed Set-Cookie header \(headerValue)")
                        resultCookie = HTTPCookie(properties: properties)
                        break
                    }
                }
            }
        }

        return (resultCookie, resultExpire)
    }

    func testNoCookies() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/1/cookiedump", callback: {response in
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "cookiedump route did not match single path request")
                do {
                    var data = Data()
                    try response?.readAllData(into: &data)

                    let responseBody = String(data: data as Data, encoding: .utf8)
                    if  let responseBody = responseBody {
                        XCTAssertEqual(responseBody, "")
                    } else {
                        XCTFail("Response body wasn't an UTF8 string")
                    }
                } catch {
                    XCTFail("Failed reading the body of the response")
                }
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/1/cookiedump", callback: {response in
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "cookiedump route did not match single path request")
                do {
                    var data = Data()
                    try response?.readAllData(into: &data)

                    let responseBody = String(data: data as Data, encoding: .utf8)
                    if  let responseBody = responseBody {
                        XCTAssertEqual(responseBody, "")
                    } else {
                        XCTFail("Response body wasn't an UTF8 string")
                    }
                } catch {
                    XCTFail("Failed reading the body of the response")
                }
                expectation.fulfill()
            }, headers: ["Cookie": "ploverxyzzy"])
        })
    }

    static func setupRouter() -> Router {
        let router = Router()

        router.get("/1/cookiedump") {request, response, next in
            var cookies: [String] = []
            for (name, cookie) in request.cookies {
                cookies.append(name + "=" + cookie.value)
            }
            response.status(HTTPStatusCode.OK)
            response.send(cookies.joined(separator: responseBodySeparator))

            next()
        }

        router.get("/1/sendcookie") {request, response, next in
            response.status(HTTPStatusCode.OK)

            let cookie1 = HTTPCookie(properties: [HTTPCookiePropertyKey.name: cookie1Name,
                                                  HTTPCookiePropertyKey.value: cookie1Value,
                                                  HTTPCookiePropertyKey.domain: cookieHost,
                                                  HTTPCookiePropertyKey.path: "/"])
            let cookie2 = HTTPCookie(properties: [HTTPCookiePropertyKey.name: cookie2Name,
                                                  HTTPCookiePropertyKey.value: cookie2Value,
                                                  HTTPCookiePropertyKey.domain: cookieHost,
                                                  HTTPCookiePropertyKey.path: "/",
                                                  HTTPCookiePropertyKey.expires: cookie2ExpireExpected])
            response.cookies[cookie1!.name] = cookie1
            response.cookies[cookie2!.name] = cookie2

            next()
        }

        router.get("/2/sendcookie") {request, response, next in
            response.status(HTTPStatusCode.OK)

            let cookie = HTTPCookie(properties: [HTTPCookiePropertyKey.name: cookie3Name,
                                                 HTTPCookiePropertyKey.value: cookie3Value,
                                                 HTTPCookiePropertyKey.domain: cookieHost,
                                                 HTTPCookiePropertyKey.path: "/",
                                                 HTTPCookiePropertyKey.secure: "Yes"])
            response.cookies[cookie!.name] = cookie

            next()
        }

        return router
    }
}
