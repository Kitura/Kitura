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

// MARK: Stack

/// Standard generic stack
///
/// copied from https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html
struct Stack<Element> {
    private var items = [Element]()

    /// Return top item of the stack if not empty, or nil
    ///
    /// - Returns: The top item if the stack is not empty, or nil.
    var topItem: Element? {
        return items.isEmpty ? nil : items[items.count - 1]
    }

    /// push an item into the stack
    ///
    /// - Parameter item: the item to push
    mutating func push(_ item: Element) {
        items.append(item)
    }

    /// pop an item from the stack
    ///
    /// - Returns: the popped item
    mutating func pop() -> Element {
        return items.removeLast()
    }
}
