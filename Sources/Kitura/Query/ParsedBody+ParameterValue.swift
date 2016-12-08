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

extension ParsedBody: ParameterValue {
    
    public var object: Any {
        return self
    }
    
    /// Data representing parameter.
    public var data: Data? {
        switch self {
        case .raw(let data):
            return data
        case .text(let value):
            return value.data(using: .utf8, allowLossyConversion: false)
        default:
            return nil
        }
    }
    
    /// String representing parameter.
    public var string: String? {
        switch self {
        case .json(let value):
            return value.string
        case .raw(let data):
            return String(data: data, encoding: .utf8)
        case .text(let value):
            return value
        default:
            return nil
        }
    }
    
    /// Integer representing parameter.
    public var int: Int? {
        switch self {
        case .json(let value):
            return value.int
        case .raw(let data):
            guard let string = String(data: data, encoding: .utf8) else {
                return nil
            }
            
            return Int(string)
        case .text(let value):
            return Int(value)
        default:
            return nil
        }
    }
    
    /// Floating-point representing parameter.
    public var double: Double? {
        switch self {
        case .json(let value):
            return value.double
        case .raw(let data):
            guard let string = String(data: data, encoding: .utf8) else {
                return nil
            }
            
            return Double(string)
        case .text(let value):
            return Double(value)
        default:
            return nil
        }
    }
    
    /// Bool representing parameter.
    public var bool: Bool? {
        switch self {
        case .json(let value):
            return value.bool
        case .raw(let data):
            guard let string = String(data: data, encoding: .utf8) else {
                return nil
            }
            return Bool(string)
        case .text(let value):
            return Bool(value)
        default:
            return nil
        }
    }
    
    /// Array representing parameter.
    public var array: [Any]? {
        switch self {
        case .json(let value):
            return value.array
        default:
            return nil
        }
    }
    
    /// Dictionary representing parameter.
    public var dictionary: [String : Any]? {
        switch self {
        case .json(let value):
            return value.dictionary
        case .urlEncoded(let dictionary):
            return dictionary
        default:
            return nil
        }
    }
    
    public subscript(keys: [QueryKeyProtocol]) -> ParameterValue {
        get {
            guard keys.count > 0 else {
                return self
            }
            
            switch self {
            case .json(let json):
                return json[keys]
            case .multipart(let parts) where keys.count > 0:
                var keys = keys
                let key = keys.remove(at: 0)
                
                guard case .key(let name) = key.queryKey else { return Query.null }
                
                let found: ParameterValue = parts.first { $0.name == name } ?? Query.null
                return found[keys]
            default:
                return Query.null
            }
            
        }
    }
    
    public subscript(keys: QueryKeyProtocol...) -> ParameterValue {
        get {
            return self[keys]
        }
    }

}
