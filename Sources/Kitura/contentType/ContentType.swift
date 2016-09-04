/*
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
 */

import Foundation
import LoggerAPI

// MARK: ContentType

/// A set of APIs to work with Content-Type headers, whether to generate the value
/// or to determine if it's an acceptable value.
public class ContentType {

    /// Whether to use the local mime-type definitions or the ones in the file
    #if os(Linux)
        private let mimeTypeEmbedded: Bool = true
    #else
        private let mimeTypeEmbedded: Bool = false
    #endif

    /// A dictionary of extensions to MIME type descriptions
    private var extToContentType = [String:String]()

    /// Shared singleton instance
    public static let sharedInstance = ContentType()

    /// The following function loads the MIME types from an external file
    private init () {
        // MARK: Remove this when Linux reading of JSON files works.
        if mimeTypeEmbedded {

            Log.warning("Loading embedded MIME types.")

            for (contentType, exts) in rawTypes {
                for ext in exts {
                    extToContentType[ext] = contentType
                }
            }

            return
        }

        let contentTypesData = contentTypesString.data(using: .utf8)
        guard contentTypesData != nil else {
            Log.error("Error parsing \(contentTypesString)")
            return
        }

        let jsonParseOptions = JSONSerialization.ReadingOptions.mutableContainers
        let parsedObject = try? JSONSerialization.jsonObject(with: contentTypesData!,
                                                                   options: jsonParseOptions)

        // MARK: Linux Foundation will return an Any instead of an AnyObject
        // Need to test if this breaks the Linux build.
        guard parsedObject != nil,
            let jsonData = parsedObject as? [String : [String]] else {
            Log.error("JSON could not be parsed")
            return
        }

        for (contentType, exts) in jsonData {
            for ext in exts {
                extToContentType[ext] = contentType
            }
        }
    }

    /// Get the content type for the given file extension
    ///
    /// - Parameter forExtension: the file extension
    ///
    /// - Returns: an Optional String for the content type
    public func getContentType(forExtension ext: String) -> String? {
        return extToContentType[ext]
    }

    /// Get the content type for the given file based on its extension
    ///
    /// - Parameter forFileName: the file
    ///
    /// - Returns: an Optional String for the content type
    public func getContentType(forFileName fileName: String) -> String? {
        let lastPathElemRange: Range<String.Index>
        let extRange: Range<String.Index>

        let backwards = String.CompareOptions.backwards
        if let lastSlash = fileName.range(of: "/", options: backwards) {
            lastPathElemRange = fileName.index(after: lastSlash.lowerBound)..<fileName.characters.endIndex
        } else {
            lastPathElemRange = fileName.characters.startIndex..<fileName.characters.endIndex
        }

        if let lastDot = fileName.range(of: ".", options: backwards, range: lastPathElemRange) {
            extRange = fileName.index(after: lastDot.lowerBound)..<fileName.characters.endIndex
        } else {
            // No "extension", use the entire last path element as the "extension"
            extRange = lastPathElemRange
        }

        return getContentType(forExtension: fileName.substring(with: extRange))
    }

    /// Check if the message content type matches the type descriptor
    ///
    /// - Parameter messageContentType: the content type
    /// - Parameter ofType: the description of the type
    ///
    /// - Returns: true if the types matched
    public func isContentType(_ messageContentType: String, ofType typeDescriptor: String) -> Bool {

        let type = typeDescriptor.lowercased()
        let typeAndSubtype = messageContentType.components(separatedBy: ";")[0].lowercased()

        if typeAndSubtype == type {
            return true
        }

        // typeDescriptor is file extension
        if typeAndSubtype == extToContentType[type] {
            return true
        }

        // typeDescriptor is a shortcut
        let normalizedType = normalize(type: type)
        if typeAndSubtype == normalizedType {
            return true
        }

        // the types match and the subtype in typeDescriptor is "*"
        let messageTypePair = typeAndSubtype.components(separatedBy: "/")
        let normalizedTypePair = normalizedType.components(separatedBy: "/")
        if messageTypePair.count == 2 && normalizedTypePair.count == 2
            && messageTypePair[0] == normalizedTypePair[0] && normalizedTypePair[1] == "*" {
            return true
        }
        return false
    }

    /// Normalized the type
    ///
    /// - Parameter type: the content type
    ///
    /// - Returns: the normalized String
    private func normalize(type: String) -> String {

        switch type {
        case "urlencoded":
            return "application/x-www-form-urlencoded"
        case "multipart":
            return "multipart/*"
        case "json":
            return "application/json"
            // TODO: +json?
            //            if (type[0] === '+') {
            //                // "+json" -> "*/*+json" expando
            //                type = '*/*' + type
            //            }
        default:
            return type
        }
    }

    /// The raw types
    /// *Note*: This will be removed once JSON parsing and the types.json file can be read.
    private var rawTypes = [
        "text/plain": ["txt", "text", "conf", "def", "list", "log", "in", "ini"],
        "text/html": ["html", "htm"],
        "text/css": ["css"],
        "text/csv": ["csv"],
        "text/xml": [],
        "text/javascript": [],
        "text/markdown": [],
        "text/x-markdown": ["markdown", "md", "mkd"],

        "application/json": ["json", "map"],
        "application/x-www-form-urlencoded": [],
        "application/xml": ["xml", "xsl", "xsd"],
        "application/javascript": ["js"],

        "image/bmp": ["bmp"],
        "image/png": ["png"],
        "image/gif": ["gif"],
        "image/jpeg": ["jpeg", "jpg", "jpe"],
        "image/svg+xml": ["svg", "svgz"]
    ]

}
