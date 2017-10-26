///**
// * Copyright IBM Corporation 2017
// *
// * Licensed under the Apache License, Version 2.0 (the "License");
// * you may not use this file except in compliance with the License.
// * You may obtain a copy of the License at
// *
// * http://www.apache.org/licenses/LICENSE-2.0
// *
// * Unless required by applicable law or agreed to in writing, software
// * distributed under the License is distributed on an "AS IS" BASIS,
// * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// * See the License for the specific language governing permissions and
// * limitations under the License.
// **/
//
//import XCTest
//import Foundation
//import KituraContracts
//
//@testable import Kitura
//@testable import KituraNet
//
//var employeeStore: [Int: Employee] = [:]
//
//struct Employee: Codable, Equatable {
//    public let serial: Int
//    public let name: String
//    public init(serial: Int, name: String) {
//        self.serial = serial
//        self.name = name
//    }
//
//    static func ==(lhs: Employee, rhs: Employee) -> Bool {
//        return (lhs.serial == rhs.serial) && (lhs.name == rhs.name)
//    }
//}
//
//extension Employee: Persistable {
//
//    // Create
//    static func create(model: Employee, respondWith: @escaping (Employee?, RequestError?) -> Void) {
//        employeeStore[model.serial] = model
//        respondWith(model, nil)
//    }
//
//    // Read ALL
//    static func read(respondWith: @escaping ([Employee]?, RequestError?) -> Void) {
//        let employees: [Employee] = employeeStore.map { $0.value }
//        respondWith(employees, nil)
//    }
//
//    // Read single
//    static func read(id: Int, respondWith: @escaping (Employee?, RequestError?) -> Void) {
//        guard let employee = employeeStore[id] else {
//            respondWith(nil, .notFound)
//            return
//        }
//        respondWith(employee, nil)
//    }
//
//    // Update
//    static func update(id: Int, model: Employee, respondWith: @escaping (Employee?, RequestError?) -> Void) {
//        guard let _ = employeeStore[id] else {
//            respondWith(nil, .notFound)
//            return
//        }
//        employeeStore[id] = model
//        respondWith(model, nil)
//    }
//
//    // Delete ALL
//    static func delete(respondWith: @escaping (RequestError?) -> Void) {
//        employeeStore.removeAll()
//        respondWith(nil)
//    }
//
//    // Delete single
//    static func delete(id: Int, respondWith: @escaping (RequestError?) -> Void) {
//        guard let _ = employeeStore.removeValue(forKey: id) else {
//            respondWith(.notFound)
//            return
//        }
//        respondWith(nil)
//    }
//}
//
//class TestCRUDTypeRouter: KituraTest {
//    static var allTests: [(String, (TestCRUDTypeRouter) -> () throws -> Void)] {
//        return [
//            ("testCreate", testCreate),
//            ("testReadAll", testReadAll),
//            ("testReadSingle", testReadSingle),
//            ("testUpdate", testUpdate),
//            ("testDeleteAll", testDeleteAll),
//            ("testDeleteSingle", testDeleteSingle),
//        ]
//    }
//
//    var router = Router()
//
//    override func setUp() {
//        router = Router()
//        router.register(api: Employee.self)
//        employeeStore = [1: Employee(serial: 1, name: "Mike"), 2: Employee(serial: 2, name: "Ricardo")]
//    }
//
//    func testCreate() {
//        let expectedEmployee = Employee(serial: 3, name: "David")
//        guard let employeeData = try? JSONEncoder().encode(expectedEmployee) else {
//            XCTFail("Could not generate employee data from object!")
//            return
//        }
//        performServerTest(router, timeout: 30) { expectation in
//            self.performRequest("post", path: "/employees", callback: { response in
//                guard let response = response else {
//                    XCTFail("ERROR!!! ClientRequest response object was nil")
//                    expectation.fulfill()
//                    return
//                }
//
//                XCTAssertEqual(response.statusCode, HTTPStatusCode.created, "HTTP Status code was \(String(describing: response.statusCode))")
//                var data = Data()
//                guard let length = try? response.readAllData(into: &data) else {
//                    XCTFail("Error reading response length!")
//                    expectation.fulfill()
//                    return
//                }
//
//                XCTAssert(length > 0, "Expected some bytes, received \(String(describing: length)) bytes.")
//                guard let employee = try? JSONDecoder().decode(Employee.self, from: data) else {
//                    XCTFail("Could not decode response! Expected response decodable to User, but got \(String(describing: String(data: data, encoding: .utf8)))")
//                    expectation.fulfill()
//                    return
//                }
//
//                // Validate the data we got back from the server
//                XCTAssertEqual(employee.name, expectedEmployee.name)
//                XCTAssertEqual(employee.serial, expectedEmployee.serial)
//
//                expectation.fulfill()
//            }, requestModifier: { request in
//                request.headers["Content-Type"] = "application/json"
//                request.write(from: employeeData)
//            })
//        }
//    }
//
//    func testReadAll() {
//        performServerTest(router, timeout: 30) { expectation in
//            let expectedEmployees = employeeStore.map({ $0.value }) // TODO: Write these out explicitly?
//
//            self.performRequest("get", path: "/employees", callback: { response in
//                guard let response = response else {
//                    XCTFail("ERROR!!! ClientRequest response object was nil")
//                    expectation.fulfill()
//                    return
//                }
//
//                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response.statusCode))")
//                var data = Data()
//                guard let length = try? response.readAllData(into: &data) else {
//                    XCTFail("Error reading response length!")
//                    expectation.fulfill()
//                    return
//                }
//
//                XCTAssert(length > 0, "Expected some bytes, received \(String(describing: length)) bytes.")
//                guard let employees = try? JSONDecoder().decode([Employee].self, from: data) else {
//                    XCTFail("Could not decode response! Expected response decodable to array of Employees, but got \(String(describing: String(data: data, encoding: .utf8)))")
//                    expectation.fulfill()
//                    return
//                }
//
//                // Validate the data we got back from the server
//                for (index, employee) in employees.enumerated() {
//                    XCTAssertEqual(employee.serial, expectedEmployees[index].serial)
//                    XCTAssertEqual(employee.name, expectedEmployees[index].name)
//                }
//
//                expectation.fulfill()
//            })
//        }
//    }
//
//    func testReadSingle() {
//        performServerTest(router, timeout: 30) { expectation in
//            guard let expectedEmployee = employeeStore[1] else {
//                XCTFail("ERROR!!! Couldn't find employee with id 1")
//                expectation.fulfill()
//                return
//            }
//
//            self.performRequest("get", path: "/employees/1", callback: { response in
//                guard let response = response else {
//                    XCTFail("ERROR!!! ClientRequest response object was nil")
//                    expectation.fulfill()
//                    return
//                }
//
//                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response.statusCode))")
//                var data = Data()
//                guard let length = try? response.readAllData(into: &data) else {
//                    XCTFail("Error reading response length!")
//                    expectation.fulfill()
//                    return
//                }
//
//                XCTAssert(length > 0, "Expected some bytes, received \(String(describing: length)) bytes.")
//                guard let employee = try? JSONDecoder().decode(Employee.self, from: data) else {
//                    XCTFail("Could not decode response! Expected response decodable an Employee, but got \(String(describing: String(data: data, encoding: .utf8)))")
//                    expectation.fulfill()
//                    return
//                }
//
//                // Validate the data we got back from the server
//                XCTAssertEqual(employee.serial, expectedEmployee.serial)
//                XCTAssertEqual(employee.name, expectedEmployee.name)
//
//                expectation.fulfill()
//            })
//        }
//    }
//
//    func testUpdate() {
//        performServerTest(router, timeout: 30) { expectation in
//            // Let's create a Employee instance
//            let expectedEmployee = Employee(serial: 1, name: "Kye")
//            // Create JSON representation of User instance
//            guard let employeeData = try? JSONEncoder().encode(expectedEmployee) else {
//                XCTFail("Could not generate employee data from string!")
//                expectation.fulfill()
//                return
//            }
//
//            self.performRequest("put", path: "/employees/1", callback: { response in
//                guard let response = response else {
//                    XCTFail("ERROR!!! ClientRequest response object was nil")
//                    expectation.fulfill()
//                    return
//                }
//
//                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response.statusCode))")
//                var data = Data()
//                guard let length = try? response.readAllData(into: &data) else {
//                    XCTFail("Error reading response length!")
//                    expectation.fulfill()
//                    return
//                }
//
//                XCTAssert(length > 0, "Expected some bytes, received \(String(describing: length)) bytes.")
//                guard let employee = try? JSONDecoder().decode(Employee.self, from: data) else {
//                    XCTFail("Could not decode response! Expected response decodable to User, but got \(String(describing: String(data: data, encoding: .utf8)))")
//                    expectation.fulfill()
//                    return
//                }
//
//                // Validate the data we got back from the server
//                XCTAssertEqual(employee.name, expectedEmployee.name)
//                XCTAssertEqual(employee.serial, expectedEmployee.serial)
//
//                expectation.fulfill()
//            }, requestModifier: { request in
//                request.headers["Content-Type"] = "application/json"
//                request.write(from: employeeData)
//            })
//        }
//    }
//
//    func testDeleteAll() {
//        performServerTest(router, timeout: 30) { expectation in
//
//            self.performRequest("delete", path: "/employees", callback: { response in
//                guard let response = response else {
//                    XCTFail("ERROR!!! ClientRequest response object was nil")
//                    return
//                }
//
//                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response.statusCode))")
//                var data = Data()
//                guard let length = try? response.readAllData(into: &data) else {
//                    XCTFail("Error reading response length!")
//                    return
//                }
//
//                XCTAssert(length == 0, "Expected zero bytes, received \(String(describing: length)) bytes.")
//                expectation.fulfill()
//            })
//        }
//    }
//
//    func testDeleteSingle() {
//        performServerTest(router, timeout: 30) { expectation in
//            self.performRequest("delete", path: "/employees/1", callback: { response in
//                guard let response = response else {
//                    XCTFail("ERROR!!! ClientRequest response object was nil")
//                    return
//                }
//                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response.statusCode))")
//                var data = Data()
//                guard let length = try? response.readAllData(into: &data) else {
//                    XCTFail("Error reading response length!")
//                    return
//                }
//                XCTAssert(length == 0, "Expected zero bytes, received \(String(describing: length)) bytes.")
//                expectation.fulfill()
//            })
//        }
//    }
//
//}
//
