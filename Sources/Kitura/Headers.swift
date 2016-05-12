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
    
    public subscript(key: String) -> String? {
        get {
            return get(key)
        }
        
        set(newValue) {
            if let newValue = newValue {
                set(key, value: newValue)
            }
        }
    }
    
    ///
    /// Gets the header (case insensitive)
    ///
    /// - Parameter key: the key
    ///
    /// - Returns: the value for the key
    ///
    public func get(_ key: String) -> String? {
        return headers.get(key)?.first
    }
    
    ///
    /// Set the header value
    ///
    /// - Parameter key: the key
    /// - Parameter value: the value
    ///
    /// - Returns: the value for the key as a list
    ///
    public mutating func set(_ key: String, value: String) {
        
        headers.set(key, value: value)
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

    
    ///
    /// Remove the header by key (case insensitive)
    ///
    /// - Parameter key: the key
    ///
    public mutating func remove(_ key: String) {
        
        headers.remove(key)
    }
}
