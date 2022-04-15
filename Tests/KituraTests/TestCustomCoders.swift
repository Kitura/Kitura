/**
 * Copyright IBM Corporation 2018
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
import KituraContracts

@testable import Kitura

final class TestCustomCoders: KituraTest, KituraTestSuite {
    static var allTests: [(String, (TestCustomCoders) -> () throws -> Void)] {
        return [
            ("testCustomCoder", testCustomCoder),
            ("testRawCustomCoder", testRawCustomCoder),
            ("testCustomQueryEncoder", testCustomQueryEncoder),
        ]
    }

    struct CodableDate: Codable, Equatable {
        let date: Date
        init(date: Date) {
            self.date = date
        }
        public static func == (lhs: CodableDate, rhs: CodableDate) -> Bool {
            return lhs.date == rhs.date
        }
    }
    
    let dateFormatter = DateFormatter()
    
    func testCustomCoder() {
        let jsonEncoder: () -> BodyEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            return encoder
        }
        let jsonDecoder: () -> BodyDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return decoder
        }
        let customRouter = Router()
        customRouter.encoders[.json] = jsonEncoder
        customRouter.decoders[.json] = jsonDecoder
        
        let date = Date(timeIntervalSince1970: 1519206456)
        let codableDate = CodableDate(date: date)
        print("codableDate \(codableDate)")
        customRouter.get("/customCoder") { (respondWith: (CodableDate?, RequestError?) -> Void) in
            print("GET on /customCoder")
            respondWith(codableDate, nil)
        }
        customRouter.post("/customCoder") { (inDate: CodableDate, respondWith: (CodableDate?, RequestError?) -> Void) in
            print("POST on /customCoder for date \(inDate)")
            XCTAssertEqual(inDate, codableDate)
            respondWith(codableDate, nil)
        }
        
        buildServerTest(customRouter, timeout: 30)
            .request("get", path: "/customCoder")
            .hasStatus(.OK)
            .hasContentType(withPrefix: "application/json")
            .hasData(codableDate, customDecoder: jsonDecoder)
            
            .request("post", path: "/customCoder", data: codableDate, headers: nil, encoder: jsonEncoder)
            .hasStatus(.created)
            .hasContentType(withPrefix: "application/json")
            .hasData(codableDate, customDecoder: jsonDecoder)
            
            .run()
    }
    
    func testRawCustomCoder() {
        // Set up router for this test
        let customRouter = Router()
        let jsonDecoder: () -> BodyDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return decoder
        }
        let jsonEncoder: () -> BodyEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            return encoder
        }
        customRouter.decoders[.json] = jsonDecoder
        customRouter.encoders[.json] = jsonEncoder
        let date = Date(timeIntervalSince1970: 1519206456)
        let codableDate = CodableDate(date: date)
        
        customRouter.get("/rawget") { _, response, next in
            let date = Date(timeIntervalSince1970: 1519206456)
            let codableDate = CodableDate(date: date)
            response.send(codableDate)
            next()
        }
        
        customRouter.post("/rawpost") { request, _, next in
            let decodedDate = try request.read(as: CodableDate.self)
            XCTAssertEqual(decodedDate, codableDate)
            next()
        }
        
        performServerTest(customRouter) { expectation in
            self.performRequest("get", path: "/rawget", callback: { response in
                if let response = response, let responseString = try? response.readString() {
                    XCTAssertEqual(responseString, "{\"date\":1519206456}")
                } else {
                    XCTFail("Unable to read response string")
                }
                expectation.fulfill()
            })
        }
        
        performServerTest(customRouter) { expectation in
            self.performRequest("post", path: "/rawpost", callback: { response in
                expectation.fulfill()
            })
        }
    }
    
    
    func testCustomQueryEncoder() {
        // Set up router for this test
        let customRouter = Router()
        customRouter.encoders[.urlEncoded] =  { return QueryEncoder() }
        
        customRouter.get("/rawget") { _, response, next in
            let date = Date(timeIntervalSince1970: 1519206456)
            let codableDate = CodableDate(date: date)
            response.send(codableDate)
            next()
        }
        
        customRouter.get("/sendjson") { _, response, next in
            let date = Date(timeIntervalSince1970: 1519206456)
            let codableDate = CodableDate(date: date)
            response.send(json: codableDate)
            next()
        }
        
        performServerTest(customRouter) { expectation in
            self.performRequest("get", path: "/rawget", callback: { response in
                if let response = response,
                    let unwrappedString = (try? response.readString()).flatMap({ $0 })
                {
                    // Drop first 6 characters from response String to remove "&date=" and just leave the date String.
                    let responseDate = self.dateFormatter.date(from: String((unwrappedString.dropFirst(6))))
                    let expectedDate = self.dateFormatter.date(from: "2018-02-21T09:47:36%2B0000")
                    XCTAssertEqual(responseDate, expectedDate)
                } else {
                    XCTFail("Unable to read response string")
                }
                expectation.fulfill()
            }, headers: ["Accept": "application/x-www-form-urlencoded"])
        }
        
        performServerTest(customRouter) { expectation in
            self.performRequest("get", path: "/rawget", callback: { response in
                if let response = response, let responseString = try? response.readString() {
                    XCTAssertEqual(responseString, "{\"date\":540899256}")
                } else {
                    XCTFail("Unable to read response string")
                }
                expectation.fulfill()
            })
        }
        
        customRouter.defaultResponseMediaType = .urlEncoded

        performServerTest(customRouter) { expectation in
            self.performRequest("get", path: "/rawget", callback: { response in
                if let response = response,
                    let unwrappedString = (try? response.readString()).flatMap({ $0 })
                {
                    // Drop first 6 characters from response String to remove "&date=" and just leave the date String.
                    let responseDate = self.dateFormatter.date(from: String((unwrappedString.dropFirst(6))))
                    let expectedDate = self.dateFormatter.date(from: "2018-02-21T09:47:36%2B0000")
                    XCTAssertEqual(responseDate, expectedDate)
                } else {
                    XCTFail("Unable to read response string")
                }
                expectation.fulfill()
            })
        }
        
        performServerTest(customRouter) { expectation in
            self.performRequest("get", path: "/sendjson", callback: { response in
                if let response = response, let responseString = try? response.readString() {
                    XCTAssertEqual(responseString, "{\"date\":540899256}")
                } else {
                    XCTFail("Unable to read response string")
                }
                expectation.fulfill()
            })
        }

        let jsonEncoder: () -> BodyEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            return encoder
        }
        customRouter.encoders[.json] = jsonEncoder
        
        performServerTest(customRouter) { expectation in
            self.performRequest("get", path: "/sendjson", callback: { response in
                if let response = response {
                    var responseData = Data()
                    _ = try? response.readAllData(into: &responseData)

                    struct DateObject: Codable {
                        let date: TimeInterval
                    }

                    let responseJson = try! JSONDecoder().decode(DateObject.self, from: responseData)
                    XCTAssertEqual(responseJson.date, 1519206456)
                } else {
                    XCTFail("Unable to read response string")
                }
                expectation.fulfill()
            })
        }
    }
}
