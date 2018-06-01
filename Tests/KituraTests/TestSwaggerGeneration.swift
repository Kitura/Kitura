/**
 * Copyright IBM Corporation 2016, 2017
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
import Dispatch

import KituraNet
import KituraContracts
@testable import Kitura

extension String {
    func contains(find: String) -> Bool {
        return self.range(of: find) != nil
    }
}

class TestSwaggerGeneration: KituraTest {

    static var allTests: [(String, (TestSwaggerGeneration) -> () throws -> Void)] {
        return [
            ("testSwaggerGeneration", testSwaggerGeneration)
        ]
    }

    let httpPort = 8080

    override func setUp() {
        super.setUp()
        stopServer() // stop common server so we can run these tests
    }

    private func setupServerAndExpectations(router: Router, expectStart: Bool, expectStop: Bool, expectFail: Bool, httpPort: Int?=nil) {
        let httpServer = Kitura.addHTTPServer(onPort: httpPort ?? self.httpPort, with: router)

        if expectStart {
            let httpStarted = expectation(description: "HTTPServer started()")

            httpServer.started {
                httpStarted.fulfill()
            }
        } else {
            httpServer.started {
                XCTFail("httpServer.started should not have been called")
            }
        }

        if expectStop {
            let httpStopped = expectation(description: "HTTPServer stopped()")

            httpServer.stopped {
                httpStopped.fulfill()
            }
        }

        if expectFail {
            let httpFailed = expectation(description: "HTTPServer failed()")

            httpServer.failed { error in
                httpFailed.fulfill()
            }
        } else {
            httpServer.failed { error in
                XCTFail("\(error)")
            }
        }
    }

    // handler to use in the tests
    func deleteHandler(completion: (RequestError?) -> Void ) -> Void {
        completion(nil)
    }

    func getPearHandler(completion: (Pear?, RequestError?) -> Void ) -> Void {
        completion(nil, nil)
    }

    func getAppleHandler(completion: (Apple?, RequestError?) -> Void ) -> Void {
        completion(nil, nil)
    }

    func getArrayAppleHandler(completion: ([Apple]?, RequestError?) -> Void ) -> Void {
        completion(nil, nil)
    }

    func getSingleAppleHandler(id: Int, completion: (Apple?, RequestError?) -> Void) -> Void {
        completion(nil, nil)
    }

    func getSingleArrayAppleHandler(completion: ([(Int, Apple)]?, RequestError?) -> Void) -> Void {
        completion(nil, nil)
    }

    func postAppleHandler(posted: Apple, completion: (Apple?, RequestError?) -> Void ) -> Void {
        completion(nil, nil)
    }

    func postSingleAppleHandler(posted: Apple, completion: (Int?, Apple?, RequestError?) -> Void ) -> Void {
        completion(nil, nil, nil)
    }

    func putSingleAppleHandler(id: Int, posted: Apple, completion: (Apple?, RequestError?) -> Void ) -> Void {
        completion(nil, nil)
    }

    func patchSingleAppleHandler(id: Int, posted: Apple, completion: (Apple?, RequestError?) -> Void ) -> Void {
        completion(nil, nil)
    }

    func pearDefinitionsAssertions(json: String?) {
        if let jsonString = json {
            guard let data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let dict = json as? [String: Any] else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }

            // test for definitions section
            if let definitions = dict["definitions"] as? [String: Any] {
                if let model = definitions["Pear"] as? [String: Any] {
                    if let type = model["type"] as? String {
                        XCTAssertTrue(type == "object", "model Pear: type is incorrect")
                    } else {
                        XCTFail("model Pear: type is missing")
                    }

                    if let required = model["required"] as? [String] {
                        XCTAssertTrue(required.contains("id"), "model Pear: required is incorrect: id")
                        XCTAssertTrue(required.contains("children"), "model Pear: required is incorrect: children")
                        XCTAssertTrue(required.contains("name"), "model Pear: required is incorrect: name")
                        XCTAssertTrue(required.contains("percent_grade"), "model Pear: required is incorrect: percent_grade")
                        XCTAssertTrue(required.count == 4, "model Pear: required.count is incorrect")
                    } else {
                        XCTFail("model Pear: type is missing")
                    }

                    if let properties = model["properties"] as? [String: Any] {
                        if let id = properties["id"] as? [String: Any] {
                            if let type = id["type"] as? String {
                                XCTAssertTrue(type == "string", "model Pear: id property has incorrect type")
                            } else {
                                XCTFail("model Pear: property id has missing type")
                            }
                        } else {
                            XCTFail("model Pear: property id is missing")
                        }

                        if let suppliers = properties["suppliers"] as? [String: Any] {
                            if let type = suppliers["type"] as? String {
                                XCTAssertTrue(type == "object", "model Pear: suppliers property has incorrect type")
                            } else {
                                XCTFail("model Pear: property suppliers has missing type")
                            }
                            if let additional = suppliers["additionalProperties"] as? [String: Any] {
                                if let type = additional["type"] as? String {
                                    XCTAssertTrue(type == "string", "model Pear: additionalProperties property has incorrect type")
                                } else {
                                    XCTFail("model Pear: property suppliers additionalProperties is missing type")
                                }
                            } else {
                                XCTFail("model Pear: property suppliers is missing additionalProperties")
                            }
                        } else {
                            XCTFail("model Pear: property suppliers is missing")
                        }
                    } else {
                        XCTFail("model Pear: properties is missing")
                    }
                }
            }
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }
    }

    func appleDefinitionsAssertions(json: String?) {
        if let jsonString = json {
            guard let data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let dict = json as? [String: Any] else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }

            // test for definitions section
            if let definitions = dict["definitions"] as? [String: Any] {
                if let model = definitions["Apple"] as? [String: Any] {
                    if let type = model["type"] as? String {
                        XCTAssertTrue(type == "object", "model Apple: type is incorrect")
                    } else {
                        XCTFail("model Apple: type is missing")
                    }

                    if let required = model["required"] as? [String] {
                        XCTAssertTrue(required.contains("answer"), "model Apple: required is incorrect")
                        XCTAssertTrue(required.count == 1, "model Apple: required.count is incorrect")
                    } else {
                        XCTFail("model Apple: required is missing")
                    }

                    if let properties = model["properties"] as? [String: Any] {
                        if let id = properties["id"] as? [String: Any] {
                            if let type = id["type"] as? String {
                                XCTAssertTrue(type == "string", "model Apple: id property has incorrect type")
                            } else {
                                XCTFail("model Apple: property id has missing type")
                            }
                        } else {
                            XCTFail("model Apple: property id is missing")
                        }

                        if let seqno = properties["seqno"] as? [String: Any] {
                            if let type = seqno["type"] as? String {
                                XCTAssertTrue(type == "integer", "model Apple: seqno property has incorrect type")
                            } else {
                                XCTFail("model Apple: property seqno has missing type")
                            }
                            if let format = seqno["format"] as? String {
                                XCTAssertTrue(format == "uint16", "model Apple: seqno property has incorrect format")
                            } else {
                                XCTFail("model Apple: property seqno has missing format")
                            }
                        } else {
                            XCTFail("model Apple: property seqno is missing")
                        }

                        if let ugly = properties["ugly"] as? [String: Any] {
                            if let ref = ugly["$ref"] as? String {
                                XCTAssertTrue(ref == "#/definitions/Uglifruit", "model Apple: ugly property has incorrect type")
                            } else {
                                XCTFail("model Apple: property ugly has missing type")
                            }
                        } else {
                            XCTFail("model Apple: property ugly is missing")
                        }
                    } else {
                        XCTFail("model Apple: properties is missing")
                    }
                }
            } else {
                XCTFail("definitions section is missing")
            }
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }
    }

    func uglifruitDefinitionsAssertions(json: String?) {
        if let jsonString = json {
            guard let data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let dict = json as? [String: Any] else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }

            // test for definitions section
            if let definitions = dict["definitions"] as? [String: Any] {
                if let model = definitions["Uglifruit"] as? [String: Any] {
                    if let type = model["type"] as? String {
                        XCTAssertTrue(type == "object", "model Uglifruit: type is incorrect")
                    } else {
                        XCTFail("model Uglifruit: type is missing")
                    }

                    XCTAssertTrue(model["required"] == nil, "model uglifruit: required should not be here")
                }
            } else {
                XCTFail("definitions section is missing")
            }
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }
    }

    func sectionsAssertions(json: String?) {
        if let jsonString = json {
            guard let data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let dict = json as? [String: Any] else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }

            // test for swagger version
            if let val = dict["swagger"] as? String {
                XCTAssertTrue(val == "2.0", "swagger version is incorrect")
            } else {
                XCTFail("swagger version is missing")
            }

            // test for basePath
            if let val = dict["basePath"] as? String {
                XCTAssertTrue(val == "/", "basePath is incorrect")
            } else {
                XCTFail("basePath is missing")
            }

            // test for schemes section
            if let schemes = dict["schemes"] as? [String] {
                XCTAssertTrue(schemes.contains("http"), "schemes does not contain http")
                XCTAssertTrue(schemes.contains("https"), "schemes does not contain https")
                XCTAssertTrue(schemes.count == 2, "schemes.count is incorrect")
            } else {
                XCTFail("schemes is missing")
            }

            // test for info section
            if let val = dict["info"] as? [String: String] {
                if let title = val["title"] {
                    XCTAssertTrue(title == "Kitura Project", "title is incorrect")
                } else {
                    XCTFail("title is missing")
                }

                if let desc = val["description"] {
                    XCTAssertTrue(desc == "Generated by Kitura", "description is incorrect")
                } else {
                    XCTFail("description is missing")
                }

                if let version = val["version"] {
                    XCTAssertTrue(version == "1.0", "version is incorrect")
                } else {
                    XCTFail("version is missing")
                }
            }
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }
    }

    func pathAssertions(json: String?) {
        if let jsonString = json {
            guard let data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let dict = json as? [String: Any] else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }

            // test for paths section
            if let paths = dict["paths"] as? [String: Any] {
                // test for path existence
                XCTAssertTrue(paths["/me/post"] != nil, "path /me/post is missing")
                XCTAssertTrue(paths["/me/getarray/{id}"] != nil, "path /me/getarray/{id} is missing")
                XCTAssertTrue(paths["/me/postid/{id}"] != nil, "path /me/postid/{id} is missing")
                XCTAssertTrue(paths["/me/getarray"] != nil, "path /me/getarray is missing")
                XCTAssertTrue(paths["/me/apple"] != nil, "path /me/apple is missing")
                XCTAssertTrue(paths["/me/getid/{id}"] != nil, "path /me/getid/{id} is missing")
                XCTAssertTrue(paths["/me/patch/{id}"] != nil, "path /me/patch/{id} is missing")
                XCTAssertTrue(paths["/me/pear"] != nil, "path /me/pear is missing")
                XCTAssertTrue(paths["/me/put/{id}"] != nil, "path /me/put/{id} is missing")
            } else {
                XCTFail("paths is missing")
            }
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }
    }

    func pathContentAssertions1(json: String?) {
        if let jsonString = json {
            guard let data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let dict = json as? [String: Any] else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }

            // test for paths section
            if let paths = dict["paths"] as? [String: Any] {
                // test for path contents
                if let path = paths["/me/put/{id}"] as? [String: Any] {
                    // test for put method
                    if let put = path["put"] as? [String: Any] {
                        // test for parameters section
                        if let parameters = put["parameters"] as? [[String: Any]] {
                            XCTAssertTrue(parameters.count == 2, "path /me/put/{id}: put parameters.count is incorrect")
                            // test for 1st parameter block
                            let p1 = parameters[0]
                            if let inval = p1["in"] as? String {
                                XCTAssertTrue(inval == "path", "path /me/put/{id}: put parameters in value is incorrect")
                            } else {
                                XCTFail("path /me/put/{id}: put parameters in value is missing")
                            }
                            if let name = p1["name"] as? String {
                                XCTAssertTrue(name == "id", "path /me/put/{id}: put parameters name value is incorrect")
                            } else {
                                XCTFail("path /me/put/{id}: put parameters name value is missing")
                            }
                            if let required = p1["required"] as? Bool {
                                XCTAssertTrue(required == true, "path /me/put/{id}: put parameters required value is incorrect")
                            } else {
                                XCTFail("path /me/put/{id}: put parameters required value is missing")
                            }
                            if let type = p1["type"] as? String {
                                XCTAssertTrue(type == "integer", "path /me/put/{id}: put parameters type value is incorrect")
                            } else {
                                XCTFail("path /me/put/{id}: put parameters type value is missing")
                            }

                            // test for 2nd parameter block
                            let p2 = parameters[1]
                            if let inval = p2["in"] as? String {
                                XCTAssertTrue(inval == "body", "path /me/put/{id}: put parameters in value is incorrect")
                            } else {
                                XCTFail("path /me/put/{id}: put parameters in value is missing")
                            }
                            if let name = p2["name"] as? String {
                                XCTAssertTrue(name == "input", "path /me/put/{id}: put parameters name value is incorrect")
                            } else {
                                XCTFail("path /me/put/{id}: put parameters name value is missing")
                            }
                            if let required = p2["required"] as? Bool {
                                XCTAssertTrue(required == true, "path /me/put/{id}: put parameters required value is incorrect")
                            } else {
                                XCTFail("path /me/put/{id}: put parameters required value is missing")
                            }
                            if let schema = p2["schema"] as? [String: String] {
                                if let ref = schema["$ref"] {
                                    XCTAssertTrue(ref == "#/definitions/Apple", "path /me/put/{id}: put parameters schema ref is incorrect")
                                } else {
                                    XCTFail("path /me/put/{id}: put parameters schema ref is missing")
                                }
                            } else {
                                XCTFail("path /me/put/{id}: put parameters schema value is missing")
                            }
                        } else {
                            XCTFail("path /me/put/{id}: put parameters are missing")
                        }
                    } else {
                        XCTFail("path /me/put/{id}: put method is missing")
                    }
                } else {
                    XCTFail("path /me/put/{id} is missing")
                }
            } else {
                XCTFail("paths is missing")
            }
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }
    }

    func pathContentAssertions2(json: String?) {
        if let jsonString = json {
            guard let data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let dict = json as? [String: Any] else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }

            // test for paths section
            if let paths = dict["paths"] as? [String: Any] {
                // test for path contents
                if let path = paths["/me/put/{id}"] as? [String: Any] {
                    // test for put method
                    if let put = path["put"] as? [String: Any] {
                        // test for produces block
                        if let produces = put["produces"] as? [String] {
                            XCTAssertTrue(produces.contains("application/json"), "path /me/put/{id}: put produces does not contain application/json")
                            XCTAssertTrue(produces.count == 1, "path /me/put/{id}: put produces.count is incorrect")
                        } else {
                            XCTFail("path /me/put/{id}: put produces is missing")
                        }
                        // test for consumes block
                        if let consumes = put["consumes"] as? [String] {
                            XCTAssertTrue(consumes.contains("application/json"), "path /me/put/{id}: put consumes does not contain application/json")
                            XCTAssertTrue(consumes.count == 1, "path /me/put/{id}: put consumes.count is incorrect")
                        } else {
                            XCTFail("path /me/put/{id}: put consumes is missing")
                        }
                        // test for responses block
                        if let responses = put["responses"] as? [String: Any] {
                            if let twohundred = responses["200"] as? [String: Any] {
                                if let description = twohundred["description"] as? String {
                                    XCTAssertTrue(description == "successful response", "path /me/put/{id}: put responses 200 description is incorrect")
                                } else {
                                    XCTFail("path /me/put/{id}: put 200 response does not contain a description")
                                }
                                if let schema = twohundred["schema"] as? [String: Any] {
                                    if let ref = schema["$ref"] as? String {
                                        XCTAssertTrue(ref == "#/definitions/Apple", "path /me/put/{id}: put responses 200 schema is incorrect")
                                    } else {
                                        XCTFail("path /me/put/{id}: put 200 response schema is missing")
                                    }
                                } else {
                                    XCTFail("path /me/put/{id}: put 200 response does not contain a schema")
                                }
                            } else {
                                XCTFail("path /me/put/{id}: put 200 response is missing")
                            }
                            XCTAssertTrue(responses.count == 1, "path /me/put/{id}: put responses.count is incorrect")
                        } else {
                            XCTFail("path /me/put/{id}: put responses is missing")
                        }
                    } else {
                        XCTFail("path /me/put/{id}: put method is missing")
                    }
                } else {
                    XCTFail("path /me/put/{id} is missing")
                }
            } else {
                XCTFail("paths is missing")
            }
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }
    }

    func pathContentAssertions3(json: String?) {
        if let jsonString = json {
            guard let data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }
            guard let dict = json as? [String: Any] else {
                XCTFail("got unexpected nil from router.swaggerJSON")
                return
            }

            // test for paths section
            if let paths = dict["paths"] as? [String: Any] {
                if let path = paths["/me/post"] as? [String: Any] {
                    if let post = path["post"] as? [String: Any] {
                        if let parameters = post["parameters"] as? [[String: Any]] {
                            XCTAssertTrue(parameters.count == 1, "path /me/post: post parameters.count is incorrect")
                        } else {
                            XCTFail("path /me/post: post parameters are missing")
                        }
                    } else {
                        XCTFail("path /me/post: post method is missing")
                    }
                } else {
                    XCTFail("path /me/post is missing")
                }

                // test for path contents
                if let path = paths["/me/pear"] as? [String: Any] {
                    // test for delete method
                    if let delete = path["delete"] as? [String: Any] {
                        if let parameters = delete["parameters"] as? [[String: Any]] {
                            XCTAssertTrue(parameters.count == 0, "path /me/pear: delete parameters.count is incorrect")
                        } else {
                            XCTFail("path /me/pear: delete parameters are missing")
                        }
                    } else {
                        XCTFail("path /me/pear: delete method is missing")
                    }
                    // test for get method
                    if let get = path["get"] as? [String: Any] {
                        if let parameters = get["parameters"] as? [[String: Any]] {
                            XCTAssertTrue(parameters.count == 0, "path /me/pear: get parameters.count is incorrect")
                        } else {
                            XCTFail("path /me/pear: get parameters are missing")
                        }
                    } else {
                        XCTFail("path /me/pear: delete method is missing")
                    }
                } else {
                    XCTFail("path /me/pear is missing")
                }
            } else {
                XCTFail("paths is missing")
            }
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }
    }

    func testSwaggerGeneration() {
        // test correct values returned from JsonApiDoc property
        let router = Router()

        router.delete("/me/pear", handler: deleteHandler)
        router.get("/me/pear", handler: getPearHandler)
        router.get("/me/apple", handler: getAppleHandler)
        router.get("/me/getarray", handler: getArrayAppleHandler)
        router.get("/me/getarray", handler: getSingleArrayAppleHandler)
        router.get("/me/getid", handler: getSingleAppleHandler)

        router.patch("/me/patch", handler: patchSingleAppleHandler)

        router.post("/me/post", handler: postAppleHandler)
        router.post("/me/postid", handler: postSingleAppleHandler)

        router.put("/me/put", handler: putSingleAppleHandler)

        setupServerAndExpectations(router: router, expectStart: true, expectStop: true, expectFail: false)

        let requestQueue = DispatchQueue(label: "Request queue")
        requestQueue.async() {
            Kitura.start()
        }

        sectionsAssertions(json: router.swaggerJSON)
        appleDefinitionsAssertions(json: router.swaggerJSON)
        pearDefinitionsAssertions(json: router.swaggerJSON)
        uglifruitDefinitionsAssertions(json: router.swaggerJSON)
        pathAssertions(json: router.swaggerJSON)
        pathContentAssertions1(json: router.swaggerJSON)
        pathContentAssertions2(json: router.swaggerJSON)
        pathContentAssertions3(json: router.swaggerJSON)

        requestQueue.async() {
            Kitura.stop()
        }

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
}
