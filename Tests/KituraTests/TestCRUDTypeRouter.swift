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
    let id: Int
}

extension Employee: Persistable {
    // Create
    static func create(model: Employee, respondWith: @escaping (Employee?, Swift.Error?) -> Void) {
        employeeStore[model.id] = model
        respondWith(model, nil)
    }

    static func read(respondWith: @escaping ([Employee]?, Swift.Error?) -> Void) {
        let employees: [Employee] = employeeStore.map { $0.1 }
        respondWith(employees, nil)
    }

    static func read(id: Int, respondWith: @escaping (Employee?, Swift.Error?) -> Void) {

    }

    static func update(id: Int, model: Employee, respondWith: @escaping (Employee?, Swift.Error?) -> Void) {
        employeeStore[id] = model
        respondWith(model, nil)
    }

    static func delete(respondWith: @escaping (Swift.Error?) -> Void) {

    }
    static func delete(id: Int, respondWith: @escaping (Swift.Error?) -> Void) {

    }
}

class TestCRUDTypeRouter: KituraTest {
    static var allTests: [(String, (TestCRUDTypeRouter) -> () throws -> Void)] {
        return [

        ]
    }
}

#endif
