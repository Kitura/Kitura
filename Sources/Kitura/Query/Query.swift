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

// MARK: Query
/// Type for storing query key - parameter values
///
///
public struct Query: CustomStringConvertible {
    
    #if os(Linux)
    typealias RegularExpressionType = RegularExpression
    #else
    typealias RegularExpressionType = NSRegularExpression
    #endif
    
    /// Regular expression used to parse dicrionary or array passed as query object
    static var indexedParameterRegex: RegularExpressionType? = {
        return try? RegularExpressionType(pattern: "([^\\[\\]\\,\\.\\s]*)\\[([^\\[\\]\\,\\.\\s]*)\\]", options: .caseInsensitive)
    }()
    
    public static let null = Query()
    
    
    /// Query parameter types
    ///
    ///
    public enum ParameterType {
        
        /// Parameter with invalid object or of unknown type
        case null(object: Any)
        
        /// Parameter of array type
        case array([Any])
        
        /// Parameter of dictionary type
        case dictionary([String : Any])
        
        /// Parameter of integer type
        case int(Int)
        
        /// Parameter of string type
        case string(String)
        
        /// Parameter of floating-point type
        case double(Double)
        
        /// Parameter of boolean type
        case bool(Bool)
        
        /// Parameter of Data type
        case data(Data)
    }
    
    fileprivate(set) public var type: ParameterType = .null(object: NSNull())
    
    private init() { }
    
    /// Initialize a new Query instance.
    ///
    /// - Parameter object: object to be parsed as query parameter.
    public init(_ object: Any) {
        self.object = object
    }
    
    /// Formatted description of the parsed query parameter.
    public var description: String {
        return "\(self.object)"
    }
    
    public var isNull: Bool {
        if case .null = self.type {
            return true
        }
        
        return false
    }
    
    public var count: Int {
        switch self.type {
        case .array(let array):
            return array.count
        case .dictionary(let dictionary):
            return dictionary.count
        default:
            return 0
        }
    }
}

extension Query {
    
    /// Object contained in query parameter.
    fileprivate(set) public var object: Any {
        get {
            switch self.type {
            case .string(let value):
                return value
            case .int(let value):
                return value
            case .double(let value):
                return value
            case .bool(let value):
                return value
            case .array(let value):
                return value
            case .dictionary(let value):
                return value
            case .data(let value):
                return value
            case .null(let object):
                return object
            }
        }
        set {
            switch newValue {
            case let string as String where !string.isEmpty:
                if let int = Int(string) {
                    self.type = .int(int)
                } else if let double = Double(string) {
                    self.type = .double(double)
                } else if let bool = Bool(string) {
                    self.type = .bool(bool)
                } else {
                    self.type = .string(string)
                }
            case let int as Int:
                self.type = .int(int)
            case let double as Double:
                self.type = .double(double)
            case let bool as Bool:
                self.type = .bool(bool)
            case let array as [Any]:
                self.type = .array(array)
            case let dictionary as [String : Any]:
                self.type = .dictionary(dictionary)
            case let data as Data:
                self.type = .data(data)
            default:
                self.type = .null(object: newValue)
            }
        }
    }
    
    internal(set) public subscript(key: QueryKeyProtocol) -> Query {
        set {
            let realKey = key.queryKey
            switch (realKey, self.type) {
            case (.key(let key), .dictionary(var dictionary)):
                dictionary[key] = newValue.object
                self.type = .dictionary(dictionary)
            default:
                break
            }
        }
        get {
            let realKey = key.queryKey
            
            switch (realKey, self.type) {
            case (.key(let key), .dictionary(let dictionary)):
                guard let value = dictionary[key] else {
                    return Query.null
                }
                return Query(value)
            case (.index(let index), .array(let array)):
                guard array.count > index,
                    index >= 0 else {
                        return Query.null
                }
                return Query(array[index])
            default:
                break
            }
            
            return Query.null
        }
    }
    
    public subscript(keys: [QueryKeyProtocol]) -> ParameterValue {
        get {
            return keys.reduce(self) { $0[$1] }
        }
    }
    
    public subscript(keys: QueryKeyProtocol...) -> ParameterValue {
        get {
            return self[keys]
        }
    }
}
