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

extension RouterRequest {
    class MimeTypeAcceptor {

        ///
        /// Finds the full mime type for a given extension
        ///
        /// - Parameter forExtension: mime type extension String
        ///
        /// - Returns the full mime type
        ///
        private static func getMimeType(forExtension ext: String) -> String {
            if let mimeType = ContentType.sharedInstance.getContentType(forExtension: ext) {
                return mimeType
            }
            return ext
        }

        typealias MimeTypeWithQValue = (type: String, qValue: Double)

        ///
        /// Parse mime type string into a digestable tuple format
        ///
        /// - Parameter type: raw mime type String
        ///
        /// - Returns a tuple with the mime type and q parameter value if present, qValue defaults to 1
        ///
        private static func parse(mediaType type: String) -> MimeTypeWithQValue {
            var finishedPair = ("", 1.0)
            let trimmed = type.trimmingCharacters(in: NSCharacterSet.whitespaces())
            let components = trimmed.characters.split(separator: ";").map(String.init)

            if let mediaType = components.first {
                finishedPair.0 = mediaType
            }
            if let qPreference = components.last {
                let qualityComponents = qPreference.characters.split(separator: "=").map(String.init)
                if let q = qualityComponents.first, value = qualityComponents.last where q == "q",
                    let pairValue = Double(value) {
                    finishedPair.1 = pairValue
                }
            }

            return finishedPair
        }

        ///
        /// Checks if passed in content types are acceptable based on the request's Accept header
        /// field values
        ///
        /// - Parameter headerValues: array of Accept header values
        ///
        /// - Parameter types: array of content/mime type strings
        ///
        /// - Returns most acceptable type or nil if there are none
        ///
        static func accepts(headerValues: [String], types: [String]) -> String? {
            let criteriaMatches = getCriteriaMatches(headerValues: headerValues, types: types)

            // sort by priority and by qValue to determine best type to return
            let sortedMatches = Array(criteriaMatches).sorted {
                if $0.1.priority != $1.1.priority {
                    return $0.1.priority < $1.1.priority
                } else {
                    return $0.1.qValue > $1.1.qValue
                }
            }

            if let bestMatch = sortedMatches.first {
                return bestMatch.0
            }
            return nil
        }

        private typealias CriteriaMatches = [String : (priority: Int, qValue: Double)]

        private static func getCriteriaMatches(headerValues: [String], types: [String]) -> CriteriaMatches {
            var criteriaMatches = [String : (priority: Int, qValue: Double)]()

            for rawHeaderValue in headerValues {
                for type in types {
                    handleMatch(rawHeaderValue: rawHeaderValue, type: type,
                                criteriaMatches: &criteriaMatches)
                }
            }
            return criteriaMatches
        }

        private static func handleMatch(rawHeaderValue: String, type: String,
                                        criteriaMatches: inout CriteriaMatches) {
            let parsedHeaderValue = parse(mediaType: rawHeaderValue)
            let mimeType = getMimeType(forExtension: type)

            let setMatchWithPriority = { (priority: Int) in
                criteriaMatches[type] = (priority: priority, qValue: parsedHeaderValue.qValue)
            }

            if parsedHeaderValue.type == mimeType { // exact match, e.g. text/html == text/html
                setMatchWithPriority(1)
                return
            }

            if parsedHeaderValue.type == "*/*" {
                if criteriaMatches[type] == nil { // else do nothing
                    setMatchWithPriority(3)
                }
                return
            }

            if nil == mimeType.range(of: parsedHeaderValue.type,
                                     options: .regularExpressionSearch) {
                return
            }

            // partial match, e.g. text/html == text/*
            if let match = criteriaMatches[type] {
                if match.priority > 2 {
                    setMatchWithPriority(2)
                }
            } else  {
                setMatchWithPriority(2)
            }
        }
    }
}
