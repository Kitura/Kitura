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

extension Bool {
    
    /// Convenience initializer from string.
    ///
    /// - Parameter string: string to be used for conversion.
    fileprivate init?(_ string: String) {
        guard string == "true" || string == "false" else { return nil }
        self.init(string == "true")
    }
}

// MARK: Query parameter return values.
extension Query: ParameterValue {
    
    /// Query parameter as optional 'Data' value
    public var data: Data? {
        switch self.type {
        case .string(let value):
            return value.data(using: .utf8, allowLossyConversion: false)
        case .int(let value as Any),
             .double(let value as Any),
             .bool(let value as Any),
             .array(let value as Any),
             .dictionary(let value as Any),
             .null(let value):
            return String(describing: value).data(using: .utf8, allowLossyConversion: false)
        default:
            return nil
        }
    }
    
    /// Query parameter as optional 'String' value
    public var string: String? {
        switch self.type {
        case .string(let value):
            return value
        case .int(let value):
            return String(value)
        case .double(let value):
            return String(value)
        case .bool(let value):
            return String(value)
        default:
            return nil
        }
    }
    
    /// Query parameter as optional 'Int' value
    public var int: Int? {
        switch self.type {
        case .string(let value):
            return Int(value)
        case .int(let value):
            return value
        case .double(let value):
            return Int(value)
        case .bool(let value):
            return value ? 1 : 0
        default:
            return nil
        }
    }
    
    /// Query parameter as optional 'Double' value
    public var double: Double? {
        switch self.type {
        case .string(let value):
            return Double(value)
        case .int(let value):
            return Double(value)
        case .double(let value):
            return value
        default:
            return nil
        }
    }
    
    /// Query parameter as optional 'Bool' value
    public var bool: Bool? {
        switch self.type {
        case .bool(let value):
            return value
        case .string(let value):
            return Bool(value)
        case .int(let value):
            return value != 0
        default:
            return nil
        }
    }
    
    /// Query parameter as optional array value
    public var array: [Any]? {
        switch self.type {
        case .array(let value):
            return value
        default:
            return nil
        }
    }
    
    /// Query parameter as optional dictionary value
    public var dictionary: [String : Any]? {
        switch self.type {
        case .dictionary(let value):
            return value
        default:
            return nil
        }
    }
}
