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

/**
 The media type (formerly known as MIME type) is a standardized way to indicate the nature and format of a document.
 This struct consists of a catagorical `topLevelType` and specific `subtype` seperated by a "/" (e.g. "text/plain").
 In HTTP, The media type is sent as the first section of the "Content-Type" header and is case insensitive.
 ### Usage Example: ###
 ```swift
 let mediaType = MediaType(type: .application, subtype: "json")
 print(mediaType.description)
 // Prints ("application/json")
 ```
 */
public struct MediaType: CustomStringConvertible {
    
    /// An enum of all recognized top-level media types (categories). See:
    /// https://www.iana.org/assignments/media-types/media-types.xhtml
    public enum TopLevelType: String {
        /// The top-level type for application, eg. `application/json`
        case application
        /// The top-level type for audio, eg. `audio/mpeg`
        case audio
        /// The top-level type for font, eg. `font/ttf`
        case font
        /// The top-level type for image, eg. `image/jpeg`
        case image
        /// The top-level type for message, eg. `message/global`
        case message
        /// The top-level type for model, eg. `model/vrml`
        case model
        /// The top-level type for multipart, eg. `multipart/form-data`
        case multipart
        /// The top-level type for text, eg. `text/csv`
        case text
        /// The top-level type for video, eg. `video/mp4`
        case video
    }
    
    // MARK: Media type components
    
    /// The topLevelType represents the category of the MediaType (e.g. "audio").
    public let topLevelType: TopLevelType
    
    /// The subtype is the specific MediaType (e.g. "html").
    public let subType: String
    
    // MARK: Initializers
    
    /**
     Initialize a `MediaType` instance with a `TopLevelType` type and `String` subtype. If no subtype is provided it will default to "*" representing all subtypes.
     ### Usage Example: ###
     ```swift
     let mediaType = MediaType(type: .application, subtype: "json")
     ```
     */
    public init(type: TopLevelType, subType: String = "*") {
        self.topLevelType = type
        self.subType = subType.lowercased()
        self.description = "\(self.topLevelType)/\(self.subType)"
    }
    
    /**
     Initialize a `MediaType` instance from a `String`. If no subtype is provided it will default to "*" representing all subtypes.
     If the string preceding the first "/" is not a valid `TopLevelType` the initializer will return nil.
     ### Usage Example: ###
     ```swift
     let mediaType = MediaType("application/json")
     ```
     */
    public init? (_ mimeType: String) {
        let mimeComponents = mimeType
            .lowercased()
            .split(separator: "/", maxSplits: 1)
        guard let topLevelType = TopLevelType(rawValue: String(mimeComponents[0])) else {
            return nil
        }
        self.topLevelType = topLevelType
        if mimeComponents.indices.contains(1) && !mimeComponents[1].isEmpty {
            self.subType = String(mimeComponents[1])
        } else {
            self.subType = "*"
        }
        //self.description = "\(self.topLevelType)/\(self.subType)"
        self.description = self.topLevelType.rawValue.appending("/").appending(self.subType)
    }
    
    /**
     Initialize a `MediaType` instance from a Content-Type header. This will extract the media type String from the first section of the header and use this to initialize itself. If the string preceding the first "/" is not a valid `TopLevelType` the initializer will return nil.
     ### Usage Example: ###
     ```swift
     let mediaType = MediaType(contentTypeHeader: "text/plain; charset=utf-8")
     ```
     */
    init? (contentTypeHeader: String) {
        let mediaType = contentTypeHeader.prefix {
            char in
            return char != ";"
        }
        self.init(String(mediaType))
    }
    
    // MARK: Helper Constructors
    
    /**
     Helper constructor for the "application/json" media type
     ### Usage Example: ###
     ```swift
     let mediaType = MediaType.json
     print(mediaType.description)
     // Prints ("application/json")
     ```
     */
    public static let json = MediaType(type: .application, subType: "json")
    
    /**
     Helper constructor for the "application/x-www-form-urlencoded" media type
     ### Usage Example: ###
     ```swift
     let mediaType = MediaType.urlEncoded
     print(mediaType.description)
     // Prints ("application/x-www-form-urlencoded")
     ```
     */
    public static let urlEncoded = MediaType(type: .application, subType: "x-www-form-urlencoded")
    
    // MARK: Protocol conformance
    
    /**
     Returns the media type, as a String structured: `topLevelType`/`subtype`. Required for CustomStringConvertible conformance.
     ### Usage Example: ###
     ```swift
     print(mediaType.description)
     // Prints ("application/json")
     ```
     */
    public let description: String
    

}

extension MediaType: Equatable {
    #if !swift(>=4.1)
    /// Compares two MediaTypes returning true if they are equal. Required for Equatable conformance.
    public static func == (lhs: MediaType, rhs: MediaType) -> Bool {
        return lhs.description == rhs.description
    }
    #endif
}

extension MediaType: Hashable {
    #if !swift(>=4.1)
    // A unique integer produced by hashing the MediaType. Required for Hashable conformance.
    public var hashValue: Int {
        return description.hashValue
    }
    #endif
}
