/**
 * Copyright IBM Corporation 2015
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
import HeliumLogger

public class ContentType {
    
    private static let MIME_TYPE_EMBEDDED: Bool = true
    
    // For now the MIME types are specified in
    private static let TYPES_PATH: [String] = [
        "Sources/router/contentType/types.json",
        "Packages/Phoenix/Sources/router/contentType/types.json",
        "./types.json"]
    
    
    private static var extToContentType = [String:String]()
    
    /**
    * Attempt to load data from the filesystem in order from the following paths
    **/
    public class func loadDataFromFile (paths: [String]) -> NSData? {
        
        for path in paths {
            
            let data = NSData(contentsOfFile: path)
            
            if data != nil {
                return data
            }
        }
        
        return nil
        
    }
    
    
    /**
    * The following function loads the MIME types from an external file
    **/
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
        
        // New behavior of using a file
        
        Log.verbose("Loading MIME types from file")
        
        let contentTypesData = loadDataFromFile(TYPES_PATH)
        
        guard let ct = contentTypesData else {
            print("Could not find a MIME types file")
            return
        }
        
        do {
            
            // MARK: Linux Foundation will return an Any instead of an AnyObject
            // Need to test if this breaks the Linux build.
            let jsonData = try NSJSONSerialization.JSONObjectWithData(ct,
                options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            
            guard jsonData != nil else {
                Log.error("JSON could not be parsed")
                return
            }
                
            for (contentType, exts) in jsonData! {
                    
                let e = exts as! [String]
                for ext in e {
                 
                    extToContentType[ext] = contentType as? String

                }
            }
                
            
        } catch {
                
            Log.error("Error reading \(TYPES_PATH)")
            return
        }
        
    }
    
    
    public class func contentTypeForExtension (ext: String) -> String? {
        return extToContentType[ext]
    }
    
    
    public class func isType (messageContentType: String, typeDescriptor: String) -> Bool {
        let type = typeDescriptor.lowercaseString
        let typeAndSubtype = messageContentType.bridge().componentsSeparatedByString(";")[0].lowercaseString
        
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
        let messageTypePair = typeAndSubtype.bridge().componentsSeparatedByString("/")
        let normalizedTypePair = normalizedType.bridge().componentsSeparatedByString("/")
        if messageTypePair.count == 2 && normalizedTypePair.count == 2
            && messageTypePair[0] == normalizedTypePair[0] && normalizedTypePair[1] == "*" {
            return true
        }
        return false
    }
    
    
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
        
    ]
    
}
