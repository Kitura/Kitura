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

import Foundation
import LoggerAPI

/// String Utils
extension String {

    /// Parses percent encoded string into query parameters
    var urlDecodedFieldValuePairs: [String : String] {
        var result: [String:String] = [:]

        for item in self.components(separatedBy: "&") {
            guard let range = item.range(of: "=") else {
                result[item] = nil
                continue
            }

            let key = String(item[..<range.lowerBound])
            let value = String(item[range.upperBound...])

            let valueReplacingPlus = value.replacingOccurrences(of: "+", with: " ")
            if let decodedValue = valueReplacingPlus.removingPercentEncoding {
                if let value = result[key] {
                    result[key] = "\(value),\(decodedValue)"
                } else {
                    result[key] = decodedValue
                }
            } else {
                Log.warning("Unable to decode query parameter \(key)")
                result[key] = valueReplacingPlus
            }
        }

        return result
    }
}

/// Codable String Conversion Extension
extension String {

    /// Converts the given String to an Int?
    public var int: Int? {
        return Int(self)
    }

    /// Converts the given String to a UInt?
    public var uInt: UInt? {
        return UInt(self)
    }

    /// Converts the given String to a Float?
    public var float: Float? {
        return Float(self)
    }

    /// Converts the given String to a Double?
    public var double: Double? {
        return Double(self)
    }

    /// Converts the given String to a Bool?
    public var boolean: Bool? {
        return Bool(self)
    }

    /// Converts the given String to a String
    public var string: String {
        return self
    }

    /// Converts the given String to an [Int]?
    public var intArray: [Int]? {
        let strs: [String] = self.components(separatedBy: ",")
        let ints: [Int] = strs.map { Int($0) }.filter { $0 != nil }.map { $0! }
        if ints.count == strs.count {
            return ints
        }
        return nil
    }

    /// Converts the given String to an [UInt]?
    public var uIntArray: [UInt]? {
        let strs: [String] = self.components(separatedBy: ",")
        let uInts: [UInt] = strs.map { UInt($0) }.filter { $0 != nil }.map { $0! }
        if uInts.count == strs.count {
            return uInts
        }
        return nil
    }

    /// Converts the given String to a [Float]?
    public var floatArray: [Float]? {
        let strs: [String] = self.components(separatedBy: ",")
        let floats: [Float] = strs.map { Float($0) }.filter { $0 != nil }.map { $0! }
        if floats.count == strs.count {
            return floats
        }
        return nil
    }

    /// Converts the given String to a [Double]?
    public var doubleArray: [Double]? {
        let strs: [String] = self.components(separatedBy: ",")
        let doubles: [Double] = strs.map { Double($0) }.filter { $0 != nil }.map { $0! }
        if doubles.count == strs.count {
            return doubles
        }
        return nil
    }

    /// Converts the given String to a [Bool]?
    public var booleanArray: [Bool]? {
        let strs: [String] = self.components(separatedBy: ",")
        let bools: [Bool] = strs.map { Bool($0) }.filter { $0 != nil }.map { $0! }
        if bools.count == strs.count {
            return bools
        }
        return nil
    }

    /// Converts the given String to a [String]
    public var stringArray: [String] {
        let strs: [String] = self.components(separatedBy: ",")
        return strs
    }

    /// Method used to decode a string into the given type T
    ///
    /// - Parameters:
    ///     - _ type: The Decodable type to convert the string into.
    /// - Returns: The Date? object. Some on success / nil on failure
    public func decodable<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        let obj: T? = try? JSONDecoder().decode(type, from: data)
        return obj
    }

    /// Converts the given String to a Date?
    ///
    /// - Parameters:
    ///     - _ formatter: The designated DateFormatter to convert the string with.
    /// - Returns: The Date? object. Some on success / nil on failure
    public func date(_ formatter: DateFormatter) -> Date? {
        return formatter.date(from: self)
    }

    /// Converts the given String to a [Date]?
    ///
    /// - Parameters:
    ///     - _ formatter: The designated DateFormatter to convert the string with.
    /// - Returns: The [Date]? object. Some on success / nil on failure
    public func dateArray(_ formatter: DateFormatter) -> [Date]? {
        let strs: [String] = self.components(separatedBy: ",")
        let dates = strs.map { formatter.date(from: $0) }.filter { $0 != nil }.map { $0! }
        if dates.count == strs.count {
            return dates
        }
        return nil
    }
}
