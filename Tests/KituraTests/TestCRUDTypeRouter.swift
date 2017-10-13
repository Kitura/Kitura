/**
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
 **/

import XCTest
import Foundation
#if swift(>=4.0)
    import SafetyContracts
#endif

@testable import Kitura
@testable import KituraNet

#if swift(>=4.0)
var employeeStore: [Int: Employee] = [:]
struct Employee: Codable {
    public let serial: Int
    public let name: String
    public init(serial: Int, name: String) {
        self.serial = serial
        self.name = name
    }
    
}

    extension Employee: Persistable, Equatable {
        
        static func ==(lhs: Employee, rhs: Employee) -> Bool {
            return (lhs.serial == rhs.serial) && (lhs.name == rhs.name)
        }
        
        // Create
        static func create(model: Employee, respondWith: @escaping (Employee?, Swift.Error?) -> Void) {
            employeeStore[model.serial] = model
            respondWith(model, nil)
        }

        static func read(respondWith: @escaping ([Employee]?, Swift.Error?) -> Void) {
            let employees: [Employee] = employeeStore.map { $0.1 }
            respondWith(employees, nil)
        }

        static func read(id: Int, respondWith: @escaping (Employee?, Swift.Error?) -> Void) {
            guard let employee = employeeStore[id] else {
                respondWith(nil, nil) //TODO: Respond with some error!
                return
            }
            respondWith(employee, nil)
        }

        static func update(id: Int, model: Employee, respondWith: @escaping (Employee?, Swift.Error?) -> Void) {
            employeeStore[id] = model
            respondWith(model, nil)
        }

        static func delete(respondWith: @escaping (Swift.Error?) -> Void) {
            employeeStore.removeAll()
        }
        
        static func delete(id: Int, respondWith: @escaping (Swift.Error?) -> Void) {
            employeeStore.removeValue(forKey: id)
            respondWith(nil)
        }
}

class TestCRUDTypeRouter: KituraTest {
    static var allTests: [(String, (TestCRUDTypeRouter) -> () throws -> Void)] {
        return [
            ("testCreate", testCreate),
            ("testReadAll", testReadAll),
            ("testReadSingle", testReadSingle),
            ("testUpdate", testUpdate),
            ("testDeleteAll", testDeleteAll),
            ("testDeleteSingle", testDeleteSingle),
        ]
    }
    
    var router = Router()
    
    override func setUp() {
        router = Router()
        router.register(api: Employee.self)
        employeeStore = [1: Employee(serial: 2345, name: "Mike"), 2: Employee(serial: 3456, name: "Ricardo")]
    }
    
    func testCreate() {
        let employee = Employee(serial: 1234, name: "David")
        Employee.create(model: employee, respondWith: { result, error in
            if let error = error {
                XCTFail("ERROR!!! \(error)")
            }
            guard let result = result else {
                XCTFail("ERROR!!! Employee wasn't created?")
                return
            }
            XCTAssertEqual(result.name, "David")
            XCTAssertEqual(result.serial, 1234)
        })
        
        //Do we really need to do this? Needs review.
        performServerTest(router, timeout: 30) { expectation in
            // Let's create a User instance
            guard let expectedEmployee = employeeStore[1234] else {
                XCTFail("ERROR!!! Employee with serial number 1234 doesn't exist")
                return
            }
            // Create JSON representation of User instance
            guard let employeeData = try? JSONEncoder().encode(expectedEmployee) else {
                XCTFail("Could not generate employee data from string!")
                return
            }

            self.performRequest("post", path: "/employees", callback: { response in
                guard let response = response else {
                    XCTFail("ERROR!!! ClientRequest response object was nil")
                    return
                }

                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response.statusCode))")
                var data = Data()
                guard let length = try? response.readAllData(into: &data) else {
                    XCTFail("Error reading response length!")
                    return
                }

                XCTAssert(length > 0, "Expected some bytes, received \(String(describing: length)) bytes.")
                guard let employee = try? JSONDecoder().decode(Employee.self, from: data) else {
                    XCTFail("Could not decode response! Expected response decodable to User, but got \(String(describing: String(data: data, encoding: .utf8)))")
                    return
                }

                // Validate the data we got back from the server
                XCTAssertEqual(employee.name, expectedEmployee.name)
                XCTAssertEqual(employee.serial, expectedEmployee.serial)

                expectation.fulfill()
            }, requestModifier: { request in
                request.write(from: employeeData)
            })
        }
    }
    
    func testReadAll() {
        Employee.read(respondWith: { result, error in
            if let error = error {
                XCTFail("ERROR!!! Read failed with message: \(error.localizedDescription)")
            }
            guard let result = result else {
                XCTFail("ERROR!!! Read failed, result was nil.")
                return
            }
            
            let expectedResult = employeeStore.map({ $0.value })
            XCTAssertEqual(expectedResult, result)
        })
        performServerTest(router, timeout: 30) { expectation in
            let expectedEmployees = employeeStore.map({ $0.value }) // TODO: Write these out explicitly?

            self.performRequest("get", path: "/employees", callback: { response in
                guard let response = response else {
                    XCTFail("ERROR!!! ClientRequest response object was nil")
                    return
                }

                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response.statusCode))")
                var data = Data()
                guard let length = try? response.readAllData(into: &data) else {
                    XCTFail("Error reading response length!")
                    return
                }

                XCTAssert(length > 0, "Expected some bytes, received \(String(describing: length)) bytes.")
                guard let employees = try? JSONDecoder().decode([Employee].self, from: data) else {
                    XCTFail("Could not decode response! Expected response decodable to array of Employees, but got \(String(describing: String(data: data, encoding: .utf8)))")
                    return
                }

                // Validate the data we got back from the server
                for (index, employee) in employees.enumerated() {
                    XCTAssertEqual(employee.serial, expectedEmployees[index].serial)
                    XCTAssertEqual(employee.name, expectedEmployees[index].name)
                }

                expectation.fulfill()
            })
        }
    }
    
    func testReadSingle() {
        Employee.read(id: 1, respondWith: { result, error in
            if let error = error {
                XCTFail("ERROR!!! Read failed with message: \(error.localizedDescription)")
            }
            guard let result = result else {
                XCTFail("ERROR!!! Read failed, result was nil.")
                return
            }
            
            if let expectedResult = employeeStore[1] {
                XCTAssertEqual(expectedResult, result)
            }
        })
        
        performServerTest(router, timeout: 30) { expectation in
            guard let expectedEmployee = employeeStore[1] else {
                XCTFail("ERROR!!! Couldn't find employee with id 1")
                return
            }

            self.performRequest("get", path: "/employees/1", callback: { response in
                guard let response = response else {
                    XCTFail("ERROR!!! ClientRequest response object was nil")
                    return
                }

                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response.statusCode))")
                var data = Data()
                guard let length = try? response.readAllData(into: &data) else {
                    XCTFail("Error reading response length!")
                    return
                }

                XCTAssert(length > 0, "Expected some bytes, received \(String(describing: length)) bytes.")
                guard let employee = try? JSONDecoder().decode(Employee.self, from: data) else {
                    XCTFail("Could not decode response! Expected response decodable an Employee, but got \(String(describing: String(data: data, encoding: .utf8)))")
                    return
                }

                // Validate the data we got back from the server
                XCTAssertEqual(employee.serial, expectedEmployee.serial)
                XCTAssertEqual(employee.name, expectedEmployee.name)

                expectation.fulfill()
            })
        }
    }
    
    func testUpdate() {
        let employee = Employee(serial: 6789, name: "Kye")
        Employee.update(id: 1, model: employee, respondWith: { result, error in
            if let error = error {
                XCTFail("ERROR!!! Update failed with the following message: \(error.localizedDescription)")
            }
            guard let result = result else {
                XCTFail("Some error here")
                return
            }
            let expectedResult = Employee(serial: 6789, name: "Kye")
            XCTAssertEqual(expectedResult, result)
            
        })
        
        performServerTest(router, timeout: 30) { expectation in
            // Let's create a User instance
            let expectedEmployee = Employee(serial: 6789, name: "Kye")
            // Create JSON representation of User instance
            guard let employeeData = try? JSONEncoder().encode(expectedEmployee) else {
                XCTFail("Could not generate employee data from string!")
                return
            }

            self.performRequest("put", path: "/employees/1", callback: { response in
                guard let response = response else {
                    XCTFail("ERROR!!! ClientRequest response object was nil")
                    return
                }

                XCTAssertEqual(response.statusCode, HTTPStatusCode.OK, "HTTP Status code was \(String(describing: response.statusCode))")
                var data = Data()
                guard let length = try? response.readAllData(into: &data) else {
                    XCTFail("Error reading response length!")
                    return
                }

                XCTAssert(length > 0, "Expected some bytes, received \(String(describing: length)) bytes.")
                guard let employee = try? JSONDecoder().decode(Employee.self, from: data) else {
                    XCTFail("Could not decode response! Expected response decodable to User, but got \(String(describing: String(data: data, encoding: .utf8)))")
                    return
                }

                // Validate the data we got back from the server
                XCTAssertEqual(employee.name, expectedEmployee.name)
                XCTAssertEqual(employee.serial, expectedEmployee.serial)

                expectation.fulfill()
            }, requestModifier: { request in
                request.write(from: employeeData)
            })
        }
    }
    
    func testDeleteAll() {
        Employee.delete(respondWith: {error in
            if let error = error {
                XCTFail("ERROR!!! Delete failed with message: \(error.localizedDescription)")
            }
        })
        
        let expectedResult = employeeStore.map( { $0.value } )
        XCTAssertEqual(expectedResult.count, 0)
        
        //TODO: Something more here??
    }
    
    func testDeleteSingle() {
        Employee.delete(id: 1, respondWith: { error in
            if let error = error {
                XCTFail("ERROR!!! Delete failed with message: \(error.localizedDescription)")
            }
        })
        
        guard let result = employeeStore[1] else {
            return
        }
        XCTFail("ERROR!!! \(result) should have been deleted.")
    }
    
    //TODO: Something more here??
}

#endif
