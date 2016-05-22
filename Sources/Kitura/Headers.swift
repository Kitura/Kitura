/**
 * Copyright IBM Corporation 2015
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

import Foundation
import KituraNet

public struct Headers {
    
    ///
    /// The header storage
    ///
    internal var headers: HeadersContainer
    
    init(headers: HeadersContainer) {
        self.headers = headers
    }
    
    ///
    /// Append values to the header
    ///
    /// - Parameter key: the key
    /// - Parameter value: the value
    ///
    public mutating func append(_ key: String, value: String) {
        
        headers.append(key, value: value)
    }
}

extension Headers: Collection {
    
    public var startIndex: HeadersIndex {return headers.startIndex }
    public var endIndex: HeadersIndex { return headers.endIndex }
    
    public typealias HeadersIndex = DictionaryIndex<String, [String]>
    
    public subscript(key: String) -> String? {
        get {
            return headers[key]?.first
        }
        
        set(newValue) {
            if let newValue = newValue {
                headers[key] = [newValue]
            }
            else {
                headers[key] = nil
            }
        }
    }
    
    
    public subscript(position: HeadersIndex) -> (String, String?) {
        get {
            let (key, value) = headers[position]
            return (key, value.first)
        }
    }
    
    public func index(after i: HeadersIndex) -> HeadersIndex {
        return headers.index(after: i)
    }
}
