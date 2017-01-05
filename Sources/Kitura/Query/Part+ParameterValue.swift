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

import Foundation

extension Part: ParameterValue {
    
    public var object: Any {
        return self
    }
    
    /// Data representing parameter.
    public var data: Data? {
        return self.body.data
    }
    
    /// String representing parameter.
    public var string: String? {
        return self.body.string
    }
    
    /// Integer representing parameter.
    public var int: Int? {
        return self.body.int
    }
    
    /// Floating-point representing parameter.
    public var double: Double? {
        return self.body.double
    }
    
    /// Bool representing parameter.
    public var bool: Bool? {
        return self.body.bool
    }
    
    /// Array representing parameter.
    public var array: [Any]? {
        return self.body.array
    }
    
    /// Dictionary representing parameter.
    public var dictionary: [String : Any]? {
        return self.body.dictionary
    }
    
    public subscript(keys: [QueryKeyProtocol]) -> ParameterValue {
        get {
            guard keys.count > 0 else {
                return self
            }
            return self.body[keys]
        }
    }
    
    public subscript(keys: QueryKeyProtocol...) -> ParameterValue {
        get {
            return self[keys]
        }
    }
}
