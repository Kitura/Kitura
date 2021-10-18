/**
 * Copyright IBM Corporation 2016,2017
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

final class TestStaticFileServer: KituraTest, KituraTestSuite {

    static var allTests: [(String, (TestStaticFileServer) -> () throws -> Void)] {
        return [
            ("testFileServer", testFileServer),
            ("testGetWithWhiteSpaces", testGetWithWhiteSpaces),
            ("testGetWithSpecialCharacters", testGetWithSpecialCharacters),
            ("testGetWithSpecialCharactersEncoded", testGetWithSpecialCharactersEncoded),
            ("testWelcomePageCanBeDisabled", testWelcomePageCanBeDisabled),
            ("testGetKituraResource", testGetKituraResource),
            ("testGetDefaultResponse", testGetDefaultResponse),
            ("testGetMissingKituraResource", testGetMissingKituraResource),
            ("testGetTraversedFileKituraResource", testGetTraversedFileKituraResource),
            ("testGetTraversedFile", testGetTraversedFile),
            ("testAbsolutePathFunction", testAbsolutePathFunction),
            ("testAbsoluteRootPath", testAbsoluteRootPath),
            ("testSubRouterStaticFileServer", testSubRouterStaticFileServer),
            ("testSubRouterSubFolderStaticFileServer", testSubRouterSubFolderStaticFileServer),
            ("testSubRouterStaticFileServerRedirect", testSubRouterStaticFileServerRedirect),
            ("testSubRouterSubFolderStaticFileServerRedirect", testSubRouterSubFolderStaticFileServerRedirect),
            ("testParameterizedSubRouterSubFolderStaticFileServer", testParameterizedSubRouterSubFolderStaticFileServer),
            ("testParameterizedSubRouterSubFolderStaticFileServerRedirect", testParameterizedSubRouterSubFolderStaticFileServerRedirect),
            ("testRangeRequests", testRangeRequests),
            ("testRangeRequestsWithLargeLastBytePos", testRangeRequestsWithLargeLastBytePos),
            ("testRangeRequestIsIgnoredOnOptionOff", testRangeRequestIsIgnoredOnOptionOff),
            ("testRangeRequestIsIgnoredOnNonGetMethod", testRangeRequestIsIgnoredOnNonGetMethod),
            ("testDataIsNotCorrupted", testDataIsNotCorrupted),
            ("testRangeRequestsWithMultipleRanges", testRangeRequestsWithMultipleRanges),
            ("testRangeRequestWithNotSatisfiableRange", testRangeRequestWithNotSatisfiableRange),
            ("testRangeRequestWithSintacticallyInvalidRange", testRangeRequestWithSintacticallyInvalidRange),
            ("testRangeRequestWithIfRangeHeaderWithETag", testRangeRequestWithIfRangeHeaderWithETag),
            ("testRangeRequestWithIfRangeHeaderWithOldETag", testRangeRequestWithIfRangeHeaderWithOldETag),
            ("testRangeRequestWithIfRangeHeaderAsLastModified", testRangeRequestWithIfRangeHeaderAsLastModified),
            ("testRangeRequestWithIfRangeHeaderAsOldLastModified", testRangeRequestWithIfRangeHeaderAsOldLastModified),
            ("testStaticFileServerRedirectPreservingQueryParams", testStaticFileServerRedirectPreservingQueryParams),
            ("testFallbackToDefaultIndex", testFallbackToDefaultIndex),
            ("testFallbackToDefaultIndexFailsIfOptionNotSet", testFallbackToDefaultIndexFailsIfOptionNotSet),
            ("testFallbackToDefaultIndexWithSubrouter", testFallbackToDefaultIndexWithSubrouter),
        ]
    }

    let router = TestStaticFileServer.setupRouter()
    let routerWithoutWelcome = TestStaticFileServer.setupRouter(enableWelcomePage: false)

    func testFileServer() {
        performServerTest(router, asyncTasks: { asyncTaskCompletion in
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
                asyncTaskCompletion()
            })
        }, { asyncTaskCompletion in
            self.performRequest("get", path:"/qwer/index.html", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                } catch {
                    XCTFail("No response body")
                }
                asyncTaskCompletion()
            })
        }, { asyncTaskCompletion in
            self.performRequest("get", path:"/qwer/index", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                } catch {
                    XCTFail("No response body")
                }
                asyncTaskCompletion()
            })
            }, { asyncTaskCompletion in
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
                    asyncTaskCompletion()
                })
            }, { asyncTaskCompletion in
                self.performRequest("get", path:"/zxcv", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(String(describing: response?.statusCode))")
                    asyncTaskCompletion()
                })
            }, { asyncTaskCompletion in
                self.performRequest("get", path:"/zxcv/index", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(String(describing: response?.statusCode))")
                    asyncTaskCompletion()
                })
            }, { asyncTaskCompletion in
                self.performRequest("get", path:"/asdf", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(String(describing: response?.statusCode))")
                    asyncTaskCompletion()
                })
            }, { asyncTaskCompletion in
                self.performRequest("put", path:"/asdf", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(String(describing:response?.statusCode))")
                    asyncTaskCompletion()
                })
            }, { asyncTaskCompletion in
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
                    asyncTaskCompletion()
                })
        })
    }

    static func servingPathPrefix() -> String {
        // this file is at
        // <original repository directory>/Tests/KituraTests/TestStaticFileServer.swift
        // the original repository directory is 3 path components up
        let currentFilePath = #file

        let pathComponents = currentFilePath.split(separator: "/").map(String.init)

        // We need to check whether we have an edited Kitura package, this will be seen from a path containing Packages and Kitura at the relevant indexes
        let expectedKituraIndex = pathComponents.count - 4
        let expectedPackagesIndex = pathComponents.count - 5
        if pathComponents[expectedKituraIndex] == "Kitura"
            && pathComponents[expectedPackagesIndex] == "Packages" {
            return "./Packages/Kitura/"
        } else {
            return "./"
        }
    }

    static func setupRouter(enableWelcomePage: Bool = true) -> Router {
        let router = Router(enableWelcomePage: enableWelcomePage)

        if !enableWelcomePage {
            // Testing the default welcome page can be disabled does not require a `StaticFileServer` to be configured.
            return router
        }

        // The route below ensures that the static file server does not prevent all routes being walked
        router.all("/", middleware: StaticFileServer())

        var cacheOptions = StaticFileServer.CacheOptions(maxAgeCacheControlHeader: 2)
        var options = StaticFileServer.Options(possibleExtensions: ["exe", "html"], cacheOptions: cacheOptions)
        router.all("/qwer", middleware: StaticFileServer(path: servingPathPrefix() + "Tests/KituraTests/TestStaticFileServer/", options:options, customResponseHeadersSetter: HeaderSetter()))

        cacheOptions = StaticFileServer.CacheOptions(addLastModifiedHeader: false, generateETag: false)
        options = StaticFileServer.Options(serveIndexForDirectory: false, cacheOptions: cacheOptions)
        router.all("/zxcv", middleware: StaticFileServer(path: servingPathPrefix() + "Tests/KituraTests/TestStaticFileServer/", options:options))

        options = StaticFileServer.Options(redirect: false)
        let directoryURL = URL(fileURLWithPath: #file + "/../TestStaticFileServer").standardizedFileURL
        router.all("/asdf", middleware: StaticFileServer(path: directoryURL.path, options:options))

        options = StaticFileServer.Options(possibleExtensions: ["exe", "html"], cacheOptions: cacheOptions, acceptRanges: false)
        router.all("/tyui", middleware: StaticFileServer(path: servingPathPrefix() + "Tests/KituraTests/TestStaticFileServer/", options:options, customResponseHeadersSetter: HeaderSetter()))
        
        options = StaticFileServer.Options(serveIndexForDirectory: true, redirect: true, cacheOptions: cacheOptions)
        router.route("/ghjk").all(middleware: StaticFileServer(path: servingPathPrefix() + "Tests/KituraTests/TestStaticFileServer/", options: options))
        
        options = StaticFileServer.Options(serveIndexForDirectory: true, redirect: true, cacheOptions: cacheOptions)
        router.route("/opnm/:parameter").all(middleware: StaticFileServer(path: servingPathPrefix() + "Tests/KituraTests/TestStaticFileServer/subfolder", options: options))

        options = StaticFileServer.Options(serveIndexForDirectory: true, redirect: true)
        router.route("/queryparams").all(middleware: StaticFileServer(path: servingPathPrefix() + "Tests/KituraTests/TestStaticFileServer/", options: options))

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
                                    bodyChecker: BodyChecker? = nil,
                                    withRouter: Router? = nil) {
        performServerTest(withRouter ?? router) { asyncTaskCompletion in
            self.performRequest("get", path: path, callback: { response in
                defer { asyncTaskCompletion() }

                guard let response = response else {
                    XCTFail("ClientRequest response object was nil")
                    return
                }
                XCTAssertEqual(response.statusCode, expectedStatusCode,
                               "No success status code returned")

                if let body = (try? response.readString()).flatMap({ $0 }) {
                    if let expectedResponseText = expectedResponseText {
                        XCTAssertEqual(body, expectedResponseText, "mismatch in body")
                    }
                    bodyChecker?(body)
                } else {
                    XCTFail("No response body")
                }
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

    func testWelcomePageCanBeDisabled() {
        runGetResponseTest(path: "/", expectedStatusCode: HTTPStatusCode.notFound, withRouter: routerWithoutWelcome)
    }

    func testGetKituraResource() {
        runGetResponseTest(path: "/@@Kitura-router@@/")
    }

    func testGetDefaultResponse() {
        runGetResponseTest(path: "/")
    }

    func testGetMissingKituraResource() {
        runGetResponseTest(path: "/@@Kitura-router@@/missing.file", expectedStatusCode: HTTPStatusCode.notFound)
    }

    func testGetTraversedFileKituraResource() {
        runGetResponseTest(path: "/@@Kitura-router@@/../../../Tests/KituraTests/TestStaticFileServer.swift", expectedStatusCode: HTTPStatusCode.notFound)
    }

    func testGetTraversedFile() {
        runGetResponseTest(path: "../Tests/KituraTests/TestStaticFileServer.swift", expectedStatusCode: HTTPStatusCode.notFound)
    }

    func testAbsolutePathFunction() {
        XCTAssertEqual(StaticFileServer.ResourcePathHandler.getAbsolutePath(for: "/"), "/", "Absolute path did not resolve to system root")
    }

    func testAbsoluteRootPath() {
        XCTAssertEqual(StaticFileServer(path: "/").absoluteRootPath, "/", "Absolute root path did not resolve to system root")
    }

    let indexHtmlContents = "<!DOCTYPE html><html><body><b>Index</b></body></html>" // contents of index.html
    let subfolderIndexHtmlContents = "<!DOCTYPE html><html><body><b>Sub Folder Index</b></body></html>" // contents of subfolder/index.html
    let indexHtmlCount = 54 // index.html file data length

    func testSubRouterStaticFileServer() {
        runGetResponseTest(path: "/ghjk/", expectedResponseText: indexHtmlContents + "\n")
    }
    
    func testSubRouterSubFolderStaticFileServer() {
        runGetResponseTest(path: "/ghjk/subfolder/", expectedResponseText: subfolderIndexHtmlContents + "\n")
    }
    
    func testSubRouterStaticFileServerRedirect() {
        runGetResponseTest(path: "/ghjk", expectedResponseText: indexHtmlContents + "\n")
    }
    
    func testSubRouterSubFolderStaticFileServerRedirect() {
        runGetResponseTest(path: "/ghjk/subfolder", expectedResponseText: subfolderIndexHtmlContents + "\n")
    }
    
    func testParameterizedSubRouterSubFolderStaticFileServer() {
        runGetResponseTest(path: "/opnm/xxxx/", expectedResponseText: subfolderIndexHtmlContents + "\n")
    }
    
    func testParameterizedSubRouterSubFolderStaticFileServerRedirect() {
        runGetResponseTest(path: "/opnm/xxxx", expectedResponseText: subfolderIndexHtmlContents + "\n")
    }
    
    func testRangeRequests() {
        let requestingBytes = 10
        performServerTest(router) { asyncTaskCompletion in
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.partialContent)
                XCTAssertEqual(response?.headers["Content-Range"]?.first, "bytes 0-\(requestingBytes)/\(self.indexHtmlCount)")
                XCTAssertEqual(response?.headers["Accept-Ranges"]?.first, "bytes")
                XCTAssertEqual(response?.headers["Content-Length"]?.first, "11")
                var bodyData = Data()
                _ = try? response?.readAllData(into: &bodyData)
                XCTAssertEqual(bodyData.count, requestingBytes + 1)
                asyncTaskCompletion()
            }, headers: ["Range": "bytes=0-\(requestingBytes)"])
        }
    }

    func testRangeRequestsWithLargeLastBytePos() {
        performServerTest(router) { asyncTaskCompletion in
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.partialContent)
                XCTAssertEqual(response?.headers["Content-Range"]?.first, "bytes 2-53/54")
                XCTAssertEqual(response?.headers["Accept-Ranges"]?.first, "bytes")
                XCTAssertEqual(response?.headers["Content-Length"]?.first, "52")
                var bodyData = Data()
                _ = try? response?.readAllData(into: &bodyData)
                XCTAssertEqual(bodyData.count, 52)
                asyncTaskCompletion()
            }, headers: ["Range": "bytes=2-100"])
        }
    }

    func testRangeRequestIsIgnoredOnOptionOff() {
        performServerTest(router) { asyncTaskCompletion in
            // static server for "/tyui" has the range option off
            self.performRequest("get", path: "/tyui/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK)
                var bodyData = Data()
                _ = try? response?.readAllData(into: &bodyData)
                XCTAssertEqual(bodyData.count, self.indexHtmlCount)
                XCTAssertEqual(response?.headers["Accept-Ranges"]?.first, "none")
                asyncTaskCompletion()
            }, headers: ["Range": "bytes=0-10"])
        }
    }

    func testRangeRequestIsIgnoredOnNonGetMethod() {
        performServerTest(router) { asyncTaskCompletion in
            self.performRequest("head", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.headers["Accept-Ranges"]?.first, "bytes")
                // Range requests should be ignored on non GET method
                // In this case we expect status code 200, no Content-Range and no body since it is a HEAD request
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK)
                XCTAssertNil(response?.headers["Content-Range"])
                let bodyString = (try? response?.readString()).flatMap({ $0 })
                XCTAssertNil(bodyString)
                asyncTaskCompletion()
            }, headers: ["Range": "bytes=0-10"])
        }
    }

    func testDataIsNotCorrupted() {
        // Corrupted files will have more bytes or less bytes than required
        // So we check the file is intact after reconstructing it (after various range requests)
        performServerTest(router) { asyncTaskCompletion in
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK)
                XCTAssertNil(response?.headers["Content-Range"]?.first)
                // Original file:
                var original = Data()
                _ = try? response?.readAllData(into: &original)

                self.performRequest("get", path: "/qwer/index.html", callback: { response in
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.partialContent)
                    XCTAssertEqual(response?.headers["Content-Range"]?.first, "bytes 0-10/\(self.indexHtmlCount)")
                    // First 11 bytes
                    var reconstructed = Data()
                    _ = try? response?.readAllData(into: &reconstructed)

                    self.performRequest("get", path: "/qwer/index.html", callback: { response in
                        XCTAssertNotNil(response)
                        XCTAssertEqual(response?.statusCode, HTTPStatusCode.partialContent)
                        XCTAssertEqual(response?.headers["Content-Range"]?.first, "bytes 11-\(self.indexHtmlCount-1)/\(self.indexHtmlCount)")
                        // 12th bytes and later
                        var part2 = Data()
                        _ = try? response?.readAllData(into: &part2)

                        // Reconstruct data
                        reconstructed.append(part2)

                        // Check both datas are the same
                        XCTAssertEqual(reconstructed.count, original.count)
                        if reconstructed.count == original.count {
                            for i in 0..<original.count {
                                XCTAssertEqual(reconstructed[i], original[i])
                            }
                        }
                    }, headers: ["Range": "bytes=11-"])
                }, headers: ["Range": "bytes=0-10"])
                asyncTaskCompletion()
            })
        }
    }

    #if os(Linux) && !swift(>=3.2)
    typealias NSTextCheckingResult = TextCheckingResult
    #endif

    /// Helper function to assert a regex pattern and returns matched groups
    func assertMatch(_ target: String?, _ pattern: String, matchedGroups: inout [String], file: StaticString = #file, line: UInt = #line) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [])else {
            return XCTFail("invalid pattern: \(pattern)", file: file, line: line)
        }
        guard let target = target else {
            return XCTFail("target string is nil")
        }
        let matches = regex.matches(in: target, options: [], range: NSRange(location: 0, length: target.count))
        if matches.isEmpty {
            XCTFail("target string didn't match", file: file, line: line)
        } else {
            let match = matches.first!
            let nsstring = NSString(string: target)
            for index in 0..<match.numberOfRanges {
                #if !os(Linux) && !swift(>=3.2)
                    let range = match.rangeAt(index)
                #else
                    let range = match.range(at: index)
                #endif
                if  range.location != NSNotFound  &&  range.location != -1 {
                    matchedGroups.append(nsstring.substring(with: range))
                }
            }
        }
    }

    func testRangeRequestsWithMultipleRanges() {
        performServerTest(router) { asyncTaskCompletion in
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                defer {
                    asyncTaskCompletion()
                }
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.partialContent)

                // Assert required headers in multipart/bytesranges
                var capturedGroups: [String] = []
                XCTAssertEqual(response?.headers["Accept-Ranges"]?.first, "bytes")
                self.assertMatch(response?.headers["Content-Type"]?.first, "multipart\\/byteranges; boundary=(.+)", matchedGroups: &capturedGroups)
                XCTAssertFalse(capturedGroups.isEmpty, "No captured groups, body and boundary tests will fail")
                guard capturedGroups.count > 1 else {
                    XCTFail("No boundary found in Content-Type header")
                    return
                }

                // Assert Content-Range is not present
                XCTAssertNil(response?.headers["Content-Range"]?.first)

                // Assert body
                var bodyData = Data()
                _ = try? response?.readAllData(into: &bodyData)
                XCTAssertTrue(bodyData.count > 0)

                // Assert body structure (Should be same as a regular multipart body)
                let bodyParser = MultiPartBodyParser(boundary: capturedGroups[1])
                guard let parsedBody = bodyParser.parse(bodyData) else {
                    XCTFail("parsedBody must not be nil")
                    return
                }
                switch parsedBody {
                case .multipart(let parts):
                    // Assert each part has the required headers and its data is of the desired length
                    XCTAssertEqual(parts.count, 2)
                    XCTAssertEqual(parts[0].headers[.contentRange], "Content-Range: bytes 0-10/\(self.indexHtmlCount)")
                    XCTAssertEqual(parts[0].headers[.type], "Content-Type: text/html")
                    let data0 = parts[0].body.asText?.data(using: .utf8)
                    XCTAssertEqual(data0?.count, 11)
                    XCTAssertEqual(parts[1].headers[.contentRange], "Content-Range: bytes 20-33/\(self.indexHtmlCount)")
                    XCTAssertEqual(parts[1].headers[.type], "Content-Type: text/html")
                    let data1 = parts[1].body.asText?.data(using: .utf8)
                    XCTAssertEqual(data1?.count, 14)
                default:
                    XCTFail("Multipart body was expected \(parsedBody)")
                }
            }, headers: ["Range": "bytes=0-10,20-33"])
        }
    }

    func testRangeRequestWithNotSatisfiableRange() {
        /// when the first- byte-pos of the range is greater than the current length
        performServerTest(router) { asyncTaskCompletion in
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.headers["Accept-Ranges"]?.first, "bytes")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.requestedRangeNotSatisfiable)
                XCTAssertEqual(response?.headers["Content-Range"]?.first, "bytes */54")
                asyncTaskCompletion()
            }, headers: ["Range": "bytes=54-55"])
        }
    }

    func testRangeRequestWithSintacticallyInvalidRange() {
        performServerTest(router) { asyncTaskCompletion in
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.headers["Accept-Ranges"]?.first, "bytes")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK)
                XCTAssertNil(response?.headers["Content-Range"]?.first)
                asyncTaskCompletion()
            }, headers: ["Range": "asdf"])
        }
    }

    func testRangeRequestWithIfRangeHeaderWithETag() {
        performServerTest(router) { asyncTaskCompletion in
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK)
                XCTAssertNotNil(response?.headers["Last-Modified"]?.first)
                guard let eTag = response?.headers["eTag"]?.first else {
                    XCTFail("eTag header was missing")
                    return asyncTaskCompletion()
                }

                // if ETag is the same then partial content (206) should be served
                self.performRequest("get", path: "/qwer/index.html", callback: { response in
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.partialContent)
                    XCTAssertEqual(response?.headers["Content-Range"]?.first, "bytes 0-10/\(self.indexHtmlCount)")
                    var data = Data()
                    _ = try? response?.readAllData(into: &data)
                    XCTAssertEqual(data.count, 11)
                }, headers: ["Range": "bytes=0-10", "If-Range": "\(eTag)"])
                asyncTaskCompletion()
            })
        }
    }

    func testRangeRequestWithIfRangeHeaderWithOldETag() {
        performServerTest(router) { asyncTaskCompletion in
            // if ETag is NOT the same then the entire file (200) should be served
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK)
                XCTAssertNil(response?.headers["Content-Range"]?.first
                )
            }, headers: ["Range": "bytes=0-10", "If-Range": "\"old-etag\""])
            asyncTaskCompletion()
        }
    }

    func testRangeRequestWithIfRangeHeaderAsLastModified() {
        performServerTest(router) { asyncTaskCompletion in
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK)
                guard let lastModified = response?.headers["Last-Modified"]?.first else {
                    XCTFail("Last-Modified header was missing")
                    return asyncTaskCompletion()
                }
                XCTAssertNotNil(response?.headers["eTag"]?.first)

                // if Last-Modified is the same then partial content (206) should be served
                self.performRequest("get", path: "/qwer/index.html", callback: { response in
                    XCTAssertNotNil(response)
                    XCTAssertEqual(response?.statusCode, HTTPStatusCode.partialContent)
                    XCTAssertEqual(response?.headers["Content-Range"]?.first, "bytes 0-10/\(self.indexHtmlCount)")
                    var data = Data()
                    _ = try? response?.readAllData(into: &data)
                    XCTAssertEqual(data.count, 11)
                }, headers: ["Range": "bytes=0-10", "If-Range": "\(lastModified)"])
                asyncTaskCompletion()
            })
        }
    }

    func testRangeRequestWithIfRangeHeaderAsOldLastModified() {
        // Range request with If-Range with etag
        performServerTest(router) { asyncTaskCompletion in
            // if Last-Modified is NOT the same then the entire file (200) should be served
            self.performRequest("get", path: "/qwer/index.html", callback: { response in
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK)
                XCTAssertNil(response?.headers["Content-Range"]?.first)
            }, headers: ["Range": "bytes=0-10", "If-Range": "Wed, 01 Jan 2000 00:00:00 GMT"])
            asyncTaskCompletion()
        }
    }

    func testStaticFileServerRedirectPreservingQueryParams() {
        performServerTest(router) { asyncTaskCompletion in
            self.performRequest("get", path: "/queryparams?a=b&c=d", followRedirects: false, callback: { response in
                defer {
                    asyncTaskCompletion()
                }
                guard let response = response else {
                    return XCTFail()
                }
                // We expect StaticFileServer to redirect us. In order to see what location header
                // has been sent, we have disabled following of redirects, so expect a 3xx response:
                XCTAssertEqual(response.statusCode.class, HTTPStatusCode.Class.redirection)
                guard let location = response.headers["Location"] else {
                    return XCTFail("Location header was missing")
                }
                XCTAssertEqual(location, ["/queryparams/?a=b&c=d"])

            })
        }
    }

    func testFallbackToDefaultIndex() {
        // This test verifies the fallback to the default index.html if the requested path
        // is not found. This feature is expected to be used by single file applications.
        let router = TestStaticFileServer.setupRouter(defaultIndex: "/index.html")
        performServerTest(router, asyncTasks: { asyncTaskCompletion in
            self.performRequest("get", path:"/help/contact", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                } catch {
                    XCTFail("No response body")
                }
                asyncTaskCompletion()
            })
        })
    }

    func testFallbackToDefaultIndexFailsIfOptionNotSet() {
        let router = TestStaticFileServer.setupRouter(defaultIndex: nil)
        performServerTest(router, asyncTasks: { asyncTaskCompletion in
            self.performRequest("get", path:"/help/contact", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(String(describing: response?.statusCode))")
                asyncTaskCompletion()
            })
        })
    }

    func testFallbackToDefaultIndexWithSubrouter() {
        let router = Router(enableWelcomePage: true)
        let parent = router.route("/help")
        parent.all("/contact", middleware: StaticFileServer(
            path: TestStaticFileServer.servingPathPrefix() + "Tests/KituraTests/TestStaticFileServer/",
            options: StaticFileServer.Options(defaultIndex: "/index.html")))

        performServerTest(router, asyncTasks: { asyncTaskCompletion in
            self.performRequest("get", path:"/help/contact/details", callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response?.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response?.statusCode))")
                do {
                    let body = try response?.readString()
                    XCTAssertEqual(body, "<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                } catch {
                    XCTFail("No response body")
                }
                asyncTaskCompletion()
            })
        })
    }

    static func setupRouter(defaultIndex: String?) -> Router {
        let router = Router(enableWelcomePage: true)
        router.all("/help", middleware: StaticFileServer(
            path: servingPathPrefix() + "Tests/KituraTests/TestStaticFileServer/",
            options: StaticFileServer.Options(defaultIndex: defaultIndex))
        )
        return router
    }
}
