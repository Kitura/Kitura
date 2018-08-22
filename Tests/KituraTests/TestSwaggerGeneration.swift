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

struct QueryStringParam: QueryParams {
    public let stringField: String
}

struct QueryIntFieldParam: QueryParams {
    public let intField: Int32
}

struct QueryIntFieldOptionalParam: QueryParams {
    public let intField: Int?
}

struct QueryIntFieldArrayParam: QueryParams {
    public let intField: [Int32]
}

struct QueryThreeParams: QueryParams {
    public let intArrayField: [Int32]?
    public let intField: Int32
    public let stringField: String
}

// handler to use in the tests
func getQueryUglifruitHandler1(query: QueryStringParam, completion: (Uglifruit?, RequestError?) -> Void ) -> Void {
    let ugli = Uglifruit(auth: "hi", colour: "red", flavour: "tangy", test: nil)
    completion(ugli, nil)
}

func getQueryUglifruitHandler2(query: QueryIntFieldParam, completion: (Uglifruit?, RequestError?) -> Void ) -> Void {
    let ugli = Uglifruit(auth: "hi", colour: "red", flavour: "tangy", test: nil)
    completion(ugli, nil)
}

func getQueryUglifruitHandler3(query: QueryIntFieldOptionalParam, completion: (Uglifruit?, RequestError?) -> Void ) -> Void {
    let ugli = Uglifruit(auth: "hi", colour: "red", flavour: "tangy", test: nil)
    completion(ugli, nil)
}

func getQueryUglifruitHandler4(query: QueryIntFieldArrayParam, completion: (Uglifruit?, RequestError?) -> Void ) -> Void {
    let ugli = Uglifruit(auth: "hi", colour: "red", flavour: "tangy", test: nil)
    completion(ugli, nil)
}

func getQueryUglifruitHandler5(query: QueryThreeParams, completion: (Uglifruit?, RequestError?) -> Void ) -> Void {
    let ugli = Uglifruit(auth: "hi", colour: "red", flavour: "tangy", test: nil)
    completion(ugli, nil)
}

func getQueryUglifruitHandler6(query: QueryThreeParams?, completion: (Uglifruit?, RequestError?) -> Void ) -> Void {
    let ugli = Uglifruit(auth: "hi", colour: "red", flavour: "tangy", test: nil)
    completion(ugli, nil)
}

func deleteQueryUglifruitHandler1(query: QueryIntFieldParam, completion: (RequestError?) -> Void) {
    completion(nil)
}

func deleteQueryUglifruitHandler2(query: QueryIntFieldParam?, completion: (RequestError?) -> Void) {
    completion(nil)
}

func deleteQueryUglifruitHandler3(query: QueryThreeParams?, completion: (RequestError?) -> Void) {
    completion(nil)
}

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

func putSingleAppleHandlerStringId(id: String, posted: Apple, completion: (Apple?, RequestError?) -> Void ) -> Void {
    completion(nil, nil)
}

func putSingleAppleHandlerIntId(id: Int, posted: Apple, completion: (Apple?, RequestError?) -> Void ) -> Void {
    completion(nil, nil)
}

func patchSingleAppleHandler(id: Int, posted: Apple, completion: (Apple?, RequestError?) -> Void ) -> Void {
    completion(nil, nil)
}

class TestSwaggerGeneration: KituraTest {

    static var allTests: [(String, (TestSwaggerGeneration) -> () throws -> Void)] {
        return [
            ("testSwaggerDefinitions", testSwaggerDefinitions),
            ("testSwaggerSections", testSwaggerSections),
            ("testSwaggerContent", testSwaggerContent),
            ("testSwaggerQueryParams", testSwaggerQueryParams),
        ]
    }

    let httpPort = 8080
    let router = Router()

    override func setUp() {
        super.setUp()
        stopServer() // stop common server so we can run these tests
        router.delete("/me/pear", handler: deleteHandler)
        router.get("/me/pear", handler: getPearHandler)
        router.get("/me/apple", handler: getAppleHandler)
        router.get("/me/getarray", handler: getArrayAppleHandler)
        router.get("/me/getarray", handler: getSingleArrayAppleHandler)
        router.get("/me/getid", handler: getSingleAppleHandler)
        router.get("/me/getugli1", handler: getQueryUglifruitHandler1)
        router.get("/me/getugli2", handler: getQueryUglifruitHandler2)
        router.get("/me/getugli3", handler: getQueryUglifruitHandler3)
        router.get("/me/getugli4", handler: getQueryUglifruitHandler4)
        router.get("/me/getugli5", handler: getQueryUglifruitHandler5)
        router.get("/me/getugli6", handler: getQueryUglifruitHandler6)
        router.delete("/me/delugli1", handler: deleteQueryUglifruitHandler1)
        router.delete("/me/delugli2", handler: deleteQueryUglifruitHandler2)
        router.delete("/me/delugli3", handler: deleteQueryUglifruitHandler3)

        router.patch("/me/patch", handler: patchSingleAppleHandler)

        router.post("/me/post", handler: postAppleHandler)
        router.post("/me/postid", handler: postSingleAppleHandler)

        router.put("/me/puts", handler: putSingleAppleHandlerStringId)
        router.put("/me/puti", handler: putSingleAppleHandlerIntId)
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

    func pathAssertions(paths: [String: Any]) {
        // test for path existence
        XCTAssertTrue(paths["/me/post"] != nil, "path /me/post is missing")
        XCTAssertTrue(paths["/me/getarray/{id}"] != nil, "path /me/getarray/{id} is missing")
        XCTAssertTrue(paths["/me/postid/{id}"] != nil, "path /me/postid/{id} is missing")
        XCTAssertTrue(paths["/me/getarray"] != nil, "path /me/getarray is missing")
        XCTAssertTrue(paths["/me/apple"] != nil, "path /me/apple is missing")
        XCTAssertTrue(paths["/me/getid/{id}"] != nil, "path /me/getid/{id} is missing")
        XCTAssertTrue(paths["/me/patch/{id}"] != nil, "path /me/patch/{id} is missing")
        XCTAssertTrue(paths["/me/pear"] != nil, "path /me/pear is missing")
        XCTAssertTrue(paths["/me/puts/{id}"] != nil, "path /me/puts/{id} is missing")
        XCTAssertTrue(paths["/me/puti/{id}"] != nil, "path /me/puti/{id} is missing")
    }

    func pearDefinitionsAssertions(definitions: [String: Any]) {
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

    func appleDefinitionsAssertions(definitions: [String: Any]) {
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
    }

    func uglifruitDefinitionsAssertions(definitions: [String: Any]) {
        if let model = definitions["Uglifruit"] as? [String: Any] {
            if let type = model["type"] as? String {
                XCTAssertTrue(type == "object", "model Uglifruit: type is incorrect")
            } else {
                XCTFail("model Uglifruit: type is missing")
            }

            XCTAssertTrue(model["required"] == nil, "model uglifruit: required should not be here")
        }
    }

    func sectionsAssertions(dict: [String: Any]) {
        // test for swagger version
        if let swagger = dict["swagger"] as? String {
            XCTAssertTrue(swagger == "2.0", "swagger version is incorrect")
        } else {
            XCTFail("swagger version is missing")
        }

        // test for basePath
        if let basepath = dict["basePath"] as? String {
            XCTAssertTrue(basepath == "/", "basePath is incorrect")
        } else {
            XCTFail("basePath is missing")
        }

        // test for schemes section
        if let schemes = dict["schemes"] as? [String] {
            XCTAssertTrue(schemes.contains("http"), "schemes does not contain http")
            XCTAssertTrue(schemes.count == 1, "schemes.count is incorrect")
        } else {
            XCTFail("schemes is missing")
        }

        // test for info section
        if let info = dict["info"] as? [String: String] {
            if let title = info["title"] {
                XCTAssertTrue(title == "Kitura Project", "title is incorrect")
            } else {
                XCTFail("title is missing")
            }

            if let desc = info["description"] {
                XCTAssertTrue(desc == "Generated by Kitura", "description is incorrect")
            } else {
                XCTFail("description is missing")
            }

            if let version = info["version"] {
                XCTAssertTrue(version == "1.0", "version is incorrect")
            } else {
                XCTFail("version is missing")
            }
        }
    }

    func pathContentAssertions1(paths: [String: Any]) {
        // test for path contents
        if let path = paths["/me/puts/{id}"] as? [String: Any] {
            // test for put method
            if let put = path["put"] as? [String: Any] {
                // test for parameters section
                if let parameters = put["parameters"] as? [[String: Any]] {
                    XCTAssertTrue(parameters.count == 2, "path /me/puts{id}: put parameters.count is incorrect")
                    // test for 1st parameter block
                    let param1 = parameters[0]
                    if let inval = param1["in"] as? String {
                        XCTAssertTrue(inval == "path", "path /me/puts/{id}: put parameters in value is incorrect")
                    } else {
                        XCTFail("path /me/puts/{id}: put parameters in value is missing")
                    }
                    if let name = param1["name"] as? String {
                        XCTAssertTrue(name == "id", "path /me/puts/{id}: put parameters name value is incorrect")
                    } else {
                        XCTFail("path /me/puts/{id}: put parameters name value is missing")
                    }
                    if let required = param1["required"] as? Bool {
                        XCTAssertTrue(required == true, "path /me/puts/{id}: put parameters required value is incorrect")
                    } else {
                        XCTFail("path /me/puts/{id}: put parameters required value is missing")
                    }
                    if let type = param1["type"] as? String {
                        XCTAssertTrue(type == "string", "path /me/puts/{id}: put parameters type value is incorrect")
                    } else {
                        XCTFail("path /me/puts/{id}: put parameters type value is missing")
                    }

                    // test for 2nd parameter block
                    let param2 = parameters[1]
                    if let inval = param2["in"] as? String {
                        XCTAssertTrue(inval == "body", "path /me/puts/{id}: put parameters in value is incorrect")
                    } else {
                        XCTFail("path /me/puts/{id}: put parameters in value is missing")
                    }
                    if let name = param2["name"] as? String {
                        XCTAssertTrue(name == "input", "path /me/puts/{id}: put parameters name value is incorrect")
                    } else {
                        XCTFail("path /me/puts/{id}: put parameters name value is missing")
                    }
                    if let required = param2["required"] as? Bool {
                        XCTAssertTrue(required == true, "path /me/puts/{id}: put parameters required value is incorrect")
                    } else {
                        XCTFail("path /me/puts/{id}: put parameters required value is missing")
                    }
                    if let schema = param2["schema"] as? [String: String] {
                        if let ref = schema["$ref"] {
                            XCTAssertTrue(ref == "#/definitions/Apple", "path /me/puts/{id}: put parameters schema ref is incorrect")
                        } else {
                            XCTFail("path /me/puts/{id}: put parameters schema ref is missing")
                        }
                    } else {
                        XCTFail("path /me/puts/{id}: put parameters schema value is missing")
                    }
                } else {
                    XCTFail("path /me/puts/{id}: put parameters are missing")
                }
            } else {
                XCTFail("path /me/puts/{id}: put method is missing")
            }
        } else {
            XCTFail("path /me/puts/{id} is missing")
        }
    }

    func pathContentAssertions2(paths: [String: Any]) {
        // test for path contents
        if let path = paths["/me/puts/{id}"] as? [String: Any] {
            // test for put method
            if let put = path["put"] as? [String: Any] {
                // test for produces block
                if let produces = put["produces"] as? [String] {
                    XCTAssertTrue(produces.contains("application/json"), "path /me/puts/{id}: put produces does not contain application/json")
                    XCTAssertTrue(produces.count == 1, "path /me/puts/{id}: put produces.count is incorrect")
                } else {
                    XCTFail("path /me/puts/{id}: put produces is missing")
                }
                // test for consumes block
                if let consumes = put["consumes"] as? [String] {
                    XCTAssertTrue(consumes.contains("application/json"), "path /me/puts/{id}: put consumes does not contain application/json")
                    XCTAssertTrue(consumes.count == 1, "path /me/puts/{id}: put consumes.count is incorrect")
                } else {
                    XCTFail("path /me/puts/{id}: put consumes is missing")
                }
                // test for responses block
                if let responses = put["responses"] as? [String: Any] {
                    if let twohundred = responses["200"] as? [String: Any] {
                        if let description = twohundred["description"] as? String {
                            XCTAssertTrue(description == "successful response", "path /me/puts/{id}: put responses 200 description is incorrect")
                        } else {
                            XCTFail("path /me/puts/{id}: put 200 response does not contain a description")
                        }
                        if let schema = twohundred["schema"] as? [String: Any] {
                            if let ref = schema["$ref"] as? String {
                                XCTAssertTrue(ref == "#/definitions/Apple", "path /me/puts/{id}: put responses 200 schema is incorrect")
                            } else {
                                XCTFail("path /me/puts/{id}: put 200 response schema is missing")
                            }
                        } else {
                            XCTFail("path /me/puts/{id}: put 200 response does not contain a schema")
                        }
                    } else {
                        XCTFail("path /me/puts/{id}: put 200 response is missing")
                    }
                    XCTAssertTrue(responses.count == 1, "path /me/puts/{id}: put responses.count is incorrect")
                } else {
                    XCTFail("path /me/puts/{id}: put responses is missing")
                }
            } else {
                XCTFail("path /me/puts/{id}: put method is missing")
            }
        } else {
            XCTFail("path /me/puts/{id} is missing")
        }
    }

    func pathContentAssertions3(paths: [String: Any]) {
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
                XCTAssertTrue(delete["parameters"] == nil, "path /me/pear: delete parameters found when they should not exist")
            } else {
                XCTFail("path /me/pear: delete method is missing")
            }
            // test for get method
            if let get = path["get"] as? [String: Any] {
                XCTAssertTrue(get["parameters"] == nil, "path /me/pear: get parameters found when they should not exist")
            } else {
                XCTFail("path /me/pear: get method is missing")
            }
        } else {
            XCTFail("path /me/pear is missing")
        }
    }

    func pathContentAssertions4(paths: [String: Any]) {
        // test for path contents
        if let path = paths["/me/puti/{id}"] as? [String: Any] {
            // test for put method
            if let put = path["put"] as? [String: Any] {
                // test for parameters section
                if let parameters = put["parameters"] as? [[String: Any]] {
                    XCTAssertTrue(parameters.count == 2, "path /me/puti{id}: put parameters.count is incorrect")
                    // test for 1st parameter block
                    let param = parameters[0]
                    if let inval = param["in"] as? String {
                        XCTAssertTrue(inval == "path", "path /me/puti/{id}: put parameters in value is incorrect")
                    } else {
                        XCTFail("path /me/puti/{id}: put parameters in value is missing")
                    }
                    if let name = param["name"] as? String {
                        XCTAssertTrue(name == "id", "path /me/puti/{id}: put parameters name value is incorrect")
                    } else {
                        XCTFail("path /me/puti/{id}: put parameters name value is missing")
                    }
                    if let required = param["required"] as? Bool {
                        XCTAssertTrue(required == true, "path /me/puti/{id}: put parameters required value is incorrect")
                    } else {
                        XCTFail("path /me/puti/{id}: put parameters required value is missing")
                    }
                    if let type = param["type"] as? String {
                        XCTAssertTrue(type == "integer", "path /me/puti/{id}: put parameters type value is incorrect")
                    } else {
                        XCTFail("path /me/puti/{id}: put parameters type value is missing")
                    }
                } else {
                    XCTFail("path /me/puti/{id}: put parameters are missing")
                }
            } else {
                XCTFail("path /me/puti/{id}: put method is missing")
            }
        } else {
            XCTFail("path /me/puti/{id} is missing")
        }
    }

    func pathGetQueryParams1(paths: [String: Any]) {
        // test for path contents
        if let path = paths["/me/getugli1"] as? [String: Any] {
            // test for put method
            if let get = path["get"] as? [String: Any] {
                // test for parameters section
                if let parameters = get["parameters"] as? [[String: Any]] {
                    XCTAssertTrue(parameters.count == 1, "path /me/getugli1: query parameters.count is incorrect")
                    // test for 1st parameter block
                    let param = parameters[0]
                    if let inval = param["in"] as? String {
                        XCTAssertTrue(inval == "query", "path /me/getugli1: query param 'in' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli1: query parameters 'in' value is missing")
                    }
                    if let name = param["name"] as? String {
                        XCTAssertTrue(name == "stringField", "path /me/getugli1: query param 'name' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli1: query parameters 'name' value is missing")
                    }
                    if let required = param["required"] as? Bool {
                        XCTAssertTrue(required, "path /me/getugli1: query param 'required' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli1: query parameters 'required' value is missing")
                    }
                    if let type = param["type"] as? String {
                        XCTAssertTrue(type == "string", "path /me/getugli1: query param 'type' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli1: query parameters 'type' value is missing")
                    }
                } else {
                    XCTFail("path /me/getugli1: query parameters are missing")
                }
            } else {
                XCTFail("path /me/getugli1: get method is missing")
            }
        } else {
            XCTFail("path /me/getugli1 is missing")
        }
    }

    func pathGetQueryParams2(paths: [String: Any]) {
        // test for path contents
        if let path = paths["/me/getugli2"] as? [String: Any] {
            // test for put method
            if let get = path["get"] as? [String: Any] {
                // test for parameters section
                if let parameters = get["parameters"] as? [[String: Any]] {
                    XCTAssertTrue(parameters.count == 1, "path /me/getugli2: query parameters.count is incorrect")
                    // test for 1st parameter block
                    let param = parameters[0]
                    if let inval = param["in"] as? String {
                        XCTAssertTrue(inval == "query", "path /me/getugli2: query param 'in' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli2: query parameters 'in' value is missing")
                    }
                    if let name = param["name"] as? String {
                        XCTAssertTrue(name == "intField", "path /me/getugli2: query param 'name' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli2: query parameters 'name' value is missing")
                    }
                    if let format = param["format"] as? String {
                        XCTAssertTrue(format == "int32", "path /me/getugli2: query param 'format' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli2: query parameters 'format' value is missing")
                    }
                    if let required = param["required"] as? Bool {
                        XCTAssertTrue(required, "path /me/getugli2: query param 'required' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli2: query parameters 'required' value is missing")
                    }
                    if let type = param["type"] as? String {
                        XCTAssertTrue(type == "integer", "path /me/getugli2: query param 'type' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli2: query parameters 'type' value is missing")
                    }
                } else {
                    XCTFail("path /me/getugli2: query parameters are missing")
                }
            } else {
                XCTFail("path /me/getugli2: get method is missing")
            }
        } else {
            XCTFail("path /me/getugli2 is missing")
        }
    }

    func pathGetQueryParams3(paths: [String: Any]) {
        // test for path contents
        if let path = paths["/me/getugli3"] as? [String: Any] {
            // test for put method
            if let get = path["get"] as? [String: Any] {
                // test for parameters section
                if let parameters = get["parameters"] as? [[String: Any]] {
                    XCTAssertTrue(parameters.count == 1, "path /me/getugli3: query parameters.count is incorrect")
                    // test for 1st parameter block
                    let param = parameters[0]
                    if let inval = param["in"] as? String {
                        XCTAssertTrue(inval == "query", "path /me/getugli3: query param 'in' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli3: query parameters 'in' value is missing")
                    }
                    if let name = param["name"] as? String {
                        XCTAssertTrue(name == "intField", "path /me/getugli3: query param 'name' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli3: query parameters 'name' value is missing")
                    }
                    if let required = param["required"] as? Bool {
                        XCTAssertFalse(required, "path /me/getugli3: query param 'required' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli3: query parameters 'required' value is missing")
                    }
                    if let type = param["type"] as? String {
                        XCTAssertTrue(type == "integer", "path /me/getugli3: query param 'type' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli3: query parameters 'type' value is missing")
                    }
                    XCTAssertTrue(param["format"] == nil, "path /me/getugli3: query parameters 'format' value is found when it should not exist")
                } else {
                    XCTFail("path /me/getugli3: query parameters are missing")
                }
            } else {
                XCTFail("path /me/getugli3: get method is missing")
            }
        } else {
            XCTFail("path /me/getugli3 is missing")
        }
    }

    func pathGetQueryParams4(paths: [String: Any]) {
        // test for path contents
        if let path = paths["/me/getugli4"] as? [String: Any] {
            // test for put method
            if let get = path["get"] as? [String: Any] {
                // test for parameters section
                if let parameters = get["parameters"] as? [[String: Any]] {
                    XCTAssertTrue(parameters.count == 1, "path /me/getugli4: query parameters.count is incorrect")
                    // test for 1st parameter block
                    let param = parameters[0]
                    if let inval = param["in"] as? String {
                        XCTAssertTrue(inval == "query", "path /me/getugli4: query param 'in' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli4: query parameters 'in' value is missing")
                    }
                    if let name = param["name"] as? String {
                        XCTAssertTrue(name == "intField", "path /me/getugli4: query param 'name' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli4: query parameters 'name' value is missing")
                    }
                    if let items = param["items"] as? [String: Any] {
                        if let type = items["type"] as? String {
                            XCTAssertTrue(type == "integer", "path /me/getugli4: query param 'items[type]' value is incorrect")
                        } else {
                            XCTFail("path /me/getugli4: query parameters 'items[type]' value is missing")
                        }
                        if let format = items["format"] as? String {
                            XCTAssertTrue(format == "int32", "path /me/getugli4: query param 'items[format]' value is incorrect")
                        } else {
                            XCTFail("path /me/getugli4: query parameters 'items[format]' value is missing")
                        }
                    } else {
                        XCTFail("path /me/getugli4: query parameters 'items' value is missing")
                    }
                    if let collectionFormat = param["collectionFormat"] as? String {
                        XCTAssertTrue(collectionFormat == "csv", "path /me/getugli4: query param 'collectionFormat' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli4: query parameters 'collectionFormat' value is missing")
                    }
                    if let required = param["required"] as? Bool {
                        XCTAssertTrue(required, "path /me/getugli4: query param 'required' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli4: query parameters 'required' value is missing")
                    }
                    if let type = param["type"] as? String {
                        XCTAssertTrue(type == "array", "path /me/getugli4: query param 'type' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli4: query parameters 'type' value is missing")
                    }
                } else {
                    XCTFail("path /me/getugli4: query parameters are missing")
                }
            } else {
                XCTFail("path /me/getugli4: get method is missing")
            }
        } else {
            XCTFail("path /me/getugli4 is missing")
        }
    }

    func pathGetQueryParams5(paths: [String: Any]) {
        if let path = paths["/me/getugli5"] as? [String: Any] {
            // test for put method
            if let get = path["get"] as? [String: Any] {
                // test for parameters section
                if let parameters = get["parameters"] as? [[String: Any]] {
                    XCTAssertTrue(parameters.count == 3, "path /me/getugli5: get parameters.count is incorrect")
                    // test for 1st parameter block
                    let param = parameters[0]
                    if let inval = param["in"] as? String {
                        XCTAssertTrue(inval == "query", "path /me/getugli5: get parameters 'in' value is incorrect")
                    } else {
                        XCTFail("path /me/getugli5: get parameters 'in' value is missing")
                    }
                } else {
                    XCTFail("path /me/getugli5: get parameters are missing")
                }
            } else {
                XCTFail("path /me/getugli5: get method is missing")
            }
        } else {
            XCTFail("path /me/getugli5 is missing")
        }
    }

    func pathDeleteQueryParams(paths: [String: Any]) {
        // Confirm that query params are created for deletes.
        if let path = paths["/me/delugli1"] as? [String: Any] {
            // test for put method
            if let delete = path["delete"] as? [String: Any] {
                // test for parameters section
                if let parameters = delete["parameters"] as? [[String: Any]] {
                    XCTAssertTrue(parameters.count == 1, "path /me/delugli1: get parameters.count is incorrect")
                    // test for 1st parameter block
                    let param = parameters[0]
                    if let inval = param["in"] as? String {
                        XCTAssertTrue(inval == "query", "path /me/delugli1: delete parameters 'in' value is incorrect")
                    } else {
                        XCTFail("path /me/delugli1: delete parameters 'in' value is missing")
                    }
                } else {
                    XCTFail("path /me/delugli1: delete parameters are missing")
                }
            } else {
                XCTFail("path /me/delugli1: delete method is missing")
            }
        } else {
            XCTFail("path /me/delugli1 is missing")
        }

        if let path = paths["/me/delugli2"] as? [String: Any] {
            // test for put method
            if let delete = path["delete"] as? [String: Any] {
                // test for parameters section
                if let parameters = delete["parameters"] as? [[String: Any]] {
                    XCTAssertTrue(parameters.count == 1, "path /me/delugli2: get parameters.count is incorrect")
                    // test for 1st parameter block
                    let param = parameters[0]
                    if let inval = param["in"] as? String {
                        XCTAssertTrue(inval == "query", "path /me/delugli2: delete parameters 'in' value is incorrect")
                    } else {
                        XCTFail("path /me/delugli2: delete parameters 'in' value is missing")
                    }
                } else {
                    XCTFail("path /me/delugli2: delete parameters are missing")
                }
            } else {
                XCTFail("path /me/delugli2: delete method is missing")
            }
        } else {
            XCTFail("path /me/delugli2 is missing")
        }
    }

    func pathOptionalQueryParams(paths: [String: Any]) {
        // Ensure that an optional query param causes all fields in the query
        // params to be optional.
        if let path = paths["/me/getugli6"] as? [String: Any] {
            // test for put method
            if let get = path["get"] as? [String: Any] {
                // test for parameters section
                if let parameters = get["parameters"] as? [[String: Any]] {
                    XCTAssertTrue(parameters.count == 3, "path /me/getugli6: get parameters.count is incorrect")
                    // test for 1st parameter block
                    for i in 0 ... 2 {
                        let param = parameters[i]
                        if let required = param["required"] as? Bool {
                            XCTAssertTrue(required == false, "path /me/getugli6 get parameter[\(i)] 'required' value is incorrect")
                        } else {
                            XCTFail("path /me/getugli6: get parameters[\(i)] 'required' value is missing")
                        }
                    }
                } else {
                    XCTFail("path /me/getugli6: get parameters are missing")
                }
            } else {
                XCTFail("path /me/getugli6: get method is missing")
            }
        } else {
            XCTFail("path /me/getugli6 is missing")
        }

        if let path = paths["/me/delugli3"] as? [String: Any] {
            // test for put method
            if let get = path["delete"] as? [String: Any] {
                // test for parameters section
                if let parameters = get["parameters"] as? [[String: Any]] {
                    XCTAssertTrue(parameters.count == 3, "path /me/delugli3: delete parameters.count is incorrect")
                    // test for 1st parameter block
                    for i in 0 ... 2 {
                        let param = parameters[i]
                        if let required = param["required"] as? Bool {
                            XCTAssertTrue(required == false, "path /me/delugli3 delete parameter[\(i)] 'required' value is incorrect")
                        } else {
                            XCTFail("path /me/delugli3: delete parameters[\(i)] 'required' value is missing")
                        }
                    }
                } else {
                    XCTFail("path /me/delugli3: delete parameters are missing")
                }
            } else {
                XCTFail("path /me/delugli3: delete method is missing")
            }
        } else {
            XCTFail("path /me/delugli3 is missing")
        }
    }

    func testSwaggerSections() {
        // test correct values returned from JsonApiDoc property
        setupServerAndExpectations(router: router, expectStart: true, expectStop: true, expectFail: false)

        let requestQueue = DispatchQueue(label: "Request queue")
        requestQueue.async() {
            Kitura.start()
        }

        if let jsonString = router.swaggerJSON {
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

            // test for document sections
            sectionsAssertions(dict: dict)
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }

        requestQueue.async() {
            Kitura.stop()
        }

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }

    func testSwaggerContent() {
        // test correct values returned from JsonApiDoc property
        setupServerAndExpectations(router: router, expectStart: true, expectStop: true, expectFail: false)

        let requestQueue = DispatchQueue(label: "Request queue")
        requestQueue.async() {
            Kitura.start()
        }


        if let jsonString = router.swaggerJSON {
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
                pathAssertions(paths: paths)
                pathContentAssertions1(paths: paths)
                pathContentAssertions2(paths: paths)
                pathContentAssertions3(paths: paths)
                pathContentAssertions4(paths: paths)
            } else {
                XCTFail("paths is missing")
            }
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }

        requestQueue.async() {
            Kitura.stop()
        }

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }

    func testSwaggerQueryParams() {
        // test correct values returned from JsonApiDoc property
        setupServerAndExpectations(router: router, expectStart: true, expectStop: true, expectFail: false)

        let requestQueue = DispatchQueue(label: "Request queue")
        requestQueue.async() {
            Kitura.start()
        }

        if let jsonString = router.swaggerJSON {
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
                pathGetQueryParams1(paths: paths)
                pathGetQueryParams2(paths: paths)
                pathGetQueryParams3(paths: paths)
                pathGetQueryParams4(paths: paths)
                pathGetQueryParams5(paths: paths)
                pathOptionalQueryParams(paths: paths)
                pathDeleteQueryParams(paths: paths)
            } else {
                XCTFail("paths is missing")
            }
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }

        requestQueue.async() {
            Kitura.stop()
        }

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }

    func testSwaggerDefinitions() {
        // test correct values returned from JsonApiDoc property
        setupServerAndExpectations(router: router, expectStart: true, expectStop: true, expectFail: false)

        let requestQueue = DispatchQueue(label: "Request queue")
        requestQueue.async() {
            Kitura.start()
        }

        if let jsonString = router.swaggerJSON {
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

            // test for document sections
            sectionsAssertions(dict: dict)

            // test for definitions section
            if let definitions = dict["definitions"] as? [String: Any] {
                appleDefinitionsAssertions(definitions: definitions)
                pearDefinitionsAssertions(definitions: definitions)
                uglifruitDefinitionsAssertions(definitions: definitions)
            } else {
                XCTFail("definitions section is missing")
            }
        } else {
            XCTFail("got unexpected nil from router.swaggerJSON")
        }

        requestQueue.async() {
            Kitura.stop()
        }

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
}
