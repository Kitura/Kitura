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

func getDeckHandler(completion: (Deck?, RequestError?) -> Void ) -> Void {
    completion(nil, nil)
}

func getArrayAppleHandler(completion: ([Apple]?, RequestError?) -> Void ) -> Void {
    completion(nil, nil)
}

func getSingleAppleHandler(id: Int, completion: (Apple?, RequestError?) -> Void) -> Void {
    completion(nil, nil)
}

func getTupleArrayAppleHandler(completion: ([(Int, Apple)]?, RequestError?) -> Void) -> Void {
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

// A route that has an input type (Banana) that is never used as an output type.
// Used to test that swagger describes the input models.
func postBananaHandler(posted: Banana, completion: (Apple?, RequestError?) -> Void) -> Void {
    completion(nil, nil)
}

// A route that has an output type (SingleValueComplexType) whose encoding is a
// single value of type NestedType. Used to test that swagger correctly generates
// a model for SingleValueComplexType, whose structure is that of NestedType.
func getSingleValueComplexType(id: Int, completion: (SingleValueComplexType?, RequestError?) -> Void) -> Void {
    completion(SingleValueComplexType(content: NestedType(apple: "Apple", banana: 1)), nil)
}

// A route that accepts an ID and returns a single value, where that value is an
// Array type.
func getSingularArrayType(id: Int, completion: ([Apple]?, RequestError?) -> Void) -> Void {
    completion(nil, nil)
}

// A route tht returns a value that embeds models within Array and Dictionary
// collection types, and where those types do not appear elsewhere within the API.
func getEmbeddedInCollectionType(id: Int, completion: (EmbeddedInCollection?, RequestError?) -> Void) -> Void {
    completion(nil, nil)
}

final class TestSwaggerGeneration: KituraTest, KituraTestSuite {

    static var allTests: [(String, (TestSwaggerGeneration) -> () throws -> Void)] {
        return [
            ("testSwaggerVersion", testSwaggerVersion),
            ("testBasePath", testBasePath),
            ("testInfo", testInfo),
            ("testCustomInfo", testCustomInfo),
            ("testSwaggerDefinitions", testSwaggerDefinitions),
            ("testSwaggerContent", testSwaggerContent),
            ("testSwaggerQueryParams", testSwaggerQueryParams),
            ("testArrayReturnTypes", testArrayReturnTypes),
            ("testTupleArrayReturnTypes", testTupleArrayReturnTypes),
            ("testPostReturningId", testPostReturningId),
            ("testInputTypesModelled", testInputTypesModelled),
            ("testNestedTypesModelled", testNestedTypesModelled),
            ("testSingleValueComplexType", testSingleValueComplexType),
            ("testCustomDateEncoding", testCustomDateEncoding),
            ("testGetSingularArray", testGetSingularArray),
            ("testTypesEmbeddedInCollections", testTypesEmbeddedInCollections),
        ]
    }

    let router = Router()

    override func setUp() {
        super.setUp()
        router.delete("/me/pear", handler: deleteHandler)
        router.get("/me/pear", handler: getPearHandler)
        router.get("/me/apple", handler: getAppleHandler)
        router.get("/me/deck", handler: getDeckHandler)
        router.get("/me/getArray", handler: getArrayAppleHandler)
        router.get("/me/getTupleArray", handler: getTupleArrayAppleHandler)
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

        router.post("/banana", handler: postBananaHandler)

        router.get("/singleValueComplexType", handler: getSingleValueComplexType)
        router.get("/getSingularArrayType", handler: getSingularArrayType)
        router.get("/getEmbeddedInCollectionType", handler: getEmbeddedInCollectionType)
    }

    func pathAssertions(paths: [String: Any]) {
        // test for path existence
        XCTAssertTrue(paths["/me/post"] != nil, "path /me/post is missing")
        XCTAssertTrue(paths["/me/getTupleArray"] != nil, "path /me/getTupleArray is missing")
        XCTAssertTrue(paths["/me/postid"] != nil, "path /me/postid is missing")
        XCTAssertTrue(paths["/me/getArray"] != nil, "path /me/getArray is missing")
        XCTAssertTrue(paths["/me/apple"] != nil, "path /me/apple is missing")
        XCTAssertTrue(paths["/me/deck"] != nil, "path /me/deck is missing")
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

    func deckDefinitionsAssertions(definitions: [String: Any]) {
        if let model = definitions["Deck"] as? [String: Any] {
            if let type = model["type"] as? String {
                XCTAssertTrue(type == "object", "model Deck: type is incorrect")
            } else {
                XCTFail("model Deck: type is missing")
            }

            if let properties = model["properties"] as? [String: Any] {
                if let cards = properties["cards"] as? [String: Any] {
                    if let items = cards["items"] as? [String : Any], let ref = items["$ref"] as? String {
                        XCTAssertTrue(ref == "#/definitions/Deck.Card", "model Deck: cards property has incorrect type")
                    } else {
                        XCTFail("model Deck: property cards has missing type")
                    }
                } else {
                    XCTFail("model Deck: property cards is missing")
                }
            } else {
                XCTFail("model Deck: properties is missing")
            }
        } else {
            return XCTFail("Deck model is missing")
        }
    }

    func deckCardDefinitionsAssertions(definitions: [String: Any]) {
        if let model = definitions["Deck.Card"] as? [String: Any] {
            if let type = model["type"] as? String {
                XCTAssertTrue(type == "object", "model Deck.Card: type is incorrect")
            } else {
                XCTFail("model Deck.Card: type is missing")
            }

            if let properties = model["properties"] as? [String: Any] {
                if let suit = properties["suit"] as? [String: Any] {
                    if let ref = suit["$ref"] as? String {
                        XCTAssertTrue(ref == "#/definitions/Deck.Card.Suit", "model Deck.Card: suit property has incorrect type")
                    } else {
                        XCTFail("model Deck.Card: property suit has missing type")
                    }
                } else {
                    XCTFail("model Deck.Card: property suit is missing")
                }
                if let rank = properties["rank"] as? [String: Any] {
                    if let ref = rank["$ref"] as? String {
                        XCTAssertTrue(ref == "#/definitions/Deck.Card.Rank", "model Deck.Card: suit property has incorrect type")
                    } else {
                        XCTFail("model Deck.Card: property rank has missing type")
                    }
                } else {
                    XCTFail("model Deck.Card: property rank is missing")
                }
            } else {
                XCTFail("model Deck.Card: properties is missing")
            }
        } else {
            return XCTFail("Deck.Card model is missing")
        }
    }

    // Check that a type that only appears as an input type is defined
    func bananaDefinitionsAssertions(definitions: [String: Any]) {
        guard let model = definitions["Banana"] as? [String: Any] else {
            return XCTFail("Banana model is missing")
        }
        if let type = model["type"] as? String {
            XCTAssertTrue(type == "object", "model Banana: type is incorrect")
        } else {
            XCTFail("Model Banana: type is missing")
        }

        if let required = model["required"] as? [String] {
            XCTAssertTrue(required.contains("name"), "model Banana: required does not contain 'name'")
            XCTAssertTrue(required.contains("colour"), "model Banana: required does not contain 'colour'")
            XCTAssertEqual(required.count, 2, "model Apple: required.count is incorrect")
        } else {
            XCTFail("model Banana: required is missing")
        }
    }

    // Check that a nested type is correctly referenced and defined in the swagger
    func nestedModelDefinitionsAssertions(definitions: [String: Any]) {
        guard let banana = definitions["Banana"] as? [String: Any] else {
            return XCTFail("Banana model is missing")
        }
        if let properties = banana["properties"] as? [String: Any] {
            if let colour = properties["colour"] as? [String: Any] {
                if let typeRef = colour["$ref"] as? String {
                    XCTAssertTrue(typeRef == "#/definitions/FruitColour", "model Banana: property 'colour' has incorrect type reference")
                } else {
                    XCTFail("model Banana: property 'colour' has missing type reference")
                }
            } else {
                XCTFail("model Banana: property 'colour' is missing")
            }
        }
        guard let fruitColour = definitions["FruitColour"] as? [String: Any] else {
            return XCTFail("FruitColour model is missing")
        }
        if let required = fruitColour["required"] as? [String] {
            XCTAssertTrue(required.contains("colour"), "model FruitColour: required does not contain 'colour'")
            XCTAssertEqual(required.count, 1, "model FruitColour: required.count is incorrect")
        } else {
            XCTFail("model FruitColour: required is missing")
        }
    }

    func personDefinitionsAssertions(definitions: [String: Any]) {
        guard let person = definitions["Person"] as? [String: Any] else {
            return XCTFail("Person  model is missing")
        }

        if let name = person["name"] as? String {
            XCTAssertTrue(name == "string", "model Person: name is incorrect")
        } else {
            XCTFail("model Person: name is missing")
        }
        if let age = person["age"] as? String {
            XCTAssertTrue(age == "integer", "model Person: age is incorrect")
        } else {
            XCTFail("model Person: age is missing")
        }

        if let required = person["required"] as? [String] {
            XCTAssertTrue(required.contains("name"), "model Person: required does not contain 'name'")
            XCTAssertTrue(required.contains("age"), "model Person: required does not contain 'age'")
            XCTAssertEqual(required.count, 2, "model Person: required.count is incorrect")
        } else {
            XCTFail("model Person: required is missing")
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
                            XCTAssertTrue(description == SwaggerDocument.responseDescription(for: HTTPStatusCode(rawValue: 200)), "path /me/puts/{id}: put responses 200 description is incorrect")
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
                    // There should be _at least_ two responses:
                    // A successful (OK) response and an error
                    // (unprocessableEntity). Other errors may
                    // also be enumerated.
                    XCTAssertGreaterThan(responses.count, 1, "path /me/puts/{id}: put responses.count is incorrect")
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

    //
    // Helper for converting the router's swaggerJSON string to JSON dictionary
    //
    private func getSwaggerDictionary(for theRouter: Router? = nil) -> [String: Any]? {
        let router = theRouter ?? self.router
        guard let jsonString = router.swaggerJSON else {
            XCTFail("Router.swaggerJSON unexpectedly nil")
            return nil
        }
        guard let data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            XCTFail("Unable to convert swaggerJSON to data")
            return nil
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            XCTFail("Unable to deserialize swaggerJSON data")
            return nil
        }
        guard let dict = json as? [String: Any] else {
            XCTFail("Deserialized JSON was not a [String: Any] dictionary")
            return nil
        }
        return dict
    }

    //
    // Test that our swagger document contains the swagger version.
    //
    func testSwaggerVersion() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        if let swagger = dict["swagger"] as? String {
            XCTAssertTrue(swagger == "2.0", "swagger version is incorrect")
        } else {
            XCTFail("swagger version is missing")
        }
    }

    //
    // Test that our swagger document defines the basePath.
    //
    func testBasePath() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        if let basepath = dict["basePath"] as? String {
            XCTAssertTrue(basepath == "/", "basePath is incorrect")
        } else {
            XCTFail("basePath is missing")
        }
    }

    //
    // Test that our swagger document defines the info section.
    //
    func testInfo() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
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

    //
    // Test that our swagger document defines the custom info section.
    //
    func testCustomInfo() {
        let customTitle = "My Project"
        let customDescription = "My project generated by Kitura"
        let customVersion = "0.0.1"
        let localRouter = Router(apiDocument: SwaggerDocument(title: customTitle,
                                                description: customDescription,
                                                version: customVersion))
        guard let dict = getSwaggerDictionary(for: localRouter) else {
            return XCTFail("Unable to get swagger dictionary")
        }
        if let info = dict["info"] as? [String: String] {
            if let title = info["title"] {
                XCTAssertTrue(title == customTitle, "title is incorrect")
            } else {
                XCTFail("title is missing")
            }

            if let desc = info["description"] {
                XCTAssertTrue(desc == customDescription, "description is incorrect")
            } else {
                XCTFail("description is missing")
            }

            if let version = info["version"] {
                XCTAssertTrue(version == customVersion, "version is incorrect")
            } else {
                XCTFail("version is missing")
            }
        }
    }

    //
    // Test that our swagger document contains the expected paths
    // and that the paths' structure is as expected.
    //
    func testSwaggerContent() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        if let paths = dict["paths"] as? [String: Any] {
            pathAssertions(paths: paths)
            pathContentAssertions1(paths: paths)
            pathContentAssertions2(paths: paths)
            pathContentAssertions3(paths: paths)
            pathContentAssertions4(paths: paths)
        } else {
            XCTFail("paths is missing")
        }
    }

    //
    // Test that query parameters are correctly represented.
    //
    func testSwaggerQueryParams() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
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
    }

    //
    // Test that our swagger document contains the expected model definitions.
    //
    func testSwaggerDefinitions() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        if let definitions = dict["definitions"] as? [String: Any] {
            appleDefinitionsAssertions(definitions: definitions)
            pearDefinitionsAssertions(definitions: definitions)
            uglifruitDefinitionsAssertions(definitions: definitions)
            deckDefinitionsAssertions(definitions: definitions)
            deckCardDefinitionsAssertions(definitions: definitions)
        } else {
            XCTFail("definitions section is missing")
        }
    }

    //
    // Test that array return types are correctly represented.
    //
    func testArrayReturnTypes() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        guard let paths = dict["paths"] as? [String: Any] else {
            return XCTFail("Paths section is missing")
        }
        let arrayPath = "/me/getArray"
        guard let path = paths[arrayPath] as? [String: Any] else {
            return XCTFail("Path \(arrayPath) is missing")
        }
        guard let get = path["get"] as? [String: Any] else {
            return XCTFail("Path \(arrayPath): GET method missing")
        }
        guard let responses = get["responses"] as? [String: Any] else {
            return XCTFail("Path \(arrayPath): GET responses missing")
        }
        guard let okResponse = responses["200"] as? [String: Any] else {
            return XCTFail("Path \(arrayPath): GET response 200 missing")
        }
        guard let okSchema = okResponse["schema"] as? [String: Any] else {
            return XCTFail("Path \(arrayPath): GET schema missing")
        }
        guard let okReturnType = okSchema["type"] as? String else {
            return XCTFail("Path \(arrayPath): GET schema type missing")
        }
        XCTAssertEqual(okReturnType, "array", "Return type for GET on path \(arrayPath) should be 'array', but was \(okReturnType)")
        guard let returnItems = okSchema["items"] as? [String: Any] else {
            return XCTFail("Path \(arrayPath): GET schema items missing")
        }
        guard let ref = returnItems["$ref"] as? String else {
            return XCTFail("Path \(arrayPath): GET schema items did not contain '$ref'")
        }
        XCTAssertEqual(ref, "#/definitions/Apple")
    }

    //
    // Test that tuple array return types are correctly represented, such as from a
    // GET (plural) where the identity of the entity being returned is external to
    // the entity.
    // We represent these tuples in Swagger as a dictionary with a string to model
    // mapping. This is okay, because Identifier must be expressable as a String.
    //
    func testTupleArrayReturnTypes() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        guard let paths = dict["paths"] as? [String: Any] else {
            return XCTFail("Paths section is missing")
        }
        let tupleArrayPath = "/me/getTupleArray"
        guard let path = paths[tupleArrayPath] as? [String: Any] else {
            return XCTFail("Path \(tupleArrayPath) is missing")
        }
        guard let get = path["get"] as? [String: Any] else {
            return XCTFail("Path \(tupleArrayPath): GET method missing")
        }
        guard let responses = get["responses"] as? [String: Any] else {
            return XCTFail("Path \(tupleArrayPath): GET responses missing")
        }
        guard let okResponse = responses["200"] as? [String: Any] else {
            return XCTFail("Path \(tupleArrayPath): GET response 200 missing")
        }
        guard let okSchema = okResponse["schema"] as? [String: Any] else {
            return XCTFail("Path \(tupleArrayPath): GET schema missing")
        }
        guard let okReturnType = okSchema["type"] as? String else {
            return XCTFail("Path \(tupleArrayPath): GET schema type missing")
        }
        XCTAssertEqual(okReturnType, "array", "Return type for GET on path \(tupleArrayPath) should be 'array', but was \(okReturnType)")
        guard let returnItems = okSchema["items"] as? [String: Any] else {
            return XCTFail("Path \(tupleArrayPath): GET schema items missing")
        }
        guard let returnType = returnItems["type"] as? String else {
            return XCTFail("Path \(tupleArrayPath): GET schema type missing")
        }
        // Dictionaries are represented as an 'object' type containing 'additionalProperties'.
        XCTAssertEqual(returnType, "object", "Array type should be 'object', but was \(returnType)")
        guard let additionalProperties = returnItems["additionalProperties"] as? [String: String] else {
            return XCTFail("Path \(tupleArrayPath): GET schema additionalProperties missing")
        }
        guard let ref = additionalProperties["$ref"] else {
            return XCTFail("Path \(tupleArrayPath): GET schema $ref missing")
        }
        XCTAssertEqual(ref, "#/definitions/Apple", "schema ref type for GET on path \(tupleArrayPath) should be '#/definitions/Apple', but was \(ref)")
    }

    //
    // Test that a POST that returns an Identifier is correctly defined as having
    // a single Codable input type, and returns a single Codable output type plus
    // a Location header containing the Identifier.
    //
    func testPostReturningId() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        guard let paths = dict["paths"] as? [String: Any] else {
            return XCTFail("Paths section is missing")
        }
        let postSinglePath = "/me/postid"
        guard let path = paths[postSinglePath] as? [String: Any] else {
            return XCTFail("Path \(postSinglePath) is missing")
        }
        guard let get = path["post"] as? [String: Any] else {
            return XCTFail("Path \(postSinglePath): POST method missing")
        }
        guard let responses = get["responses"] as? [String: Any] else {
            return XCTFail("Path \(postSinglePath): POST responses missing")
        }
        guard let createdResponse = responses["201"] as? [String: Any] else {
            return XCTFail("Path \(postSinglePath): POST response 201 missing")
        }
        guard let createdHeaders = createdResponse["headers"] as? [String: Any] else {
            return XCTFail("Path \(postSinglePath): POST headers missing")
        }
        guard let createdLocation = createdHeaders["Location"] as? [String: Any] else {
            return XCTFail("Path \(postSinglePath): POST Location header missing")
        }
        guard let createdDescription = createdLocation["description"] as? String else {
            return XCTFail("Path \(postSinglePath): POST Location header description missing")
        }
        guard let createdType = createdLocation["type"] as? String else {
            return XCTFail("Path \(postSinglePath): POST Location header type missing")
        }
        XCTAssertEqual(createdDescription, "Identity of resource", "Location header description for POST on path \(postSinglePath) should be 'Identity of resource', but was \(createdDescription)")
        XCTAssertEqual(createdType, "integer", "type of Location id for POST on path \(postSinglePath) should be 'integer', but was \(createdType)")
    }

    //
    // Test that input types that do not also appear as output types are
    // correctly modelled.
    //
    func testInputTypesModelled() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        guard let definitions = dict["definitions"] as? [String: Any] else {
            return XCTFail("Definitions section is missing")
        }
        bananaDefinitionsAssertions(definitions: definitions)
    }

    //
    // Test that types that do not appear directly as top-level input or output parameters,
    // but are referenced by such top-level types, are modelled in the swagger.
    //
    func testNestedTypesModelled() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        guard let definitions = dict["definitions"] as? [String: Any] else {
            return XCTFail("Definitions section is missing")
        }
        nestedModelDefinitionsAssertions(definitions: definitions)
    }

    //
    // Test that a type that encodes to a single value, whose type is a composite (complex)
    // type, is modelled and is described as the structure of its encoded type. In this
    // example, we expect SingleValueComplexType to be described with NestedType's structure.
    //
    func testSingleValueComplexType() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        guard let definitions = dict["definitions"] as? [String: Any] else {
            return XCTFail("Definitions section is missing")
        }
        // Check that SingleValueComplexType contains NestedType's structure
        guard let model = definitions["SingleValueComplexType"] as? [String: Any] else {
            return XCTFail("SingleValueComplexType model is missing")
        }
        if let type = model["type"] as? String {
            XCTAssertTrue(type == "object", "model SingleValueComplexType: type is incorrect")
        } else {
            XCTFail("Model SingleValueComplexType: type is missing")
        }

        if let required = model["required"] as? [String] {
            XCTAssertTrue(required.contains("apple"), "model SingleValueComplexType: required does not contain 'apple'")
            XCTAssertTrue(required.contains("banana"), "model SingleValueComplexType: required does not contain 'banana'")
            XCTAssertEqual(required.count, 2, "model SingleValueComplexType: required.count is incorrect")
        } else {
            XCTFail("model SingleValueComplexType: required is missing")
        }
        // Check that NestedType is not modelled
        XCTAssertNil(definitions["NestedType"], "NestedType should not be modelled")
    }


    //
    // Test that setting a custom Date encoding on the Router's JSON serializer is
    // reflected in the swagger definition. DateEncodingStrategy of .iso8601 and .formatted
    // should be represented as a 'string',
    //
    func testCustomDateEncoding() {
        /// Helper function to set date encoding.
        /// - Parameter router: The router to configure
        /// - Parameter encodingStrategy: The encoding to use for the Date type
        func configureDateEncoding(on router: Router, encodingStrategy: JSONEncoder.DateEncodingStrategy, decodingStrategy: JSONDecoder.DateDecodingStrategy) {
            router.encoders = [.json: {
                    let encoder = JSONEncoder()
                    if #available(OSX 10.12, *) {
                        encoder.dateEncodingStrategy = encodingStrategy
                    }
                    return encoder
                }]
            router.decoders = [.json: {
                    let decoder = JSONDecoder()
                    if #available(OSX 10.12, *) {
                        decoder.dateDecodingStrategy = decodingStrategy
                    }
                    return decoder
                }]
        }
        /// Router handler for getting a person by ID
        func getPersonHandler(id: Int, respondWith: (Person?, RequestError?) -> Void) {
            let person = Person(name: "Fred", birthday: Date(timeIntervalSince1970: 1))
            respondWith(person, nil)
        }
        /// Helper function for validating swagger representation of Person.birthday
        /// - Parameter router: The router to inspect
        /// - Parameter expectedEncoding: The type description we expect for Date
        /// - Paramter expectedFormat: The special format we expect for Date
        func personEncodingAssertions(for router: Router, expectedEncoding: String, expectedFormat: String? = nil) {
            guard let dict = getSwaggerDictionary(for: router) else {
                return XCTFail("Unable to get swagger dictionary")
            }
            guard let definitions = dict["definitions"] as? [String: Any] else {
                return XCTFail("Definitions section is missing")
            }
            guard let model = definitions["Person"] as? [String: Any] else {
                return XCTFail("Person model is missing")
            }
            if let type = model["type"] as? String {
                XCTAssertTrue(type == "object", "model Person: type is incorrect")
            } else {
                XCTFail("Model Person: type is missing")
            }

            guard let properties = model["properties"] as? [String: Any] else {
                return XCTFail("model Person: properties dictionary missing")
            }
            guard let birthday = properties["birthday"] as? [String: Any] else {
                return XCTFail("model Person: properties does not contain 'birthday'")
            }
            guard let birthdayType = birthday["type"] as? String else {
                return XCTFail("model Person: birthday does not contain 'type'")
            }
            XCTAssertEqual(birthdayType, expectedEncoding, "model Person: birthday expected to be encoded as \(expectedEncoding), but was \(birthdayType)")
            if let expectedFormat = expectedFormat {
                guard let birthdayFormat = birthday["format"] as? String else {
                    return XCTFail("model Person: birthday does not contain 'format'")
                }
                XCTAssertEqual(birthdayFormat, expectedFormat, "model Person: birthday expected to be encoded as \(expectedEncoding) with format \(expectedFormat), but was format \(birthdayFormat)")
            }
        }

        // Check that Date is described as 'string' when encoding with ISO8601 strategy
        if #available(OSX 10.12, *) {
            let customRouterIso8601 = Router()
            configureDateEncoding(on: customRouterIso8601, encodingStrategy: .iso8601, decodingStrategy: .iso8601)
            customRouterIso8601.get("/standardPerson", handler: getPersonHandler)
            personEncodingAssertions(for: customRouterIso8601, expectedEncoding: "string", expectedFormat: "date-time")
        }
        let customRouterRFC3339 = Router()
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        configureDateEncoding(on: customRouterRFC3339, encodingStrategy: .formatted(RFC3339DateFormatter), decodingStrategy: .formatted(RFC3339DateFormatter))
        customRouterRFC3339.get("/standardPerson", handler: getPersonHandler)
        personEncodingAssertions(for: customRouterRFC3339, expectedEncoding: "string", expectedFormat: "date-time")

        let customRouterRFC3339FullDate = Router()
        let RFC3339DateFormatterFullDate = DateFormatter()
        RFC3339DateFormatterFullDate.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatterFullDate.dateFormat = "yyyy-MM-dd"
        RFC3339DateFormatterFullDate.timeZone = TimeZone(secondsFromGMT: 0)
        configureDateEncoding(on: customRouterRFC3339FullDate, encodingStrategy: .formatted(RFC3339DateFormatterFullDate), decodingStrategy: .formatted(RFC3339DateFormatterFullDate))
        customRouterRFC3339FullDate.get("/standardPerson", handler: getPersonHandler)
        personEncodingAssertions(for: customRouterRFC3339FullDate, expectedEncoding: "string", expectedFormat: "date")

        // Check that Date is described as 'integer' when encoded as seconds since 1970
        let customRouterSince1970 = Router()
        configureDateEncoding(on: customRouterSince1970, encodingStrategy: .secondsSince1970, decodingStrategy: .secondsSince1970)
        customRouterSince1970.get("/standardPerson", handler: getPersonHandler)
        personEncodingAssertions(for: customRouterSince1970, expectedEncoding: "integer")

        // Check that Date is described as a 'number' when using the default (Double) encoding
        let standardRouter = Router()
        standardRouter.get("/standardPerson", handler: getPersonHandler)
        personEncodingAssertions(for: standardRouter, expectedEncoding: "number")
   }

    //
    // Test that a GET (singular) route returning an Array type is correctly
    // represented in swagger as an array of refs to the appropriate model.
    //
    func testGetSingularArray() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        // check return type of /getSingularArrayType/{id} is an array of Apple refs
        guard let paths = dict["paths"] as? [String: Any] else {
            return XCTFail("Paths section is missing")
        }
        let arrayPath = "/getSingularArrayType/{id}"
        guard let path = paths[arrayPath] as? [String: Any] else {
            return XCTFail("Path \(arrayPath) is missing")
        }
        // Route should have a 'get' method
        guard let get = path["get"] as? [String: Any] else {
            return XCTFail("Path \(arrayPath): GET method missing")
        }
        // method should define 'responses'
        guard let responses = get["responses"] as? [String: Any] else {
            return XCTFail("Path \(arrayPath): GET responses missing")
        }
        // responses should contain '200'
        guard let okResponse = responses["200"] as? [String: Any] else {
            return XCTFail("Path \(arrayPath): GET response 200 missing")
        }
        // 200 response should contain a schema
        guard let okSchema = okResponse["schema"] as? [String: Any] else {
            return XCTFail("Path \(arrayPath): GET schema missing")
        }
        // schema should contain a 'type'
        guard let okReturnType = okSchema["type"] as? String else {
            return XCTFail("Path \(arrayPath): GET schema type missing")
        }
        // schema type should be 'array'
        XCTAssertEqual(okReturnType, "array", "Return type for GET on path \(arrayPath) should be 'array', but was \(okReturnType)")
        // schema should contain 'items'
        guard let returnItems = okSchema["items"] as? [String: Any] else {
            return XCTFail("Path \(arrayPath): GET schema items missing")
        }
        // items should contain a 'ref'
        guard let ref = returnItems["$ref"] as? String else {
            return XCTFail("Path \(arrayPath): GET schema items $ref missing")
        }
        // ref should be the Apple model
        XCTAssertEqual(ref, "#/definitions/Apple", "schema ref type for GET on path \(arrayPath) should be '#/definitions/Apple', but was \(ref)")
    }

    //
    // Test that types that only appear within collections (Array or Dictionary
    // values) are defined in the swagger document.
    // The EmbeddedInCollection type is returned by a route, and defines an Array
    // of EmbeddedInArrayType, and a Dictionary of Int:EmbeddedInDictionaryType.
    // These types do not appear elsewhere in the API.
    //
    func testTypesEmbeddedInCollections() {
        guard let dict = getSwaggerDictionary() else {
            return XCTFail("Unable to get swagger dictionary")
        }
        guard let definitions = dict["definitions"] as? [String: Any] else {
            return XCTFail("Definitions section is missing")
        }
        // Check that the EmbeddedInArrayType model exists
        guard let inArrayModel = definitions["EmbeddedInArrayType"] as? [String: Any] else {
            return XCTFail("EmbeddedInArrayType model is missing")
        }
        if let type = inArrayModel["type"] as? String {
            XCTAssertTrue(type == "object", "model EmbeddedInArrayType: type is incorrect")
        } else {
            XCTFail("Model EmbeddedInArrayType: type is missing")
        }
        // Check that the EmbeddedInDictionaryType model exists
        guard let inDictModel = definitions["EmbeddedInDictionaryType"] as? [String: Any] else {
            return XCTFail("EmbeddedInDictionaryType model is missing")
        }
        if let type = inDictModel["type"] as? String {
            XCTAssertTrue(type == "object", "model EmbeddedInDictionaryType: type is incorrect")
        } else {
            XCTFail("Model EmbeddedInDictionaryType: type is missing")
        }
    }

}
