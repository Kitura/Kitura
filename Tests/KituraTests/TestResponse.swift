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

class TestResponse: KituraTest {

    static var allTests: [(String, (TestResponse) -> () throws -> Void)] {
        return [
            ("testSimpleResponse", testSimpleResponse),
            ("testOptionalStringNilResponse", testOptionalStringNilResponse),
            ("testOptionalStringResponse", testOptionalStringResponse),
            ("testLargeGet", testLargeGet),
            ("testLargePost", testLargePost),
            ("testResponseNoEndOrNext", testResponseNoEndOrNext),
            ("testEmptyHandler", testEmptyHandler),
            ("testPostRequest", testPostRequest),
            ("testPostRequestTheHardWay", testPostRequestTheHardWay),
            ("testPostJSONRequest", testPostRequest),
            ("testPostRequestWithDoubleBodyParser", testPostRequestWithDoubleBodyParser),
            ("testPostRequestUrlEncoded", testPostRequestUrlEncoded),
            ("testMultipartFormParsing", testMultipartFormParsing),
            ("testRawDataPost", testRawDataPost),
            ("testParameters", testParameters),
            ("testParametersPercent20InPath", testParametersPercent20InPath),
            ("testParametersPlusInPath", testParametersPlusInPath),
            ("testParametersPercent20InQuery", testParametersPercent20InQuery),
            ("testParametersPlusInQuery", testParametersPlusInQuery),
            ("testParametersPercentageEncoding", testParametersPercentageEncoding),
            ("testRedirect", testRedirect),
            ("testErrorHandler", testErrorHandler),
            ("testHeaderModifiers", testHeaderModifiers),
            ("testRouteFunc", testRouteFunc),
            ("testAcceptTypes", testAcceptTypes),
            ("testAcceptEncodingTypes", testAcceptEncodingTypes),
            ("testFormat", testFormat),
            ("testLink", testLink),
            ("testSubdomains", testSubdomains),
            ("testJsonp", testJsonp),
            ("testLifecycle", testLifecycle),
            ("testSend", testSend),
            ("testSendAfterEnd", testSendAfterEnd),
            ("testChangeStatusCodeOnInvokedSend", testChangeStatusCodeOnInvokedSend),
            ("testUserInfo", testUserInfo)
        ]
    }

    class SomeJSON: Codable, Equatable {
        let some: String

        init(value: String = "json") {
            self.some = value
        }

        static func ==(lhs: SomeJSON, rhs: SomeJSON) -> Bool {
            return lhs.some == rhs.some
        }
    }


    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    let router = TestResponse.setupRouter()

    func testSimpleResponse() {
    	performServerTest(router) { expectation in
            self.performRequest("get", path:"/qwer", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                //XCTAssertEqual(response?.method, "GET", "The request wasn't recognized as a get")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }
    }
    
    func testOptionalStringNilResponse() {
        performServerTest(router) { expectation in
            self.performRequest("post", path:"/sendNilString", callback: { response in
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                
                do {
                    var data = Data()
                    let body = try response?.readAllData(into: &data)
                    XCTAssertEqual(body, 0, "Expected 0 bytes, received \(String(describing: body)).")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }
    }
    
    func testOptionalStringResponse() {
        performServerTest(router) { expectation in
            self.performRequest("post", path:"/sendNonNilString", callback: { response in
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "Test")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }
    }

    func testLargeGet() {
        performServerTest(router, timeout: 30) { expectation in
            let uint8 = UInt8.max
            let count = 1024 * 1024

            self.performRequest("get", path:"/largeGet?uint8=\(uint8)&count=\(count)", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")

                do {
                    var data = Data(capacity: count/32)
                    let length = try response?.readAllData(into: &data)
                    XCTAssertEqual(length, count, "Expected \(count) bytes, received \(String(describing: length)).")
                    XCTAssertEqual(data, Data(repeating: uint8, count: count), "Received data different from expected data")
                } catch {
                    XCTFail("Error reading body")
                }

                expectation.fulfill()
            })
        }
    }

    func testLargePost() {
        performServerTest(router, timeout: 30) { expectation in
            let count = 1024 * 1024
            let postData = Data(repeating: UInt8.max, count: count)

            self.performRequest("post", path: "/largePost", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")

                do {
                    var data = Data(capacity: count/32)
                    let length = try response?.readAllData(into: &data)
                    XCTAssertEqual(length, count, "Expected \(count) bytes, received \(String(describing: length)).")
                    XCTAssertEqual(data, postData, "Received data different from posted data")
                } catch {
                    XCTFail("Error reading body")
                }

                expectation.fulfill()
            }, requestModifier: { request in
                request.write(from: postData)
            })
        }
    }

    func testResponseNoEndOrNext() {
        performServerTest(router) { expectation in
            self.performRequest("get", path:"/noEndOrNext", callback: {response in
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>noEndOrNext</b></body></html>\n\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }
    }

    func testEmptyHandler() {
        performServerTest(router) { expectation in
            self.performRequest("get", path:"/emptyHandler", callback: {response in
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.serviceUnavailable, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                do {
                    let body = try response?.readString()
                    XCTAssertNil(body, "No body expected, but was received: '\(body!)'")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }
    }

    func testPostRequest() {
    	performServerTest(router) { expectation in
            self.performRequest("post", path: "/bodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                //XCTAssertEqual(response?.method, "POST", "The request wasn't recognized as a post")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Received text body: </b>plover\nxyzzy\n</body></html>\n\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            }) {req in
                req.write(from: "plover\n")
                req.write(from: "xyzzy\n")
            }
        }
    }

    func testPostRequestTheHardWay() {
        performServerTest(router) { expectation in
            self.performRequest("post", path: "/bodytesthardway", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "Read 13 bytes")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            }) {req in
                req.write(from: "plover\n")
                req.write(from: "xyzzy\n")
            }
        }
    }

    func testPostJSONRequest() {
        let jsonToTest = SomeJSON()

        performServerTest(router) { expectation in
            self.performRequest("post", path: "/bodytest", callback: { response in
                guard let response = response else {
                    XCTFail("ClientRequest response object was nil")
                    expectation.fulfill()
                    return
                }
                XCTAssertNotNil(response.headers["Date"], "There was No Date header in the response")
                do {
                    var body = Data()
                    guard try response.read(into: &body) > 0  else {
                        XCTFail("body in response is nil")
                        expectation.fulfill()
                        return
                    }
                    let returnedJSON = try TestResponse.decoder.decode(SomeJSON.self, from: body)
                    XCTAssertEqual(returnedJSON, jsonToTest)
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            }, headers: ["Content-Type": "application/json"]) { req in
                do {
                    let jsonData = try TestResponse.encoder.encode(jsonToTest)
                    req.write(from: jsonData)
                    req.write(from: "\n")
                } catch {
                    XCTFail("caught error \(error)")
                }
            }
        }
    }

    func testPostRequestWithDoubleBodyParser() {
        performServerTest(router) { expectation in
            self.performRequest("post", path: "/doublebodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                //XCTAssertEqual(response?.method, "POST", "The request wasn't recognized as a post")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Received text body: </b>plover\nxyzzy\n</body></html>\n\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            }) {req in
                req.write(from: "plover\n")
                req.write(from: "xyzzy\n")
            }
        }
    }

    func testPostRequestUrlEncoded() {
        performServerTest(router) { expectation in
            self.performRequest("post", path: "/bodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Received URL encoded body</b><br> [\"swift\": \"rocks\"] </body></html>\n\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            }) {req in
                req.headers["Content-Type"] = "application/x-www-form-urlencoded"
                req.write(from: "swift=rocks")
            }
        }
        // repeat the same test with a Content-Type parameter of charset=UTF-8
        performServerTest(router) { expectation in
            self.performRequest("post", path: "/bodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Received URL encoded body</b><br> [\"swift\": \"rocks\"] </body></html>\n\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            }) {req in
                req.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
                req.write(from: "swift=rocks")
            }
        }
        // Now try the multi-value body parser
        performServerTest(router) { expectation in
            self.performRequest("post", path: "/bodytestMultiValue", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertNotNil(response?.headers["Date"], "There was No Date header in the response")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Received URL encoded body</b><br> [\"swift\": [\"rocks\", \"rules\"]] </body></html>\n\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            }) {req in
                req.headers["Content-Type"] = "application/x-www-form-urlencoded"
                req.write(from: "swift=rocks&swift=rules")
            }
        }

    }

    func dataComponentsTest(_ searchString: String, separator: String) {
        let stringFind = searchString.components(separatedBy: separator)

        // test Data.components extension
        var separatorData = Data()
        if let data = separator.data(using: .utf8) {
            separatorData = data
        }
        var searchData = Data()
        if let data = searchString.data(using: .utf8) {
            searchData = data
        }
        let dataFind = searchData.components(separatedBy: separatorData)
        // ensure we get the same sized array back
        XCTAssert(dataFind.count == stringFind.count)
        // test to ensure the strings are equal
        for i in 0 ..< stringFind.count {
            let dataString = String(data: dataFind[i], encoding: .utf8)
            XCTAssertEqual(stringFind[i], dataString)
        }
    }

    func testMultipartFormParsing() {

        // ensure NSData.components works just like String.components
        dataComponentsTest("AxAyAzA", separator: "A")
        dataComponentsTest("HelloWorld", separator: "World")
        dataComponentsTest("ababababababababababa", separator: "b")
        dataComponentsTest("Invalid separator", separator: "")
        dataComponentsTest("", separator: "Invalid search string")

        performServerTest(router) { expectation in
            self.performRequest("post", path: "/multibodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "text  text(\"text default\") file1 a.txt text(\"Content of a.txt.\") file2 a.html text(\"<!DOCTYPE html><title>Content of a.html.</title>\") ")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            }) {req in
                req.headers["Content-Type"] = "multipart/form-data; boundary=---------------------------9051914041544843365972754266"
                req.write(from: "-----------------------------9051914041544843365972754266\r\n" +
                    "Content-Disposition: form-data; name=\"text\"\r\n\r\n" +
                    "text default\r\n" +
                    "-----------------------------9051914041544843365972754266\r\n" +
                    "Content-Disposition: form-data; name=\"file1\"; filename=\"a.txt\"\r\n" +
                    "Content-Type: text/plain\r\n\r\n" +
                    "Content of a.txt.\r\n" +
                    "-----------------------------9051914041544843365972754266\r\n" +
                    "Content-Disposition: form-data; name=\"file2\"; filename=\"a.html\"\r\n" +
                    "Content-Type: text/html\r\n\r\n" +
                    "<!DOCTYPE html><title>Content of a.html.</title>\r\n" +
                    "-----------------------------9051914041544843365972754266--")
            }
        }
        // repeat the test with blank headers (allowed as per section 5.1 of RFC 2046) and custom headers that should be skiped
        performServerTest(router) { expectation in
            self.performRequest("post", path: "/multibodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "  text(\"text default\") file1 a.txt text(\"Content of a.txt.\") file2 a.html text(\"<!DOCTYPE html><title>Content of a.html.</title>\") ")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            }) {req in
                req.headers["Content-Type"] = "multipart/form-data; boundary=---------------------------9051914041544843365972754266"
                req.write(from: "This is a preamble and should be ignored" +
                    "\r\n-----------------------------9051914041544843365972754266\r\n" +
                    "\r\n" +
                    "text default\r\n" +
                    "-----------------------------9051914041544843365972754266\r\n" +
                    "Content-Disposition: form-data; name=\"file1\"; filename=\"a.txt\"\r\n" +
                    "Content-Type: text/plain\r\n" +
                    "X-Arbitrary-Header: we should ignore this\r\n\r\n" +
                    "Content of a.txt.\r\n" +
                    "-----------------------------9051914041544843365972754266\r\n" +
                    "Content-Disposition: form-data; name=\"file2\"; filename=\"a.html\"\r\n" +
                    "Content-Type: text/html\r\n" +
                    "X-Arbitrary-Header2: we should ignore this too\r\n\r\n" +
                    "<!DOCTYPE html><title>Content of a.html.</title>\r\n" +
                    "-----------------------------9051914041544843365972754266--")
            }
        }
        // One more test to ensure we handle Content-Type with a parameter after the bounadary
        performServerTest(router) { expectation in
            self.performRequest("post", path: "/multibodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "  text(\"text default\") ")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            }) {req in
                req.headers["Content-Type"] = "multipart/form-data; boundary=ZZZY70gRGgDPOiChzXcmW3psiU7HlnC; charset=US-ASCII"
                req.write(from: "Preamble" +
                    "\r\n--ZZZY70gRGgDPOiChzXcmW3psiU7HlnC\r\n" +
                    "\r\n" +
                    "text default\r\n" +
                    "--ZZZY70gRGgDPOiChzXcmW3psiU7HlnC--")
            }
        }

        // Negative test case - valid boundary but an invalid body
        performServerTest(router) { expectation in
            self.performRequest("post", path: "/multibodytest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "Cannot POST /multibodytest.")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            }) {req in
                req.headers["Content-Type"] = "multipart/form-data; boundary=ABDCEFG"
                req.write(from: "This does not contain any valid boundary")
            }
        }

    }

    func testRawDataPost() {
        performServerTest(router) { expectation in
            self.performRequest("post",
                                path: "/bodytest",
                                callback: { response in
                                    guard let response = response else {
                                        XCTFail("Client response was nil on raw data post.")
                                        expectation.fulfill()
                                        return
                                    }

                                    XCTAssertNotNil(response.headers["Date"], "There was No Date header in the response")
                                    do {
                                        let responseString = try response.readString()
                                        XCTAssertEqual("length: 2048", responseString)
                                    } catch {
                                        XCTFail("Failed posting raw data")
                                    }
                                    expectation.fulfill()
                                },
                                headers: ["Content-Type": "application/octet-stream"],
                                requestModifier: { request in
                                    let length = 2048
                                    let bytes = [UInt32](repeating: 0, count: length).map { _ in 0 }
                                    let randomData = Data(bytes: bytes, count: length)
                                    request.write(from: randomData)
            })
        }
    }

    private func runTestParameters(pathParameter: String, queryParameter: String,
                                   expectedReturnedPathParameter: String? = nil,
                                   expectedReturnedQueryParameter: String? = nil) {
        let expectedReturnedPathParameter = expectedReturnedPathParameter ?? pathParameter
        let expectedReturnedQueryParameter = expectedReturnedQueryParameter ?? queryParameter
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/zxcv/\(pathParameter)?q=\(queryParameter)",
                callback: { response in
                guard let response = response else {
                    XCTFail("ClientRequest response object was nil")
                    expectation.fulfill()
                    return
                }

                do {
                    let body = try response.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Received /zxcv</b><p>" +
                        "<p>p1=\(expectedReturnedPathParameter)<p>" +
                        "<p>q=\(expectedReturnedQueryParameter)<p>" +
                        "<p>u1=Ploni Almoni</body></html>\n\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }
    }

    func testParameters() {
        runTestParameters(pathParameter: "test1", queryParameter: "test2")
    }

    func testParametersPercent20InPath() {
        runTestParameters(pathParameter: "John%20Doe", queryParameter: "test2",
                          expectedReturnedPathParameter: "John Doe")
    }

    func testParametersPlusInPath() {
        runTestParameters(pathParameter: "John+Doe", queryParameter: "test2",
                          expectedReturnedPathParameter: "John+Doe")
    }

    func testParametersPercent20InQuery() {
        runTestParameters(pathParameter: "test1", queryParameter: "John%20Doe",
                          expectedReturnedQueryParameter: "John Doe")
    }

    func testParametersPlusInQuery() {
        runTestParameters(pathParameter: "test1", queryParameter: "John+Doe",
                          expectedReturnedQueryParameter: "John Doe")
    }

    func testParametersPercentageEncoding() {
        runTestParameters(pathParameter: "John%40Doe", queryParameter: "Jane%2BRoe",
                          expectedReturnedPathParameter: "John@Doe",
                          expectedReturnedQueryParameter: "Jane+Roe")
    }

    func testRedirect() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/redirect", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "redirected to new route")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }
    }

    func testErrorHandler() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/error", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                do {
                    let body = try response?.readString()
                    let errorDescription = "foo is nil"
                    XCTAssertEqual(body, "Caught the error: \(errorDescription)")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }
    }

    func testRouteFunc() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/route", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "get 1\nget 2\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("post", path: "/route", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "post received")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        })
    }

    func testHeaderModifiers() {

        router.get("/headerTest") { _, response, next in

            response.headers.append("Content-Type", value: "text/html")
            XCTAssertEqual(response.headers["Content-Type"], "text/html")

            response.headers.append("Content-Type", value: "text/plain; charset=utf-8")
            XCTAssertEqual(response.headers["Content-Type"], "text/html")

            response.headers["Content-Type"] = nil
            XCTAssertNil(response.headers["Content-Type"])

            response.headers.append("Content-Type", value: "text/plain, image/png")
            XCTAssertEqual(response.headers["Content-Type"], "text/plain, image/png")

            response.headers.append("Content-Type", value: "text/html, image/jpeg")
            XCTAssertEqual(response.headers["Content-Type"], "text/plain, image/png")

            response.headers.append("Content-Type", value: "charset=UTF-8")
            XCTAssertEqual(response.headers["Content-Type"], "text/plain, image/png")

            response.headers["Content-Type"] = nil

            response.headers.append("Content-Type", value: "text/html")
            XCTAssertEqual(response.headers["Content-Type"], "text/html")

            response.headers.append("Content-Type", value: "image/png, text/plain")
            XCTAssertEqual(response.headers["Content-Type"], "text/html")

            do {
                try response.status(HTTPStatusCode.OK).send("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n").end()
            } catch {}
            next()
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/headerTest", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            })
        }

    }

    func testAcceptTypes() {

        router.get("/customPage") { request, response, next in

            XCTAssertEqual(request.accepts(type: "html"), "html", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(types: "text/html"), "text/html", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(types: ["json", "text"]), "json", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(types: "application/json"), "application/json", "Accepts did not return expected value")

            // test for headers with * subtype
            XCTAssertEqual(request.accepts(types: "application/xml"), "application/xml", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(types: "xml", "json"), "json", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(types: "html", "xml", "png"), "html", "Accepts did not return expected value")

            // shouldn't match anything
            XCTAssertNil(request.accepts(types: "image/png"), "Request accepts this type when it shouldn't")
            XCTAssertNil(request.accepts(types: "png"), "Request accepts this type when it shouldn't")
            XCTAssertNil(request.accepts(types: "unreal"), "Invalid extension was accepted!")

            do {
                try response.status(HTTPStatusCode.OK).send("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n").end()
            } catch {}
            next()
        }

        router.get("/customPage2") { request, response, next in

            XCTAssertEqual(request.accepts(types: "image/png"), "image/png", "Request accepts this type when it shouldn't")
            XCTAssertEqual(request.accepts(types: "image/tiff"), "image/tiff", "Request accepts this type when it shouldn't")
            XCTAssertEqual(request.accepts(types: "json", "jpeg", "html"), "html", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(types: ["png", "html"]), "html", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(types: ["xml", "html", "unreal"]), "html", "Accepts did not return expected value")

            do {
                try response.status(HTTPStatusCode.OK).send("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n").end()
            } catch {}
            next()
        }

        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/customPage", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            }) {req in
                req.headers = ["Accept": "text/*;q=.5, application/json, application/*;q=.3"]
            }
        }, { expectation in
            self.performRequest("get", path:"/customPage2", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            }) {req in
                req.headers = ["accept": "*/*;q=.001, application/*;q=0.2, image/jpeg;q=0.8, text/html, text/plain"]
            }
        })
    }

    func testAcceptEncodingTypes() {
        router.get("/customPage") { request, response, next in
            XCTAssertEqual(request.accepts(header: "Accept-Encoding", type: "gzip"), "gzip", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(header: "Accept-Encoding", types: "compress"), "compress", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(header: "Accept-Encoding", types: ["compress", "gzip"]), "gzip", "Accepts did not return expected value")

            // should NOT match "*" here as q = 0
            XCTAssertNil(request.accepts(header: "Accept-Encoding", types: "deflate"), "Request accepts this type when it shouldn't")

            do {
                try response.status(HTTPStatusCode.OK).send("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n").end()
            } catch {}
            next()
        }

        router.get("/customPage2") { request, response, next in
            XCTAssertEqual(request.accepts(header: "Accept-Encoding", type: "gzip"), "gzip", "Accepts did not return expected value")
            XCTAssertEqual(request.accepts(header: "Accept-Encoding", types: "compress"), "compress", "Accepts did not return expected value")
            //should match compress instead of gzip here as q value is greater
            XCTAssertEqual(request.accepts(header: "Accept-Encoding", types: ["compress", "gzip"]), "compress", "Accepts did not return expected value")

            // should match "*" here as q > 0
            XCTAssertEqual(request.accepts(header: "Accept-Encoding", types: "deflate"), "deflate", "Accepts did not return expected value")

            // should NOT match here as header is incorrect
            XCTAssertNil(request.accepts(header: "Accept-Charset", types: "deflate"), "Request accepts this type when it shouldn't")

            do {
                try response.status(HTTPStatusCode.OK).send("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n").end()
            } catch {}
            next()
        }

        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/customPage", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            }) {req in
                req.headers = ["Accept-Encoding": "compress;q=0.5, gzip;q=1.0, *;q=0"]
            }
        }, { expectation in
            self.performRequest("get", path:"/customPage2", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                expectation.fulfill()
            }) {req in
                req.headers = ["accept-encoding": "gzip;q=0.5, compress;q=1.0, *;q=0.001"]
            }
        })
    }

    func testFormat() {
        performServerTest(router) { expectation in
            self.performRequest("get", path:"/format", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertEqual(response?.headers["Content-Type"]?.first, "text/html")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body>Hi from Kitura!</body></html>\n\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
                }, headers: ["Accept": "text/html"])
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path:"/format", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertEqual(response?.headers["Content-Type"]?.first, "text/plain")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "Hi from Kitura!")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
                }, headers: ["Accept": "text/plain"])
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path:"/format", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "default")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
                }, headers: ["Accept": "text/cmd"])
        }

    }

    func testLink() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/single_link", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                let header = response?.headers["Link"]?.first
                XCTAssertNotNil(header, "Link header should not be nil")
                XCTAssertEqual(header, "<https://developer.ibm.com/swift>; rel=\"root\"")
                expectation.fulfill()
            })
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/multiple_links", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                let firstLink = "<https://developer.ibm.com/swift/products/ibm-swift-sandbox/>; rel=\"next\""
                let secondLink = "<https://developer.ibm.com/swift/products/ibm-bluemix/>; rel=\"prev\""
                let header = response?.headers["Link"]?.first
                XCTAssertNotNil(header, "Link header should not be nil")
                XCTAssertNotNil(header?.range(of: firstLink), "link header should contain first link")
                XCTAssertNotNil(header?.range(of: secondLink), "link header should contain second link")
                expectation.fulfill()
            })
        }
    }

    func testJsonp() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/jsonp?callback=testfn", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    let expected = "{\"some\":\"json\"}"

                    XCTAssertEqual(body, "/**/ testfn(\(expected))")
                    XCTAssertEqual(response?.headers["Content-Type"]?.first, "application/javascript")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/jsonp?callback=test+fn", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.badRequest, "HTTP Status code was \(String(describing: response?.statusCode))")
                expectation.fulfill()
            })
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/jsonp", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.badRequest, "HTTP Status code was \(String(describing: response?.statusCode))")
                expectation.fulfill()
            })
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/jsonp_cb?cb=testfn", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    let expected = "{\"some\":\"json\"}"

                    XCTAssertEqual(body, "/**/ testfn(\(expected))")
                    XCTAssertEqual(response?.headers["Content-Type"]?.first, "application/javascript")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/jsonp_encoded?callback=testfn", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    let expected = "{\"some\":\"json with bad js chars \\u2028 \\u2029\"}"

                    XCTAssertEqual(body, "/**/ testfn(\(expected))")
                    XCTAssertEqual(response?.headers["Content-Type"]?.first, "application/javascript")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }
    }

    func testSubdomains() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/subdomains", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                let hostHeader = response?.headers["Host"]?.first
                let domainHeader = response?.headers["Domain"]?.first
                let subdomainsHeader = response?.headers["Subdomain"]?.first

                XCTAssertEqual(hostHeader, "localhost", "Wrong http response host")
                XCTAssertEqual(domainHeader, "localhost", "Wrong http response domain")
                XCTAssertEqual(subdomainsHeader, "", "Wrong http response subdomains")
                expectation.fulfill()
            })
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/subdomains", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                let hostHeader = response?.headers["Host"]?.first
                let domainHeader = response?.headers["Domain"]?.first
                let subdomainsHeader = response?.headers["Subdomain"]?.first

                XCTAssertEqual(hostHeader, "a.b.c.example.com", "Wrong http response host")
                XCTAssertEqual(domainHeader, "example.com", "Wrong http response domain")
                XCTAssertEqual(subdomainsHeader, "a, b, c", "Wrong http response subdomains")
                expectation.fulfill()
            }, headers: ["Host": "a.b.c.example.com"])
        }

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/subdomains", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                let hostHeader = response?.headers["Host"]?.first
                let domainHeader = response?.headers["Domain"]?.first
                let subdomainsHeader = response?.headers["Subdomain"]?.first

                XCTAssertEqual(hostHeader, "a.b.c.d.example.co.uk", "Wrong http response host")
                XCTAssertEqual(domainHeader, "example.co.uk", "Wrong http response domain")
                XCTAssertEqual(subdomainsHeader, "a, b, c, d", "Wrong http response subdomains")
                expectation.fulfill()
            }, headers: ["Host": "a.b.c.d.example.co.uk"])
        }
    }

    func testLifecycle() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/lifecycle", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertEqual(response?.headers["x-lifecycle"]?.first, "kitura", "Wrong lifecycle header")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Filtered</b></body></html>\n\n")
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }
    }

    func testSend() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/data", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    var body = Data()
                    _ = try response?.read(into: &body)
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n".data(using: .utf8)!)
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        }

        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/json", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertEqual(response?.headers["Content-Type"]?.first, "application/json", "Wrong Content-Type header")
                do {
                    var body = Data()
                    _ = try response?.read(into: &body)
                    let json = try TestResponse.decoder.decode(SomeJSON.self, from: body)
                    XCTAssertEqual(SomeJSON(), json)
                } catch {
                    XCTFail("Error reading body")
                }
                expectation.fulfill()
            })
        },
        { expectation in
            self.performRequest("get", path: "/jsonDictionary", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertEqual(response?.headers["Content-Type"]?.first, "application/json", "Wrong Content-Type header")
                do {
                    let json = try response?.readString()
                    XCTAssertEqual("{\"some\":\"json\"}", json)
                } catch {
                    XCTFail("Error reading body. Error=\(error.localizedDescription)")
                }
                expectation.fulfill()
            })
        },
        { expectation in
            self.performRequest("get", path: "/jsonCodableDictionary", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertEqual(response?.headers["Content-Type"]?.first, "application/json", "Wrong Content-Type header")
                do {
                    var body = Data()
                    _ = try response?.read(into: &body)
                    let dict = try TestResponse.decoder.decode([String: SomeJSON].self, from: body)
                    XCTAssertEqual(["some": SomeJSON()], dict)
                } catch {
                    XCTFail("Error reading body. Error=\(error.localizedDescription)")
                }
                expectation.fulfill()
            })
        },
        { expectation in
            self.performRequest("get", path: "/jsonArray", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertEqual(response?.headers["Content-Type"]?.first, "application/json", "Wrong Content-Type header")
                do {
                    let json = try response?.readString()
                    XCTAssertEqual("[\n  \"some\",\n  10,\n  \"json\"\n]", json)
                } catch {
                    XCTFail("Error reading body. Error=\(error.localizedDescription)")
                }
                expectation.fulfill()
            })
        },
        { expectation in
            self.performRequest("get", path: "/jsonCodableArray", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertEqual(response?.headers["Content-Type"]?.first, "application/json", "Wrong Content-Type header")
                do {
                    var body = Data()
                    _ = try response?.read(into: &body)
                    let json = try TestResponse.decoder.decode([SomeJSON].self, from: body)
                    XCTAssertEqual([SomeJSON(), SomeJSON()], json)
                } catch {
                    XCTFail("Error reading body. Error=\(error.localizedDescription)")
                }
                expectation.fulfill()
            })
        })

        performServerTest(router) { expectation in
            self.performRequest("get", path: "/download", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                XCTAssertEqual(response?.headers["Content-Type"]?.first, "text/html", "Wrong Content-Type header")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                } catch {
                    XCTFail("Error reading body. Error=\(error.localizedDescription)")
                }

                expectation.fulfill()
            })
        }

    }

    func testSendAfterEnd() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/send_after_end", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.forbidden, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body?.lowercased(), "forbidden<!DOCTYPE html><html><body><b>forbidden</b></body></html>\n\n".lowercased())
                } catch {
                    XCTFail("Error reading body. Error=\(error.localizedDescription)")
                }
                expectation.fulfill()
            })
        }
    }

    func testChangeStatusCodeOnInvokedSend() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/code_unknown_to_ok", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, .OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                expectation.fulfill()
            })
        },
        { expectation in
            self.performRequest("get", path: "/code_notFound_no_change", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, .notFound, "HTTP Status code was \(String(describing: response?.statusCode))")
                expectation.fulfill()
            })
        })
    }

    func testUserInfo() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/user_info", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "hello world")
                } catch {
                    XCTFail("Error reading body. Error=\(error.localizedDescription)")
                }
                expectation.fulfill()
            })
        }
    }
    
    static func setupRouter() -> Router {
        let router = Router()

        // subdomains test
        router.get("subdomains") { request, response, next in
            response.headers["Host"] = request.hostname
            response.headers["Domain"] = request.domain

            let subdomains = request.subdomains

            response.headers["Subdomain"] = subdomains.joined(separator: ", ")

            response.status(.OK)
            next()
        }

        // the same router definition is used for all these test cases
        router.all("/zxcv/:p1") { request, _, next in
            request.userInfo["u1"] = "Ploni Almoni"
            next()
        }

        router.get("/qwer") { _, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            do {
                try response.send("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n").end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
            next()
        }

        router.get("/largeGet") { request, response, _ in
            do {
                let uint8 = UInt8(request.queryParameters["uint8"] ?? "NA")
                let count = Int(request.queryParameters["count"] ?? "NA")
                if let uint8 = uint8, let count = count {
                    response.send(data: Data(repeating: uint8, count: count))
                }
                try response.end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
        }

        router.post("/largePost") { request, response, _ in
            do {
                var data = Data()
                let count = try request.read(into: &data)
                try response.send(data: data).end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
        }
        
        router.post("/sendNilString") { request, response, _ in
            do {
                let str: String? = nil
                try response.send(str).end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
        }
        
        router.post("/sendNonNilString") { request, response, _ in
            do {
                let str: String? = "Test"
                try response.send(str).end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
        }

        router.get("/noEndOrNext") { _, response, _ in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            response.send("<!DOCTYPE html><html><body><b>noEndOrNext</b></body></html>\n\n")
        }

        router.get("/emptyHandler") { _, _, _ in
        }

        router.get("/zxcv/:p1") { request, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            let p1 = request.parameters["p1"] ?? "(nil)"
            let q = request.queryParameters["q"] ?? "(nil)"
            let u1 = request.userInfo["u1"] as? String ?? "(nil)"
            do {
                try response.send("<!DOCTYPE html><html><body><b>Received /zxcv</b><p><p>p1=\(p1)<p><p>q=\(q)<p><p>u1=\(u1)</body></html>\n\n").end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
            next()
        }

        router.get("/redirect") { _, response, next in
            do {
                try response.redirect("/redirected")
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }

            next()
        }
        
        router.get("/redirected") { _, response, next in
            do {
                try response.send("redirected to new route").end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
                next()
            }
        }

        // Error handling example
        router.get("/error") { _, response, next in
            response.status(HTTPStatusCode.internalServerError)
            response.error = InternalError.nilVariable(variable: "foo")
            next()
        }

        router.route("/route")
        .get { _, response, next in
            response.send("get 1\n")
            next()
        }
        .post {_, response, next in
            response.send("post received")
            next()
        }
        .get { _, response, next in
            response.send("get 2\n")
            next()
        }

        let bodyTestHandler: RouterHandler = { request, response, next in
            guard let requestBody = request.body else {
                next ()
                return
            }

            if let urlEncoded = requestBody.asURLEncoded {
                do {
                    response.headers["Content-Type"] = "text/html; charset=utf-8"
                    try response.send("<!DOCTYPE html><html><body><b>Received URL encoded body</b><br> \(urlEncoded) </body></html>\n\n").end()
                } catch {
                    XCTFail("caught error: \(error)")
                }
            } else if let urlEncoded = requestBody.asURLEncodedMultiValue {
                do {
                    response.headers["Content-Type"] = "text/html; charset=utf-8"
                    try response.send("<!DOCTYPE html><html><body><b>Received URL encoded body</b><br> \(urlEncoded) </body></html>\n\n").end()
                } catch {
                    XCTFail("caught error: \(error)")
                }
            } else if let text = requestBody.asText {
                do {
                    response.headers["Content-Type"] = "text/html; charset=utf-8"
                    try response.send("<!DOCTYPE html><html><body><b>Received text body: </b>\(text)</body></html>\n\n").end()
                } catch {
                    XCTFail("caught error: \(error)")
                }
            } else if let json = requestBody.asJSON {
                do {
                    response.headers["Content-Type"] = "application/json; charset=utf-8"
                    try response.send(json: json).end()
                } catch {
                    XCTFail("caught error: \(error)")
                }
            } else if let data = requestBody.asRaw {
                XCTAssertNotNil(data)
                let length = "2048"
                _ = response.send("length: \(length)")
                next()
            } else {
                response.error = Error.failedToParseRequestBody(body: "\(String(describing: request.body))")
            }

            next()
        }

        router.all("/bodytestMultiValue", allowPartialMatch: false, middleware: BodyParserMultiValue())
        router.post("/bodytestMultiValue", handler: bodyTestHandler)

        router.all("/bodytest", allowPartialMatch: false, middleware: BodyParser())
        router.post("/bodytest", handler: bodyTestHandler)

        router.post("/bodytesthardway") { request, response, next in
            let body = try request.readString()
            response.status(.OK).send("Read \(body?.count ?? 0) bytes")
            next()
        }

        //intentially BodyParser is added twice, to check how two body parsers work together
        router.all("/doublebodytest", middleware: BodyParser())
        router.all("/doublebodytest", middleware: BodyParser())
        router.post("/doublebodytest", handler: bodyTestHandler)

        router.all("/multibodytest", middleware: BodyParser())

        router.post("/multibodytest") { request, response, next in
            guard let body = request.body else {
                next ()
                return
            }
            guard let parts = body.asMultiPart else {
                response.error = Error.failedToParseRequestBody(body: "\(String(describing: request.body))")
                next ()
                return
            }
            for part in parts {
                response.send("\(part.name) \(part.filename) \(part.body) ")
            }

            next()
        }

        func callbackText(request: RouterRequest, response: RouterResponse) {
            do {
                try response.status(HTTPStatusCode.OK).send("Hi from Kitura!").end()
            } catch {}

        }

        func callbackHtml(request: RouterRequest, response: RouterResponse) {
            do {
                try response.status(HTTPStatusCode.OK).send("<!DOCTYPE html><html><body>Hi from Kitura!</body></html>\n\n").end()
            } catch {}

        }

        func callbackDefault(request: RouterRequest, response: RouterResponse) {
            do {
                response.headers["Content-Type"] = "text/plain; charset=utf-8"
                try response.status(HTTPStatusCode.OK).send("default").end()
            } catch {}

        }

        router.get("/format") { _, response, _ in
            do {
                try response.format(callbacks: [
                                                   "text/plain": callbackText,
                                                   "text/html": callbackHtml,
                                                   "default": callbackDefault])
            } catch {}
        }

        router.get("/single_link") { _, response, _ in
            do {
                response.headers.addLink("https://developer.ibm.com/swift",
                                     linkParameters: [.rel: "root"])
                try response.status(.OK).end()
            } catch {}
        }

        router.get("/multiple_links") { _, response, _ in
            do {
                response.headers.addLink("https://developer.ibm.com/swift/products/ibm-bluemix/",
                         linkParameters: [.rel: "prev"])
                response.headers.addLink("https://developer.ibm.com/swift/products/ibm-swift-sandbox/",
                         linkParameters: [.rel: "next"])
                try response.status(.OK).end()
            } catch {}
        }

        router.get("/jsonp") { _, response, _ in
            let json = SomeJSON()

            do {
                do {
                    try response.send(jsonp: json).end()
                } catch JSONPError.invalidCallbackName {
                    try response.status(.badRequest).end()
                }
            } catch {}
        }

        router.get("/jsonp_cb") { _, response, _ in
            let json = SomeJSON()

            do {
                do {
                    try response.send(jsonp: json, callbackParameter: "cb").end()
                } catch JSONPError.invalidCallbackName {
                    try response.status(.badRequest).end()
                }
            } catch {}
        }

        router.get("/jsonp_encoded") { _, response, _ in
            #if os(Linux)
                let json = SomeJSON(value: "json with bad js chars \u{2028} \u{2029}")
            #else
                let json = SomeJSON(value: ("json with bad js chars \u{2028} \u{2029}" as NSString) as String)
            #endif
            do {
                do {
                    try response.send(jsonp: json).end()
                } catch JSONPError.invalidCallbackName {
                    try response.status(.badRequest).end()
                }
            } catch {}
        }

        router.get("/lifecycle") { _, response, next in
            var previousOnEndInvoked: LifecycleHandler? = nil
            let onEndInvoked = {
                response.headers["x-lifecycle"] = "kitura"
                previousOnEndInvoked!()
            }
            previousOnEndInvoked = response.setOnEndInvoked(onEndInvoked)

            var previousWrittenDataFilter: WrittenDataFilter? = nil
            let writtenDataFilter: WrittenDataFilter = { _ in
                let newBody = "<!DOCTYPE html><html><body><b>Filtered</b></body></html>\n\n"
                return previousWrittenDataFilter!(newBody.data(using: .utf8)!)
            }
            previousWrittenDataFilter = response.setWrittenDataFilter(writtenDataFilter)

            response.headers["Content-Type"] = "text/html; charset=utf-8"
            do {
                try response.send("<!DOCTYPE html><html><body><b>Lifecycle</b></body></html>\n\n").end()
            } catch {}
            next()
        }

        router.get("/data") { _, response, next in
            do {
                try response.send(data: "<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n".data(using: .utf8)!).end()
            } catch {}
            next()
        }

        router.get("/json") { _, response, next in
            response.headers["Content-Type"] = "application/json"
            do {
                try response.send(SomeJSON()).end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
            next()
        }

        router.get("/jsonDictionary") { _, response, next in
            response.headers["Content-Type"] = "application/json"
            do {
                try response.send(json: ["some": "json"]).end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
            next()
        }

        router.get("/jsonArray") { _, response, next in
            response.headers["Content-Type"] = "application/json"
            do {
                try response.send(json: ["some", 10, "json"]).end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
            next()
        }

        router.get("/jsonCodableDictionary") { _, response, next in
            response.headers["Content-Type"] = "application/json"
            do {
                try response.send(json: ["some": SomeJSON()]).end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
            next()
        }

        router.get("/jsonCodableArray") { _, response, next in
            response.headers["Content-Type"] = "application/json"
            do {
                try response.send(json: [SomeJSON(), SomeJSON()]).end()
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
            next()
        }

        router.get("/download") { _, response, next in
            do {
                try response.send(download: "./Tests/KituraTests/TestStaticFileServer/index.html")
            } catch {
                XCTFail("Error sending response. Error=\(error.localizedDescription)")
            }
            next()
        }

        router.get("/send_after_end") { _, response, next in
            do {
                let json = SomeJSON()

                try response.send(status: HTTPStatusCode.forbidden).send(data: "<!DOCTYPE html><html><body><b>forbidden</b></body></html>\n\n".data(using: .utf8)!).end()
                try response.send(status: HTTPStatusCode.OK).end()
                let nilString: String? = nil
                response.send(nilString)
                response.send("string")
                response.send(json: json)
                response.send(json: ["some": "json"])
                response.send(json: ["some", 10, "json"])
                try response.send(jsonp: json, callbackParameter: "cb").end()

                let data = try TestResponse.encoder.encode(json)
                response.send(data: data)

                try response.send(fileName: "./Tests/KituraTests/TestStaticFileServer/index.html")
                try response.send(download: "./Tests/KituraTests/TestStaticFileServer/index.html")
            } catch {}
            next()
        }

        router.get("/code_unknown_to_ok") { _, response, _ in
            XCTAssert(response.statusCode == .unknown)

            response.send("Hello world")

            XCTAssert(response.statusCode == .OK)
        }

        router.get("/code_notFound_no_change") { _, response, _ in
            response.status(.notFound)

            XCTAssert(response.statusCode == .notFound)

            response.send("Hello world")

            XCTAssert(response.statusCode == .notFound)
        }

        
        router.get("user_info", handler: {
            _, response, next in
            // Store something in userInfo
            response.userInfo["greeting"] = "hello"
            next()
        }, {
            _, response, next in
            // Read the value that should be stored in userInfo
            guard let greeting = response.userInfo["greeting"] as? String else {
                return XCTFail()
            }
            response.send("\(greeting) world")
            next()
        })
        
        router.error { _, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            do {
                let errorDescription: String
                if let error = response.error {
                    errorDescription = "\(error)"
                } else {
                    errorDescription = ""
                }
                try response.send("Caught the error: \(errorDescription)").end()
            } catch {}
            next()
        }

        router.error([ { request, response, next in
            // Dummy error handler
            next()
        }])

        router.error(DummyErrorMiddleware())

        router.error([DummyErrorMiddleware()])

        return router
    }

    class DummyErrorMiddleware: RouterMiddleware {
        func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
            next()
        }
    }
}
