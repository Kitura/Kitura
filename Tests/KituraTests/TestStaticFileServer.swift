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

class TestStaticFileServer : XCTestCase {

    static var allTests : [(String, (TestStaticFileServer) -> () throws -> Void)] {
        return [
            ("testFileServer", testFileServer),
        ]
    }
    
    override func setUp() {
        doSetUp()
    }

    override func tearDown() {
        doTearDown()
    }

    let router = TestStaticFileServer.setupRouter()

    func testFileServer() {
    	performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path:"/qwer", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                }
                catch{
                    XCTFail("No response body")
                }
                
                XCTAssertEqual(response!.headers["x-custom-header"]!.first!, "Kitura")
                XCTAssertNotNil(response!.headers["Last-Modified"])
                XCTAssertNotNil(response!.headers["Etag"])
                XCTAssertEqual(response!.headers["Cache-Control"]!.first!, "max-age=2")
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path:"/qwer/index.html", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path:"/qwer/index", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                do {
                    let body = try response!.readString()
                    XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                }
                catch{
                    XCTFail("No response body")
                }
                expectation.fulfill()
            })
            }, { expectation in
                self.performRequest("get", path:"/zxcv/index.html", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                    do {
                        let body = try response!.readString()
                        XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                    }
                    catch{
                        XCTFail("No response body")
                    }
                    XCTAssertNil(response!.headers["x-custom-header"])
                    XCTAssertNil(response!.headers["Last-Modified"])
                    XCTAssertNil(response!.headers["Etag"])
                    XCTAssertEqual(response!.headers["Cache-Control"]!.first!, "max-age=0")
                    expectation.fulfill()
                })
            }, { expectation in
                self.performRequest("get", path:"/zxcv", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response!.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(response!.statusCode)")
                    expectation.fulfill()
                })
            }, { expectation in
                self.performRequest("get", path:"/zxcv/index", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response!.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(response!.statusCode)")
                    expectation.fulfill()
                })
            }, { expectation in
                self.performRequest("get", path:"/asdf", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response!.statusCode, HTTPStatusCode.notFound, "HTTP Status code was \(response!.statusCode)")
                    expectation.fulfill()
                })
            }, { expectation in
                self.performRequest("get", path:"/asdf/", callback: {response in
                    XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                    XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
                    do {
                        let body = try response!.readString()
                        XCTAssertEqual(body!,"<!DOCTYPE html><html><body><b>Index</b></body></html>\n")
                    }
                    catch{
                        XCTFail("No response body")
                    }
                    XCTAssertNil(response!.headers["x-custom-header"])
                    XCTAssertNotNil(response!.headers["Last-Modified"])
                    XCTAssertNotNil(response!.headers["Etag"])
                    XCTAssertEqual(response!.headers["Cache-Control"]!.first!, "max-age=0")
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
        router.all("/asdf", middleware: StaticFileServer(path: "./Tests/KituraTests/TestStaticFileServer/", options:options))
        
        return router
    }
    
    class HeaderSetter : ResponseHeadersSetter {
        func setCustomResponseHeaders(response: RouterResponse, filePath: String, fileAttributes: [FileAttributeKey : Any]) {
            response.headers["x-custom-header"] = "Kitura"
        }
    }
}
