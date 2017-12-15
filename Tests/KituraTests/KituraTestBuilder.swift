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
import Kitura

@testable import KituraNet

import Foundation
import Dispatch

// This file defines a builder API on top of KituraTest as syntactic sugar
// for writing more concise tests.
//
// For example, from inside a subclass of KituraTest, you can write:
// func testSomething() {
//     buildServerTest(someRouter, timeout: 30)
//         .request("get", path: "/route")
//         .hasStatus(.OK)
//         .hasData(someCodable)
//         .run()
// }
// This will create a test server connected to someRouter, send a single
// GET request to "/route", and test the response HTTP status code is 200 (OK)
// and the response data can be decoded and equal to someCodable.

// These protocols prevent adding assertions before adding at least
// one request
protocol RequestTestBuilder {
    func request(_ method: String, path: String) -> AssertionTestBuilder
    func request<T: Encodable>(_ method: String, path: String, data: T) -> AssertionTestBuilder
    func run()
}

protocol AssertionTestBuilder: RequestTestBuilder {
    func has(callback: @escaping (ClientResponse) -> Void) -> Self
    func hasStatus(_ statusCode: HTTPStatusCode) -> Self
    func hasHeader(_ name: String, only expectedValue: String) -> Self
    func hasNoData() -> Self
    func hasData(_ expected: String) -> Self
    func hasData<T: Decodable & Equatable>(_ expected: [T]) -> Self
    func hasData<T: Decodable & Equatable>(_ expected: T) -> Self
}

// A builder object for constructing tests made up of one or more
// requests on which multiple assertions can be applied
class ServerTestBuilder: RequestTestBuilder, AssertionTestBuilder {
    // An object to keep track of a request and store up a list of
    // assertions to be applied when the request is complete
    private class Request {
        let test: KituraTest
        let invoker: (@escaping (ClientResponse?) -> Void) throws -> Void
        fileprivate var assertions: [(ClientResponse) -> Void] = []

        init(_ test: KituraTest, _ method: String, _ path: String) {
            self.test = test
            self.invoker = { callback in
                test.performRequest(method, path: path, callback: callback)
            }
        }

        init<T: Encodable>(_ test: KituraTest, _ method: String, _ path: String, _ data: T) {
            self.test = test
            self.invoker = { callback in
                let data = try JSONEncoder().encode(data)
                test.performRequest(method, path: path, callback: callback, requestModifier: { request in
                    request.headers["Content-Type"] = "application/json; charset=utf-8"
                    request.write(from: data)
                })
            }
        }
    }
    let test: KituraTest
    let router: ServerDelegate
    let sslOption: SSLOption
    let timeout: TimeInterval
    let line: Int
    private var requests: [Request] = []
    private var currentRequest: Request? { return requests.last }

    public init(test: KituraTest, router: ServerDelegate, sslOption: SSLOption, timeout: TimeInterval, line: Int) {
        self.test = test
        self.router = router
        self.sslOption = sslOption
        self.timeout = timeout
        self.line = line
    }

    public func request(_ method: String, path: String) -> AssertionTestBuilder {
        requests.append(Request(test, method, path))
        return self
    }

    public func request<T: Encodable>(_ method: String, path: String, data: T) -> AssertionTestBuilder {
        requests.append(Request(test, method, path, data))
        return self
    }

    public func has(callback: @escaping (ClientResponse) -> Void) -> Self {
        currentRequest?.assertions.append(callback)
        return self
    }

    public func hasStatus(_ statusCode: HTTPStatusCode) -> Self {
        return has { XCTAssertEqual($0.statusCode, statusCode) }
    }

    public func hasHeader(_ name: String, only expectedValue: String) -> Self {
        return has { response in
            guard let header = response.headers[name] else {
                XCTFail("Expected response header \(name) missing")
                return
            }
            guard header.count == 1, let actualValue = header.first else {
                XCTFail("Header \(name) does not contain expected number of values:\nexpected: 1\nactual: \(header.count)")
                return
            }
            XCTAssertEqual(actualValue, expectedValue, "Header \(name) does not contain expected value:\nexpected: \(expectedValue)\nactual: \(actualValue)")
        }
    }

    private func readDataOrFail(from response: ClientResponse, allowEmpty: Bool = false) -> (length: Int, data: Data)? {
        var data = Data()
        guard let length = try? response.readAllData(into: &data) else {
            XCTFail("Failed to read response data")
            return nil
        }
        guard allowEmpty || length > 0 else {
            XCTFail("Expected some data but got none")
            return nil
        }
        return (length, data)
    }

    public func hasNoData() -> Self {
        return has { response in
            guard let (length, _) = self.readDataOrFail(from: response, allowEmpty: true) else { return }
            XCTAssertEqual(length, 0, "Response data does not match expected length:\nexpected: 0\nactual: \(length)")
        }
    }

    public func hasData(_ expected: Data) -> Self {
        return has { response in
            guard let (_, data) = self.readDataOrFail(from: response) else { return }
            XCTAssertEqual(data, expected, "Response data does not match expected")
        }
    }

    public func hasData(_ expected: String) -> Self {
        return has { response in
            guard let (_, data) = self.readDataOrFail(from: response) else { return }
            guard let actual = String(data: data, encoding: .utf8) else {
                XCTFail("Failed to decode response data into UTF8 String")
                return
            }
            XCTAssertEqual(expected, actual, "Response data does not match expected value:\nexpected: \(expected)\nactual: \(actual)")
        }
    }

    public func hasData<T: Decodable & Equatable>(_ expected: [T]) -> Self {
        return has { response in
            guard let (_, data) = self.readDataOrFail(from: response) else { return }
            do {
                let actual = try JSONDecoder().decode([T].self, from: data)
                XCTAssertEqual(expected, actual, "Response data does not match expected value:\nexpected: \(expected)\nactual: \(actual)")
            } catch {
                XCTFail("Failed to decode response data into type \([T].self): \(error)")
            }
        }
    }

    public func hasData<T: Decodable & Equatable>(_ expected: T) -> Self {
        return has { response in
            guard let (_, data) = self.readDataOrFail(from: response) else { return }
            do {
                let actual = try JSONDecoder().decode(T.self, from: data)
                XCTAssertEqual(expected, actual, "Response data does not match expected value:\nexpected: \(expected)\nactual: \(actual)")
            } catch {
                XCTFail("Failed to decode response data into type \(T.self): \(error)")
            }
        }
    }

    public func run() {
        // Construct a list of async tasks that will perform each
        // request in turn and test their associated assertions
        let tasks = requests.map { request in
            return { (expectation: XCTestExpectation) in
                do {
                    try request.invoker() { response in
                        guard let response = response else {
                            XCTFail("Expected response object")
                            return
                        }
                        for assertion in request.assertions {
                            assertion(response)
                        }
                        expectation.fulfill()
                    }
                } catch {
                    XCTFail("Failed to build request: \(error)")
                    expectation.fulfill()
                }
            }
        }
        test.performServerTest(router, sslOption: sslOption, timeout: timeout, line: line, asyncTasks: tasks)
    }
}
