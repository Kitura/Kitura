/*
 * Copyright IBM Corporation 2017
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
 */

import XCTest

class TestDecodingErrorExtension: XCTestCase {
    
    static var allTests: [(String, (TestDecodingErrorExtension) -> () throws -> Void)] {
        return [
            ("testMalformedJson", testMalformedJson),
            ("testMissingRequiredKey", testMissingRequiredKey),
            ("testWrongType", testWrongType),
            ("testMissingValue", testMissingValue),
            
        ]
    }
    
    func testMalformedJson() {
        
        let testJSON = """
{
"name": "woof", THISSHOULDNOTBEHERE
"value": 3,
"subCodable": {
  "subName": "subWoof",
  "subSubTest": {
    "subSubSubInt" : 4
    }
  }
}
"""
        do {
            _ = try JSONDecoder().decode(TestCodable.self, from: testJSON.data(using: .utf8)!)
            XCTFail("We should have had a decoding error, but had no error.")
        } catch  {
            if let decodingError = error as? DecodingError {
                XCTAssert(decodingError.humanReadableDescription.contains("The JSON appears to be malformed."), "DecodingError.humanReadableDescription not what we expected.")
            } else {
                // Linux Swift does not throw a DecodingError for malformed JSON, an Error "The operation could not be completed"
                #if !os(Linux)
                XCTFail("We should have had a DecodingError, but we got \(error) instead.")
                #endif
            }
        }
    }
    func testMissingRequiredKey() {
        
        let testJSON = """
{
"name": "woof",
"value": 3,
"subCodable": {
  "subSubTest": {
    "subSubSubInt" : 4
    }
  }
}
"""
        do {
            _ = try JSONDecoder().decode(TestCodable.self, from: testJSON.data(using: .utf8)!)
            XCTFail("We should have had a decoding error.")
        } catch  {
            if let decodingError = error as? DecodingError {
                XCTAssert(decodingError.humanReadableDescription == "The required key 'subCodable.subName' not found.", "DecodingError.humanReadableDescription not what we expected.")
            } else {
                XCTFail("We should have had a decoding error.")
            }
        }
    }
    func testWrongType() {
        let testJSON = """
{
"name": "woof",
"value": "not a number",
"subCodable": {
  "subSubTest": {
    "subSubSubInt" : 4
    }
  }
}
"""
        do {
            _ = try JSONDecoder().decode(TestCodable.self, from: testJSON.data(using: .utf8)!)
            XCTFail("We should have had a decoding error.")
        } catch  {
            if let decodingError = error as? DecodingError {
                XCTAssert(decodingError.humanReadableDescription.contains("Key 'value' has the wrong type."), "DecodingError.humanReadableDescription not what we expected.")
            } else {
                XCTFail("We should have had a decoding error.")
            }
        }
    }
    
    func testMissingValue() {
        let testJSON = """
{
"name": null,
"value": 3,
"subCodable": {
  "subName": "subWoof",
  "subSubTest": {
    "subSubSubInt" : 4
    }
  }
}
"""
        do {
            _ = try JSONDecoder().decode(TestCodable.self, from: testJSON.data(using: .utf8)!)
            XCTFail("We should have had a decoding error.")
        } catch  {
            if let decodingError = error as? DecodingError {
                XCTAssert(decodingError.humanReadableDescription.contains("Key \'name\' has the wrong type or was not found"), "DecodingError.humanReadableDescription not what we expected.")
            } else {
                XCTFail("We should have had a decoding error.")
            }
        }
        
    }
    
    
    struct TestSubSub: Codable {
        let subSubSubInt: Int
    }
    
    struct TestSubCodable: Codable {
        let subName: String
        let subSubTest: TestSubSub
    }
    struct TestCodable: Codable {
        let name: String
        let value: Int
        let optionalCaption: String?
        let subCodable: TestSubCodable
    }
    
    
}
