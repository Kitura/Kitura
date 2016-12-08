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

import SwiftyJSON

// MARK: QueryKey

/// Enum type that descripbes subscript keys
///
///
public enum QueryKey {
    
    /// Subscript key based on Int
    case index(Int)
    
    /// Subscript key based on String
    case key(String)
}

/// Protocol for implementing query key for types used in subscripting
///
///
public protocol QueryKeyProtocol: JSONSubscriptType {
    
    /// 'QueryKey' value
    var queryKey: QueryKey { get }
}

extension Int: QueryKeyProtocol {
    
    public var queryKey: QueryKey {
        return .index(self)
    }
}

extension String: QueryKeyProtocol {
    
    public var queryKey: QueryKey {
        return .key(self)
    }
}
