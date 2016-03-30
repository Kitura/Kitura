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
import LoggerAPI

// MARK: ContentType 

public class ContentType {
    
    ///
    /// Whether to use the local mime-type definitions or the ones in the file
    ///
    #if os(Linux)
        private static let MIME_TYPE_EMBEDDED: Bool = true
    #else
        private static let MIME_TYPE_EMBEDDED: Bool = false
    #endif
    
    ///
    /// A dictionary of extensions to MIME type descriptions
    ///
    private static var extToContentType = [String:String]()

    ///
    /// The following function loads the MIME types from an external file
    ///
    public class func initialize () {

        // MARK: Remove this when Linux reading of JSON files works.
        if MIME_TYPE_EMBEDDED {

            Log.warning("Loading embedded MIME types.")

            for (contentType, exts) in rawTypes {
                for ext in exts {
                    extToContentType[ext] = contentType
                }
            }

            return
        }

        let contentTypesData = contentTypesString.bridge().data(usingEncoding: NSUTF8StringEncoding)

        if contentTypesData == nil {
            Log.error("Error parsing \(contentTypesString)")
            return
        }

        // MARK: Linux Foundation will return an Any instead of an AnyObject
        // Need to test if this breaks the Linux build.
        let jsonData = try? NSJSONSerialization.jsonObject(with: contentTypesData!,
            options: NSJSONReadingOptions.mutableContainers) as? NSDictionary

        if jsonData == nil || jsonData! == nil {
            Log.error("JSON could not be parsed")
            return
        }

        for (contentType, exts) in jsonData!! {

            let e = exts as! [String]
            for ext in e {

                extToContentType[ext] = contentType as? String

            }
        }
    }

    ///
    /// Get the content type for the given file extension
    ///
    /// - Parameter ext: the file extension
    ///
    /// - Returns: an Optional String for the content type
    ///
    public class func contentTypeForExtension (ext: String) -> String? {
        return extToContentType[ext]
    }

    ///
    /// Get the content type for the given file based on its extension
    ///
    /// - Parameter fileName: the file
    ///
    /// - Returns: an Optional String for the content type
    ///
    public class func contentTypeForFile (fileName: String) -> String? {
        let lastPathElemRange: Range<String.Index>
        if  let lastSlash = fileName.range(of: "/", options: NSStringCompareOptions.backwardsSearch)  {
            lastPathElemRange = lastSlash.startIndex.successor()..<fileName.characters.endIndex
        }
        else {
            lastPathElemRange = fileName.characters.startIndex..<fileName.characters.endIndex
        }

        let extRange: Range<String.Index>
        if  let lastDot = fileName.range(of: ".", range: lastPathElemRange)  {
            extRange = lastDot.startIndex.successor()..<fileName.characters.endIndex
        }
        else {
            // No "extension", use the entire last path element as the "extension"
            extRange = lastPathElemRange
        }

        return contentTypeForExtension(fileName.substring(with: extRange))
    }

    ///
    /// Check if the message content type matches the type descriptor
    ///
    /// - Parameter messageContentType: the content type
    /// - Parameter typeDescriptor: the description of the type
    ///
    /// - Returns: whether the types matched
    ///
    public class func isType (messageContentType: String, typeDescriptor: String) -> Bool {

        let type = typeDescriptor.lowercased()
        let typeAndSubtype = messageContentType.bridge().componentsSeparated(by: ";")[0].lowercased()

        if typeAndSubtype == type {
            return true
        }

        // typeDescriptor is file extension
        if typeAndSubtype == extToContentType[type] {
            return true
        }

        // typeDescriptor is a shortcut
        let normalizedType = normalizeType(type)
        if typeAndSubtype == normalizedType {
            return true
        }

        // the types match and the subtype in typeDescriptor is "*"
        let messageTypePair = typeAndSubtype.bridge().componentsSeparated(by: "/")
        let normalizedTypePair = normalizedType.bridge().componentsSeparated(by: "/")
        if messageTypePair.count == 2 && normalizedTypePair.count == 2
            && messageTypePair[0] == normalizedTypePair[0] && normalizedTypePair[1] == "*" {
            return true
        }
        return false
    }
    
    ///
    /// Normalized the type 
    ///
    /// - Parameter type: the content type
    /// 
    /// - Returns: the normalized String 
    ///
    private class func normalizeType (type: String) -> String {
        
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
    
    ///
    /// The raw types
    /// *Note*: This will be removed once JSON parsing and the types.json file can be read. 
    ///
    private static var rawTypes = [
        "text/plain": ["txt","text","conf","def","list","log","in","ini"],
        "text/html": ["html", "htm"],
        "text/css": ["css"],
        "text/csv": ["csv"],
        "text/xml": [],
        "text/javascript": [],
        "text/markdown": [],
        "text/x-markdown": ["markdown","md","mkd"],

        "application/json": ["json","map"],
        "application/x-www-form-urlencoded": [],
        "application/xml": ["xml","xsl","xsd"],
        "application/javascript": ["js"],

        "image/bmp": ["bmp"],
        "image/png": ["png"],
        "image/gif": ["gif"],
        "image/jpeg": ["jpeg","jpg","jpe"],
        "image/svg+xml": ["svg","svgz"]
    ]

}
