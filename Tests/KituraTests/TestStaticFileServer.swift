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

class TestStaticFileServer: KituraTest {

    static var allTests: [(String, (TestStaticFileServer) -> () throws -> Void)] {
        return [
            ("testFileServer", testFileServer),
            ("testGetWithWhiteSpaces", testGetWithWhiteSpaces),
            ("testGetWithSpecialCharacters", testGetWithSpecialCharacters),
            ("testGetWithSpecialCharactersEncoded", testGetWithSpecialCharactersEncoded),
            ("testGetKituraResource", testGetKituraResource),
            ("testGetMissingKituraResource", testGetMissingKituraResource),
            ("testAbsolutePathFunction", testAbsolutePathFunction),
            ("testRangeRequests", testRangeRequests)
        ]
    }

    let router = TestStaticFileServer.setupRouter()

    func testFileServer() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path:"/qwer", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                } catch {
                    XCTFail("No response body")
                }

                XCTAssertEqual(response?.headers["x-custom-header"]?.first, "Kitura")
                XCTAssertNotNil(response?.headers["Last-Modified"])
                XCTAssertNotNil(response?.headers["Etag"])
                XCTAssertEqual(response?.headers["Cache-Control"]?.first, "max-age=2")
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path:"/qwer/index.html", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                } catch {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path:"/qwer/index", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                } catch {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
            }, { expectation in
                self.performRequest("get", path:"/zxcv/index.html", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                    do {
                        let body = try response?.readString()
                        XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                    } catch {
                        XCTFail("No response body")
                    }
                    XCTAssertNil(response?.headers["x-custom-header"])
                    XCTAssertNil(response?.headers["Last-Modified"])
                    XCTAssertNil(response?.headers["Etag"])
                    XCTAssertEqual(response?.headers["Cache-Control"]?.first, "max-age=0")
                    expectation.fulfill()
                })
            }, { expectation in
                self.performRequest("get", path:"/zxcv", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(String(describing: response?.statusCode))")
                    expectation.fulfill()
                })
            }, { expectation in
                self.performRequest("get", path:"/zxcv/index", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(String(describing: response?.statusCode))")
                    expectation.fulfill()
                })
            }, { expectation in
                self.performRequest("get", path:"/asdf", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(String(describing: response?.statusCode))")
                    expectation.fulfill()
                })
            }, { expectation in
                self.performRequest("put", path:"/asdf", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(String(describing:response?.statusCode))")
                    expectation.fulfill()
                })
            }, { expectation in
                self.performRequest("get", path:"/asdf/", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                    do {
                        let body = try response?.readString()
                        XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                    } catch {
                        XCTFail("No response body")
                    }
                    XCTAssertNil(response?.headers["x-custom-header"])
                    XCTAssertNotNil(response?.headers["Last-Modified"])
                    XCTAssertNotNil(response?.headers["Etag"])
                    XCTAssertEqual(response?.headers["Cache-Control"]?.first, "max-age=0")
                    expectation.fulfill()
                })
        })
    }

    static func setupRouter() -> Router {
        let router = Router()

        var cacheOptions = StaticFileServer.CacheOptions(maxAgeCacheControlHeader: 2)
        var options = StaticFileServer.Options(possibleExtensions: ["exe", "html"], cacheOptions: cacheOptions)
        router.all("/qwer", middleware: StaticFileServer(path: "./Tests/KituraTests/TestStaticFileServer/", options:options, customResponseHeadersSetter: HeaderSetter()))

        cacheOptions = StaticFileServer.CacheOptions(addLastModifiedHeader: false, generateETag: false)
        options = StaticFileServer.Options(serveIndexForDirectory: false, cacheOptions: cacheOptions)
        router.all("/zxcv", middleware: StaticFileServer(path: "./Tests/KituraTests/TestStaticFileServer/", options:options))

        options = StaticFileServer.Options(redirect: false)
        let directoryURL = URL(fileURLWithPath: #file + "/../TestStaticFileServer").standardizedFileURL
        router.all("/asdf", middleware: StaticFileServer(path: directoryURL.path, options:options))

        options = StaticFileServer.Options(possibleExtensions: ["exe", "html"], cacheOptions: cacheOptions, acceptRanges: false)
        router.all("/tyui", middleware: StaticFileServer(path: "./Tests/KituraTests/TestStaticFileServer/", options:options, customResponseHeadersSetter: HeaderSetter()))

        return router
    }

    class HeaderSetter: ResponseHeadersSetter {
        func setCustomResponseHeaders(response: RouterResponse, filePath: String, fileAttributes: [FileAttributeKey : Any]) {
            response.headers["x-custom-header"] = "Kitura"
        }
    }

    private typealias BodyChecker =  (String) -> Void
    private func runGetResponseTest(path: String, expectedResponseText: String? = nil,
                                    expectedStatusCode: HTTPStatusCode = HTTPStatusCode.OK,
                                    bodyChecker: BodyChecker? = nil) {
        performServerTest(router) { expectation in
            self.performRequest("get", path: path, callback: { response in
                guard let response = response else {
                    XCTFail("ClientRequest response object was nil")
                    expectation.fulfill()
                    return
                }
                XCTAssertEqual(response.statusCode, expectedStatusCode,
                               "No success status code returned")
                if let optionalBody = try? response.readString(), let body = optionalBody {
                    if let expectedResponseText = expectedResponseText {
                        XCTAssertEqual(body, expectedResponseText, "mismatch in body")
                    }
                    bodyChecker?(body)
                } else {
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }
    }

    func testGetWithWhiteSpaces() {
        runGetResponseTest(path: "/qwer/index%20with%20whitespace.html", expectedResponseText: "<!DOCTYPE html><html><body><b>Index with whitespace</b></body></html>\n")
    }

    func testGetWithSpecialCharacters() {
        runGetResponseTest(path: "/qwer/index+@,.html", expectedResponseText: "<!DOCTYPE html><html><body><b>Index with plus at comma</b></body></html>\n")
    }

    func testGetWithSpecialCharactersEncoded() {
        runGetResponseTest(path: "/qwer/index%2B%40%2C.html", expectedResponseText: "<!DOCTYPE html><html><body><b>Index with plus at comma</b></body></html>\n")
    }

    func testGetKituraResource() {
        runGetResponseTest(path: "/@@Kitura-router@@/")
    }

    func testGetMissingKituraResource() {
        runGetResponseTest(path: "/@@Kitura-router@@/missing.file", expectedStatusCode: HTTPStatusCode.notFound)
    }

    func testAbsolutePathFunction() {
        XCTAssertEqual(StaticFileServer.ResourcePathHandler.getAbsolutePath(for: "/"), "/", "Absolute path did not resolve to system root")
    }

    let indexHtmlContents = "<!DOCTYPE html><html><body><b>Index</b></body></html>" // contents of index.html
    let indexHtmlCount = 54 // index.html file data length

    func testRangeRequests() {
        let requestingBytes = 10
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.partialContent)
                XCTAssertEqual(response?.headers["Content-Range"]?.first, "bytes 0-\(requestingBytes)/\(self.indexHtmlCount)")
                XCTAssertEqual(response?.headers["Accept-Ranges"]?.first, "bytes")
                var bodyData = Data()
                _ = try? response?.readAllData(into: &bodyData)
                XCTAssertEqual(bodyData.count, requestingBytes)
                expectation.fulfill()
            }, headers: ["Range": "bytes=0-\(requestingBytes)"])
        }
    }

    func testRangeRequestIsIgnoredOnOptionOff() {
        performServerTest(router) { expectation in
            // static server for "/tyui" has the range option off
            self.performRequest("get", path: "/tyui/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK)
                var bodyData = Data()
                _ = try? response?.readAllData(into: &bodyData)
                XCTAssertEqual(bodyData.count, self.indexHtmlCount)
                XCTAssertEqual(response?.headers["Accept-Ranges"]?.first, "none")
                expectation.fulfill()
            }, headers: ["Range": "bytes=0-10"])
        }
    }

    func disabled_testRangeRequestIsIgnoredOnNonGetMethod() {
        performServerTest(router) { expectation in
            self.performRequest("head", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK)
                XCTAssertEqual(response?.headers["Accept-Ranges"]?.first, "bytes")
                XCTAssertNil(response?.headers["Content-Range"])
                let bodyString = (try? response?.readString()) as? String
                XCTAssertEqual(bodyString, self.indexHtmlContents, "Entire file contents are expected")
                expectation.fulfill()
            }, headers: ["Range": "bytes=0-10"])
        }
    }

    func assertMatch(_ target: String?, _ pattern: String, matchedGroups: inout [String], file: StaticString = #file, line: UInt = #line) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [])else {
            return XCTFail("invalid pattern: \(pattern)", file: file, line: line)
        }
        guard let target = target else {
            return XCTFail("target string is nil")
        }
        let matches = regex.matches(in: target, options: [], range: NSRange(location: 0, length: target.characters.count))
        if matches.isEmpty {
            XCTFail("target string didn't match", file: file, line: line)
        } else {
            let match = matches.first!
            let nsstring = (target as NSString)
            for i in 0..<match.numberOfRanges {
                #if swift(>=4)
                    matchedGroups.append(nsstring.substring(with: match.range(at: i)))
                #else
                    matchedGroups.append(nsstring.substring(with: match.rangeAt(i)))
                #endif
            }
        }
    }

    func testRangeRequestsWithMultipleRanges() {
        performServerTest(router) { expectation in
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.partialContent)
                var capturedGroups: [String] = []
                XCTAssertEqual(response?.headers["Accept-Ranges"]?.first, "bytes")
                self.assertMatch(response?.headers["Content-Type"]?.first, "multipart\\/byteranges; boundary=(.+)", matchedGroups: &capturedGroups)
                var bodyData = Data()
                _ = try? response?.readAllData(into: &bodyData)
                XCTAssertTrue(bodyData.count > 0)
                XCTAssertFalse(capturedGroups.isEmpty, "No captured groups, body and boundary tests will fail")
                if capturedGroups.count > 1 {
                    let bodyParser = MultiPartBodyParser(boundary: capturedGroups[1])
                    let parsedBody = bodyParser.parse(bodyData)
                    XCTAssertNotNil(parsedBody)
                    // Check each part has the right headers and data is of the correct length
                }
                //XCTAssertEqual(bodyData.count, 10)
                expectation.fulfill()
            }, headers: ["Range": "bytes=0-10,20-30"])
        }
    }
}
