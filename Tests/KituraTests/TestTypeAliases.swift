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

@testable import Kitura

class TestTypeAliases: KituraTest {
    static var allTests: [(String, (TestTypeAliases) -> () throws -> Void)] {
        return [
            ("testKituraContractsTypes", testKituraContractsTypes)
        ]
    }

    struct MyQuery: QueryParams {
        public let greaterThan: GreaterThan<Int>
        public let greaterThanOrEqual: GreaterThanOrEqual<Int>
        public let lowerThan: LowerThan<Double>
        public let lowerThanOrEqual: LowerThanOrEqual<Double>
        public let inclusiveRange: InclusiveRange<UInt>
        public let exclusiveRange: ExclusiveRange<UInt>
        public let ordering: Ordering
        public let pagination: Pagination
    }

    func testKituraContractsTypes() {
      /// Test that it can constuct the Types without KituraContracts import statement

      let query = MyQuery(
        greaterThan: GreaterThan(value: 8),
        greaterThanOrEqual: GreaterThanOrEqual(value: 10),
        lowerThan: LowerThan(value: 7.0),
        lowerThanOrEqual: LowerThanOrEqual(value: 12.0),
        inclusiveRange: InclusiveRange(start: 0, end: 5),
        exclusiveRange: ExclusiveRange(start: 4, end: 15),
        ordering: Ordering(by: .asc("name"), .desc("age")),
        pagination: Pagination(start: 8, size: 14)
      )
    }
}
