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

/**
 The `ContentType` class provides functions to determine the MIME content type for a given file extension. The user can pass in a complete file name e.g. "foo.png" or just the file extension e.g. "png", or they can pass in both a MIME content type and a file extension and query whether they match.
 ### Usage Example: ###
 In this example, a `ContentType` instance is initialised called contentType. This instance is then used to obtain the MIME content type of the file "foo.png", which is identified as "image/png".
 ```swift
 let contentType = ContentType.sharedInstance
 let result = contentType.getContentType(forFileName: "foo.png")
 print(String(describing: result))
 // Prints Optional("image/png")
 ```
 */
public class ContentType {

    /// A dictionary of extensions to MIME type descriptions
    private var extToContentType = [String:String]()

    /// Shared singleton instance.
    public static let sharedInstance = ContentType()

    /// The following function loads the MIME types from an external file
    private init () {
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

    /**
     Get the content type for the given file extension.
     ### Usage Example: ###
     ```swift
     let contentType = ContentType.sharedInstance
     let result = contentType.getContentType(forExtension: "js")
     print(String(describing: result))
     //Prints Optional("application/javascript")
     ```
     - Parameter forExtension: The file extension.
     - Returns: An Optional String for the content type.
     */
    public func getContentType(forExtension ext: String) -> String? {
        return extToContentType[ext]
    }

    /**
     Get the content type for the given file based on its extension.
     ### Usage Example: ###
     ```swift
     let contentType = ContentType.sharedInstance
     let result = contentType.getContentType(forFileName: "test.html")
     print(String(describing: result))
     //Prints Optional("text/html")
     ```
     - Parameter forFileName: The file name.
     - Returns: An Optional String for the content type.
     */
    public func getContentType(forFileName fileName: String) -> String? {
        let lastPathElemRange: Range<String.Index>
        let extRange: Range<String.Index>

        let backwards = String.CompareOptions.backwards
        if let lastSlash = fileName.range(of: "/", options: backwards) {
            lastPathElemRange = fileName.index(after: lastSlash.lowerBound)..<fileName.endIndex
        } else {
            lastPathElemRange = fileName.startIndex..<fileName.endIndex
        }

        if let lastDot = fileName.range(of: ".", options: backwards, range: lastPathElemRange) {
            extRange = fileName.index(after: lastDot.lowerBound)..<fileName.endIndex
        } else {
            // No "extension", use the entire last path element as the "extension"
            extRange = lastPathElemRange
        }

        return getContentType(forExtension: String(fileName[extRange]))
    }

    /**
     Check if the message content type matches the type descriptor.
     ### Usage Example: ###
     ```swift
     let contentType = ContentType.sharedInstance
     var result = contentType.isContentType("application/json", ofType: "json")
     print(String(describing: result))
     //Prints true
     ```
     - Parameter messageContentType: The content type.
     - Parameter ofType: The description of the type.
     - Returns: True if the types matched.
     */
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

    /// Normalize the type
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
            // swiftlint:disable todo
            // TODO: +json?
            //            if (type[0] === '+') {
            //                // "+json" -> "*/*+json" expando
            //                type = '*/*' + type
            //            }
        // swiftlint:enable todo
        default:
            return type
        }
    }

}
