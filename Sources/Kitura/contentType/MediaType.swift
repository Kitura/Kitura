/*
 * Copyright IBM Corporation 2018
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

import KituraNet

public struct MediaType: CustomStringConvertible {
    
    public enum TopLevelType: String {
        case application = "application"
        case audio = "audio"
        case font = "font"
        case image = "image"
        case message = "message"
        case model = "model"
        case multipart = "multipart"
        case text = "text"
        case video = "video"
    }
    
    let topLevelType: TopLevelType
    
    let subtype: String
    
    init(type: TopLevelType, subtype: String = "*") {
        self.topLevelType = type
        self.subtype = subtype.lowercased()
    }
    
    init? (_ mimeType: String) {
        let mimeComponents = mimeType
            .lowercased()
            .components(separatedBy: "/")
        guard let topLevelType = TopLevelType(rawValue: mimeComponents[0]) else {
            return nil
        }
        self.topLevelType = topLevelType
        if mimeComponents.indices.contains(1) && !mimeComponents[1].isEmpty {
            self.subtype = mimeComponents[1]
        } else {
            self.subtype = "*"
        }
    }
    
    init? (headers: HeadersContainer) {
        let contentType = headers["Content-Type"]?[0]
        guard let contentTypeComponents = contentType?.components(separatedBy: ";") else {
            return nil
        }
        self.init(contentTypeComponents[0])
    }
    
    public var description: String {
        return "\(topLevelType)/\(subtype)"
    }
    
    /// "application/json" content type
    public static let json = MediaType(type: .application, subtype: "json")
    
    /// "application/x-www-form-urlencoded" content type
    public static let urlEncoded = MediaType(type: .application, subtype: "x-www-form-urlencoded")
    
    /// "application/json" content type
    public static let html = MediaType(type: .text, subtype: "html")
}

