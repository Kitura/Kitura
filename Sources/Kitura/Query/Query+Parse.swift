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

extension String {
    
    fileprivate var trimmed: String {
        let characterSet = CharacterSet(charactersIn: " \"\n")
        return self.trimmingCharacters(in: characterSet)
    }
}

// MARK: Query parsing.
extension Query {
    
    /// Initialize a new Query instance by parsing URL query string.
    ///
    /// - Parameter query: URL query string to be parsed.
    public init(fromText query: String?) {
        self.init([:])
        
        guard let query = query,
            let escapedQuery = query.removingPercentEncoding else {
                return
        }
        Query.parse(fromText: escapedQuery, into: &self)
    }
    
    static private func parse(fromText query: String, into root: inout Query) {
        let pairs = query.components(separatedBy: "&")
        
        for pair in pairs {
            let pairArray = pair.components(separatedBy: "=")
            
            guard pairArray.count == 2 else {
                continue
            }
            
            let key = pairArray[0]
            let valueString = pairArray[1]
            
            guard !valueString.isEmpty,
                !key.isEmpty else {
                    continue
            }
            
            let value = Query(valueString)
            if case .null = value.type { continue }
            Query.parse(root: &root, key: key, value: value)
        }
    }
    
    static private func parse(root: inout Query, key: String?, value: Query) {
        if let key = key,
            let regex = Query.keyedParameterRegex,
            let match = regex.firstMatch(in: key, options: [], range: NSMakeRange(0, key.characters.count)) {
            let nsKey = NSString(string: key)
            
            #if os(Linux)
                let matchRange = match.range(at: 0)
                let parameterRange = match.range(at: 1)
                let indexRange = match.range(at: 2)
            #else
                let matchRange = match.rangeAt(0)
                let parameterRange = match.rangeAt(1)
                let indexRange = match.rangeAt(2)
            #endif
            
            let parameterKey = nsKey.substring(with: parameterRange).trimmed
            let indexKey = nsKey.substring(with: indexRange).trimmed
            
            let nextKey = nsKey.replacingCharacters(in: matchRange, with: indexKey)
        
            Query.parse(root: &root,
                        key: nextKey,
                        parameterKey: parameterKey,
                        defaultRaw: [:],
                        value: value) { $0.dictionary }
        } else if let key = key?.replacingOccurrences(of: "[]", with: ""),
            !key.isEmpty {
            
            let currentValue = root[key]
            if case .null = currentValue.type {
                root[key] = value
            } else if case .array(var array) = currentValue.type {
                array.append(value.object)
                root[key] = Query(array)
            } else {
                let array = [currentValue.object, value.object]
                root[key] = Query(array)
            }
        }
    }
    
    static private func parse(root: inout Query,
                              key: String,
                              parameterKey: String,
                              defaultRaw: Any,
                              value: Query,
                              raw rawClosure: (Query) -> Any?) {
        var newParameter: Query
        
        if !parameterKey.isEmpty,
            let raw = rawClosure(root[parameterKey]) {
            newParameter = Query(raw)
        } else if parameterKey.isEmpty,
            let raw = root.array?.first {
            newParameter = Query(raw)
        } else {
            newParameter = Query(defaultRaw)
        }
        
        Query.parse(root: &newParameter, key: key, value: value)
        
        if !parameterKey.isEmpty {
            root[parameterKey] = newParameter
        } else if case .array(var array) = root.type {
            if array.count > 0 {
                array[0] = newParameter.object
            } else {
                array.append(newParameter.object)
            }
            
            root = Query(array)
        }
    }
}
