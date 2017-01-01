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

// MARK: Query parsing.
extension Query {
    
    /// Initialize a new Query instance by parsing URL query string.
    ///
    /// - Parameter query: URL query string to be parsed.
    public init(percentEncodedQuery query: String?) {
        guard let query = query else {
                self.init()
                return
        }
        
        let dictionary = Query.parse(query: query)
        self.init(dictionary)
    }
    
    private static func parse(query: String) -> [String : Any] {
        var root = [String : Any]()
        let keyValues = query.components(separatedBy: "&")
        
        for keyValue in keyValues {
            guard let range = keyValue.range(of: "=") else {
                continue
            }
            
            guard let key = keyValue.substring(to: range.lowerBound)
                .removingPercentEncoding,
                !key.isEmpty else {
                    continue
            }
            
            let valuesString = keyValue
                .substring(from: range.upperBound)
                .replacingOccurrences(of: "+", with: " ")
            
            let values = valuesString.components(separatedBy: ",")
            
            for value in values {
                guard let value = value.removingPercentEncoding,
                    !value.isEmpty else {
                        continue
                }
                
                self.parse(into: &root, key: key, value: value)
            }
        }
        
        return root
    }
    
    private static func parse(into root: inout [String : Any], key: String, value: String) {
        if let startKeyRange = key.range(of: "["),
            let endKeyRange = key.range(of: "]", range: (startKeyRange.upperBound..<key.endIndex)) {
            
            let rootKey = key.substring(to: startKeyRange.lowerBound)
            
            guard startKeyRange.upperBound != endKeyRange.lowerBound else {
                self.store(in: &root, key: rootKey, value: value)
                return
            }
            
            let nextKey = key.substring(with: (startKeyRange.upperBound..<endKeyRange.lowerBound)) + key.substring(from: endKeyRange.upperBound)
            
            let storedValue = root[rootKey]
            switch storedValue {
            case var dictionary as [String : Any]:
                self.parse(into: &dictionary, key: nextKey, value: value)
                root[rootKey] = dictionary
            case var array as [Any]:
                var dictionary = [String : Any]()
                self.parse(into: &dictionary, key: nextKey, value: value)
                array.append(dictionary)
                root[rootKey] = array
            case let current?:
                var array = [current]
                var dictionary = [String : Any]()
                self.parse(into: &dictionary, key: nextKey, value: value)
                array.append(dictionary)
                root[rootKey] = array
            default:
                var dictionary = [String : Any]()
                self.parse(into: &dictionary, key: nextKey, value: value)
                root[rootKey] = dictionary
            }
            
        } else {
            self.store(in: &root, key: key, value: value)
        }
    }
    
    private static func store(in dictionary: inout [String : Any], key: String, value: String) {
        let storedValue = dictionary[key]
        switch storedValue {
        case .none:
            dictionary[key] = value
        case var array as [Any]:
            array.append(value)
            dictionary[key] = array
        default:
            let array = [storedValue!, value]
            dictionary[key] = array
        }
    }
}
