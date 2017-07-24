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

class TestStack: XCTestCase {

    static var allTests: [(String, (TestStack) -> () throws -> Void)] {
        return [
            ("testEmpty", testEmpty),
            ("testPushPop", testPushPop)
        ]
    }

    func testEmpty() {
        let stack = Stack<Int>()
        XCTAssertNil(stack.topItem)
    }

    private func assertTopItem<Element: Equatable>(_ stack: Stack<Element>, item: Element) {
        guard let topItem = stack.topItem else {
            XCTFail("stack.topItem unexpectedly nil")
            return
        }
        XCTAssertEqual(item, topItem, "expected \(item), returned \(topItem)")
    }

    private func popAndAssert<Element: Equatable>(_ stack: inout Stack<Element>, item: Element) {
        let popped = stack.pop()
        XCTAssertEqual(item, popped, "expected \(item), returned \(popped)")
    }

    func testPushPop() {
        var stack = Stack<Int>()

        stack.push(1)
        assertTopItem(stack, item: 1)

        stack.push(2)
        assertTopItem(stack, item: 2)

        stack.push(3)
        assertTopItem(stack, item: 3)

        popAndAssert(&stack, item: 3)
        assertTopItem(stack, item: 2)

        stack.push(4)
        assertTopItem(stack, item: 4)

        popAndAssert(&stack, item: 4)
        assertTopItem(stack, item: 2)

        popAndAssert(&stack, item: 2)
        assertTopItem(stack, item: 1)

        popAndAssert(&stack, item: 1)
        XCTAssertNil(stack.topItem)
    }
}
