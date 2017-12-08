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

/// Class defining shared resources for the QueryDecoder and QueryEncoder
public class Coder {

    /// The designated DateFormatter used for encoding and decoding query parameters
    public let dateFormatter: DateFormatter

    /// Initializes a Coder instance with a Date Formatter
    /// using the "UTC" timezone and "yyyy-MM-dd'T'HH:mm:ssZ" date format
    public init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.timeZone = TimeZone(identifier: "UTC")
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    }

    /// Helper method to extract the field name from a CodingKey array
    public static func getFieldName(from codingPath: [CodingKey]) -> String {
        return codingPath.flatMap({"\($0)"}).joined(separator: ".")
    }
}
