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

import SwiftyJSON

class TestQuery: XCTestCase {

    static var allTests: [(String, (TestQuery) -> () throws -> Void)] {
        return [
            ("testQueryValues", testQueryValues),
            ("testQueryParse", testQueryParse),
            ("testParameterValueJSON", testParameterValueJSON),
            ("testQueryInRequest", testQueryInRequest),
            ("testQueriableBody", testQueriableBody),
        ]
    }

    override func setUp() {
        doSetUp()
    }

    override func tearDown() {
        doTearDown()
    }
    
    func testQueryValues() {
        var query = Query(1050)
        
        guard case .int = query.type else {
            XCTFail("query should have int type")
            return
        }
        
        XCTAssertEqual(query.data, "1050".data(using: .utf8))
        XCTAssertEqual(query.object as? Int, 1050)
        XCTAssertEqual(query.int, 1050)
        XCTAssertEqual(query.double, 1050)
        XCTAssertEqual(query.string, "1050")
        XCTAssertNil(query.array)
        XCTAssertNil(query.dictionary)
        XCTAssertEqual(query.bool, true)
        XCTAssertEqual(query.count, 0)
        XCTAssertEqual(query.description, "1050")
        XCTAssertFalse(query.isNull)
        
        query = Query(10.5)
        
        guard case .double = query.type else {
            XCTFail("query should have double type")
            return
        }
        
        XCTAssertEqual(query.data, "10.5".data(using: .utf8))
        XCTAssertEqual(query.object as? Double, 10.5)
        XCTAssertEqual(query.int, 10)
        XCTAssertEqual(query.double, 10.5)
        XCTAssertEqual(query.string, "10.5")
        XCTAssertNil(query.array)
        XCTAssertNil(query.dictionary)
        XCTAssertNil(query.bool)
        XCTAssertEqual(query.count, 0)
        XCTAssertFalse(query.isNull)
        
        query = Query("10501")
        
        guard case .int = query.type else {
            XCTFail("query should have int type")
            return
        }
        
        XCTAssertEqual(query.object as? Int, 10501)
        XCTAssertEqual(query.int, 10501)
        XCTAssertEqual(query.double, 10501)
        XCTAssertEqual(query.string, "10501")
        XCTAssertNil(query.array)
        XCTAssertNil(query.dictionary)
        XCTAssertEqual(query.bool, true)
        XCTAssertEqual(query.count, 0)
        XCTAssertFalse(query.isNull)
        
        query = Query("10.501")
        
        guard case .double = query.type else {
            XCTFail("query should have double type")
            return
        }
        
        XCTAssertEqual(query.object as? Double, 10.501)
        XCTAssertEqual(query.int, 10)
        XCTAssertEqual(query.double, 10.501)
        XCTAssertEqual(query.string, "10.501")
        XCTAssertNil(query.array)
        XCTAssertNil(query.dictionary)
        XCTAssertNil(query.bool)
        XCTAssertEqual(query.count, 0)
        XCTAssertFalse(query.isNull)
        
        query = Query(false)
        
        guard case .bool = query.type else {
            XCTFail("query should have bool type")
            return
        }
        
        XCTAssertEqual(query.data, "false".data(using: .utf8))
        XCTAssertEqual(query.object as? Bool, false)
        XCTAssertEqual(query.int, 0)
        XCTAssertNil(query.double)
        XCTAssertEqual(query.string, "false")
        XCTAssertNil(query.array)
        XCTAssertNil(query.dictionary)
        XCTAssertEqual(query.bool, false)
        XCTAssertEqual(query.count, 0)
        XCTAssertFalse(query.isNull)
        
        query = Query("true")
        
        guard case .bool = query.type else {
            XCTFail("query should have bool type")
            return
        }
        
        XCTAssertEqual(query.object as? Bool, true)
        XCTAssertEqual(query.int, 1)
        XCTAssertNil(query.double)
        XCTAssertEqual(query.string, "true")
        XCTAssertNil(query.array)
        XCTAssertNil(query.dictionary)
        XCTAssertEqual(query.bool, true)
        XCTAssertEqual(query.count, 0)
        XCTAssertFalse(query.isNull)
        
        query = Query("text")
        
        guard case .string = query.type else {
            XCTFail("query should have string type")
            return
        }
        
        XCTAssertEqual(query.data, "text".data(using: .utf8))
        XCTAssertEqual(query.object as? String, "text")
        XCTAssertNil(query.int)
        XCTAssertNil(query.double)
        XCTAssertEqual(query.string, "text")
        XCTAssertNil(query.array)
        XCTAssertNil(query.dictionary)
        XCTAssertNil(query.bool)
        XCTAssertEqual(query.count, 0)
        XCTAssertFalse(query.isNull)
        
        query = Query([1, 2, 3])
        
        guard case .array = query.type else {
            XCTFail("query should have array type")
            return
        }
        
        XCTAssertEqual(query.data, String(describing: [1, 2, 3]).data(using: .utf8))
        XCTAssertEqual((query.object as? [Int])!, [1, 2, 3])
        XCTAssertNil(query.int)
        XCTAssertNil(query.double)
        XCTAssertNil(query.string)
        XCTAssertEqual((query.array as? [Int])!, [1, 2, 3])
        XCTAssertNil(query.dictionary)
        XCTAssertNil(query.bool)
        XCTAssertEqual(query.count, 3)
        XCTAssertFalse(query.isNull)
        
        query = Query(["1" : 1])
        
        guard case .dictionary = query.type else {
            XCTFail("query should have dictionary type")
            return
        }
        
        XCTAssertEqual(query.data, String(describing: ["1" : 1]).data(using: .utf8))
        XCTAssertEqual((query.object as? [String : Int])!, ["1" : 1])
        XCTAssertNil(query.int)
        XCTAssertNil(query.double)
        XCTAssertNil(query.string)
        XCTAssertNil(query.array)
        XCTAssertEqual((query.dictionary as? [String : Int])!, ["1" : 1])
        XCTAssertNil(query.bool)
        XCTAssertEqual(query.count, 1)
        XCTAssertFalse(query.isNull)
        
        struct null: CustomStringConvertible {
            
            var value: Int
            
            var description: String {
                return "\(self.value)"
            }
        }
        
        query = Query(null(value: 10))
        
        guard case .null = query.type else {
            XCTFail("query should have null type")
            return
        }
        
        XCTAssertEqual(query.data, "10".data(using: .utf8))
        XCTAssertEqual((query.object as? null)?.value, 10)
        XCTAssertNil(query.int)
        XCTAssertNil(query.double)
        XCTAssertNil(query.string)
        XCTAssertNil(query.array)
        XCTAssertNil(query.dictionary)
        XCTAssertNil(query.bool)
        XCTAssertEqual(query.count, 0)
        XCTAssertTrue(query.isNull)
        
        
        query = Query("10".data(using: .utf8)!)
        
        guard case .data = query.type else {
            XCTFail("query should have data type")
            return
        }
        
        XCTAssertEqual(query.object as? Data, "10".data(using: .utf8))
        XCTAssertEqual(query.data, "10".data(using: .utf8))
    }
    
    func testQueryParse() {
        var queryString = "q=1"
        
        var query = Query(fromText: queryString)
        XCTAssertEqual(query["q"].string, "1")
        
        queryString = "array=10&array=12"
        query = Query(fromText: queryString)
        XCTAssertEqual(query["array", 0].int, 10)
        XCTAssertEqual(query["array", 1].int, 12)
        
        queryString = "array[]=1&array[]=2"
        query = Query(fromText: queryString)
        XCTAssertEqual(query["array", 0].int, 1)
        XCTAssertEqual(query["array", 1].int, 2)
        
        queryString = "d[a]=1&d[b]=2"
        query = Query(fromText: queryString)
        XCTAssertEqual(query["d", "a"].int, 1)
        XCTAssertEqual(query["d", "b"].int, 2)
        
        queryString = "d=1&d[a]=1&d[b]=2"
        query = Query(fromText: queryString)
        XCTAssertEqual(query["d", 0].int, 1)
        XCTAssertEqual(query["d", 1, "a"].int, 1)
        XCTAssertEqual(query["d", 2, "b"].int, 2)
        
        queryString = "d[a]=1&d[b]=2&d=1"
        query = Query(fromText: queryString)
        XCTAssertEqual(query["d", 0, "a"].int, 1)
        XCTAssertEqual(query["d", 0, "b"].int, 2)
        XCTAssertEqual(query["d", 1].int, 1)
        
        
        queryString = "d[a]1&d[b]=2"
        query = Query(fromText: queryString)
        XCTAssertNil(query["d", "a"].int)
        XCTAssertEqual(query["d", "b"].int, 2)
        
        queryString = "=&a=&d[b]=2"
        query = Query(fromText: queryString)
        XCTAssertNil(query["d", "a"].int)
        XCTAssertEqual(query["d", "b"].int, 2)
        
        query = Query(fromText: nil)
        XCTAssertEqual(query.count, 0)
        XCTAssertNil(query.dictionary)
        XCTAssertTrue(query.isNull)
        guard case .null = query.type else {
            XCTFail("should be null type")
            return
        }
        
    }
    
    func testParameterValueJSON() {
        var json = JSON(["a", "b"]) as ParameterValue
        
        XCTAssertNotNil(json.data)
        XCTAssertEqual(json.array as! [String], ["a", "b"])
        XCTAssertNil(json.dictionary)
        XCTAssertEqual(json[0].string, "a")
        
        json = JSON(["a" : ["b" : 0]]) as ParameterValue
        
        XCTAssertNotNil(json.dictionary)
        XCTAssertNil(json.array)
        XCTAssertEqual(json["a", "b"].int, 0)
    }

    func testQueryInRequest() {
        let router = Router()

        router.get("/strings") { request, response, next in
            defer {
                response.status(.OK)
                next()
            }

            XCTAssertNotNil(request.queryParameters["q"])
            XCTAssertNotNil(request.query["q"].string)
            XCTAssertEqual(request.query["q"].string, request.queryParameters["q"])

            response.send(request.query["q"].string ?? "")
        }

        router.get("/ints") { request, response, next in
            defer {
                response.status(.OK)
                next()
            }

            let param = request.queryParameters["q"]
            XCTAssertNotNil(param)
            XCTAssertNotNil(request.query["q"].string)
            let parameterInt = Int(param!)
            XCTAssertEqual(request.query["q"].int, parameterInt)

            response.send(request.query["q"].string ?? "")
        }

        router.get("/non_int") { request, response, next in
            defer {
                response.status(.OK)
                next()
            }

            let param = request.queryParameters["q"]
            XCTAssertNotNil(param)

            if case .null = request.query["q"].type {
                XCTFail()
            }

            XCTAssertNil(request.query["q"].int)
            XCTAssertNotNil(request.query["q"].string)
            XCTAssertEqual(request.query["q"].string, request.queryParameters["q"])

            response.send(request.query["q"].string ?? "")
        }

        router.get("/array") { request, response, next in
            defer {
                response.status(.OK)
                next()
            }

            XCTAssertNotNil(request.queryParameters["q%5B%5D"])

            if case .null = request.query["q"].type {
                XCTFail()
            }

            XCTAssertNil(request.query["q"].int)
            XCTAssertNil(request.query["q"].string)
            XCTAssertNotNil(request.query["q"].array)

            XCTAssertEqual(request.query["q"][0].int, 1)
            XCTAssertEqual(request.query["q"][1].int, 2)
            XCTAssertEqual(request.query["q"][2].int, 3)

            XCTAssertEqual(request.query["q", 0].int, 1)
            XCTAssertEqual(request.query["q", 1].int, 2)
            XCTAssertEqual(request.query["q", 2].int, 3)

            XCTAssertEqual(request.query["q", 0].int, request.query["q"][0].int)
            XCTAssertEqual(request.query["q", 1].int, request.query["q"][1].int)
            XCTAssertEqual(request.query["q", 2].int, request.query["q"][2].int)

            XCTAssertNil(request.query["q"][3].int)

            response.send(request.query["q", 0].string ?? "")
        }
        
        router.get("/same_property_array") { request, response, next in
            defer {
                response.status(.OK)
                next()
            }
            
            XCTAssertNotNil(request.queryParameters["q"])
            
            if case .null = request.query["q"].type {
                XCTFail()
            }
            
            XCTAssertNil(request.query["q"].int)
            XCTAssertNil(request.query["q"].string)
            XCTAssertNotNil(request.query["q"].array)
            
            XCTAssertEqual(request.query["q"][0].int, 1)
            XCTAssertEqual(request.query["q"][1].int, 2)
            XCTAssertEqual(request.query["q"][2].int, 3)
            
            XCTAssertEqual(request.query["q", 0].int, 1)
            XCTAssertEqual(request.query["q", 1].int, 2)
            XCTAssertEqual(request.query["q", 2].int, 3)
            
            XCTAssertEqual(request.query["q", 0].int, request.query["q"][0].int)
            XCTAssertEqual(request.query["q", 1].int, request.query["q"][1].int)
            XCTAssertEqual(request.query["q", 2].int, request.query["q"][2].int)
            
            XCTAssertNil(request.query["q"][3].int)
            
            response.send(request.query["q", 0].string ?? "")
        }

        router.get("/dictionary") { request, response, next in
            defer {
                response.status(.OK)
                next()
            }

            XCTAssertNotNil(request.queryParameters["q%5Ba%5D"])

            if case .null = request.query["q"].type {
                XCTFail()
            }

            XCTAssertNil(request.query["q"].int)
            XCTAssertNil(request.query["q"].string)
            XCTAssertNil(request.query["q"].array)
            XCTAssertNotNil(request.query["q"].dictionary)

            XCTAssertEqual(request.query["q"]["a"].int, 1)
            XCTAssertEqual(request.query["q"]["str"].string, "done")
            XCTAssertEqual(request.query["q"]["1"].string, "int")

            XCTAssertEqual(request.query["q", "a"].int, 1)
            XCTAssertEqual(request.query["q", "str"].string, "done")
            XCTAssertEqual(request.query["q", "1"].string, "int")

            XCTAssertEqual(request.query["q", "a"].int, request.query["q"]["a"].int)
            XCTAssertEqual(request.query["q", "str"].string, request.query["q"]["str"].string)
            XCTAssertEqual(request.query["q", "1"].string, request.query["q"]["1"].string)

            XCTAssertNil(request.query["q"][1].int)
            XCTAssertNil(request.query["q"]["2"].int)
            XCTAssertNil(request.query["q"]["a3"].int)

            response.send(request.query["q", "str"].string ?? "")
        }
        
        router.get("/array_in_dictionary") { request, response, next in
            defer {
                response.status(.OK)
                next()
            }
            
            XCTAssertNotNil(request.queryParameters["q%5Ba%5D"])
            
            if case .null = request.query["q"].type {
                XCTFail()
            }
            
            XCTAssertNil(request.query["q"].int)
            XCTAssertNil(request.query["q"].string)
            XCTAssertNil(request.query["q"].array)
            XCTAssertNotNil(request.query["q"].dictionary)
            
            XCTAssertNil(request.query["q"]["a"].int)
            XCTAssertNotNil(request.query["q"]["a"].array)
            
            XCTAssertEqual(request.query["q", "a"][0].int, 1)
            XCTAssertEqual(request.query["q", "a"][1].string, "done")
            XCTAssertEqual(request.query["q", "a"][2].string, "int")
            
            XCTAssertEqual(request.query["q", "b"].int, 10)
            
            response.send(request.query["q", "b"].string ?? "")
        }

        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/strings?q=tra-ta-ta".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")

                let string = try! response!.readString()

                XCTAssertNotNil(string)
                XCTAssertEqual(string, "tra-ta-ta")

                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/ints?q=1050".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")

                let string = try! response!.readString()

                XCTAssertNotNil(string)
                XCTAssertEqual(string, "1050")

                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/non_int?q=105ess0".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")

                let string = try! response!.readString()

                XCTAssertNotNil(string)
                XCTAssertEqual(string, "105ess0")

                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/array?q[]=1&q[]=2&q[]=3".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")

                let string = try! response!.readString()

                XCTAssertNotNil(string)
                XCTAssertEqual(string, "1")

                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/same_property_array?q=1&q=2&q=3".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                
                let string = try! response!.readString()
                
                XCTAssertNotNil(string)
                XCTAssertEqual(string, "1")
                
                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/dictionary?q[a]=1&q[str]=done&q[1]=int".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")

                let string = try! response!.readString()

                XCTAssertNotNil(string)
                XCTAssertEqual(string, "done")

                expectation.fulfill()
            })
        }, { expectation in
            self.performRequest("get", path: "/array_in_dictionary?q[a]=1&q[a]=done&q[a]=int&q[b]=10".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, callback: { response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
                
                let string = try! response!.readString()
                
                XCTAssertNotNil(string)
                XCTAssertEqual(string, "10")
                
                expectation.fulfill()
            })
        })
    }

    func testQueriableBody() {
        let router = Router()

        router.post("*", middleware: BodyParser())

        router.post("/text") { request, response, next in
            defer {
                response.status(.OK)
                next()
            }

            guard let body = request.body else {
                XCTFail("body should exist")
                return
            }

            guard case .text(let string) = body else {
                XCTFail("wrong body")
                return
            }

            XCTAssertNotNil(body.string)
            XCTAssertEqual(body.string, "hello")
            XCTAssertEqual(body.string, string)

            response.send(body.string ?? "")
        }

        router.post("/json") { request, response, next in
            defer {
                response.status(.OK)
                next()
            }

            guard let body = request.body else {
                XCTFail("body should exist")
                return
            }

            guard case .json(let json) = body else {
                XCTFail("wrong body")
                return
            }

            XCTAssertNotNil(body["foo"].string)
            XCTAssertEqual(body["foo"].string, "bar")
            XCTAssertEqual(body["foo"].string, json["foo"].stringValue)  // can't use json["foo"].string because of: Ambiguous use of 'subscript'
            XCTAssertEqual(body["foo"].string, (json["foo"] as JSON).string) //workaround for 'json["foo"].string'
            XCTAssertEqual(body["inner", "a"].string, (json["inner", "a"] as JSON).string)

            response.send(body["foo"].string ?? "")
        }

        router.post("/multipart") { request, response, next in
            defer {
                response.status(.OK)
                next()
            }

            guard let body = request.body else {
                XCTFail("body should exist")
                return
            }

            guard case .multipart(let parts) = body else {
                XCTFail("wrong body")
                return
            }

            guard let parsedBody = (body["text"].object as? Part)?.body,
                case .text = parsedBody else {
                    XCTFail("wrong part body")
                    return
            }
            
            XCTAssertNotNil(body["text"].data)
            XCTAssertEqual(body["text"].data, "text default".data(using: .utf8))
            XCTAssertNotNil(body["text"].string)
            XCTAssertEqual(body["text"].string, "text default")
            
            guard let text = parts.first,
                case .text(let string) = text.body else {
                    XCTFail()
                    return
            }

            XCTAssertEqual(body["text"].string, string)
            
            XCTAssertEqual(body["number"].int, 10)
            XCTAssertEqual(body["number"].double, 10.0)
            
            XCTAssertEqual(body["boolean"].bool, true)
            
            XCTAssertNil(body["text"].array)
            XCTAssertNil(body["text"].dictionary)

            response.send(body["text"].string ?? "")
        }


        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("post", path: "/text", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")

                let string = try! response!.readString()

                XCTAssertNotNil(string)
                XCTAssertEqual(string, "hello")

                expectation.fulfill()
            }) { req in
                req.write(from: "hello")
            }
        }, { expectation in
            let jsonToTest = JSON(["foo": "bar", "inner" : ["a" : "b"]])

            self.performRequest("post", path: "/json", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")

                let string = try! response!.readString()

                XCTAssertNotNil(string)
                XCTAssertEqual(string, "bar")

                expectation.fulfill()
            }, headers: ["Content-Type": "application/json"]) { req in
                do {
                    let jsonData = try jsonToTest.rawData()
                    req.write(from: jsonData)
                    req.write(from: "\n")
                } catch {
                    XCTFail("caught error \(error)")
                }
            }
        }, { expectation in

            self.performRequest("post", path: "/multipart", callback: {response in
                XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")

                let string = try! response!.readString()

                XCTAssertNotNil(string)
                XCTAssertEqual(string, "text default")

                expectation.fulfill()
            }) {req in
                req.headers["Content-Type"] = "multipart/form-data; boundary=---------------------------9051914041544843365972754266"
                req.write(from: "-----------------------------9051914041544843365972754266\r\n" +
                    "Content-Disposition: form-data; name=\"text\"\r\n\r\n" +
                    "text default\r\n" +
                    "-----------------------------9051914041544843365972754266\r\n" +
                    "Content-Disposition: form-data; name=\"number\"\r\n\r\n" +
                    "10\r\n" +
                    "-----------------------------9051914041544843365972754266\r\n" +
                    "Content-Disposition: form-data; name=\"boolean\"\r\n\r\n" +
                    "true\r\n" +
                    "-----------------------------9051914041544843365972754266--")
            }
        })

    }
}
