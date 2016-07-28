/*
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
 */

import Foundation
import KituraNet

/// Headers
public struct Headers {
    
    /// The header storage
    internal var headers: HeadersContainer
    
    /// Initialize a `Headers`
    ///
    /// - Parameter headers: the container for the headers
    init(headers: HeadersContainer) {
        self.headers = headers
    }
    
    /// Append values to the header
    ///
    /// - Parameter key: the key
    /// - Parameter value: the value
    public mutating func append(_ key: String, value: String) {
        headers.append(key, value: value)
    }
}

/// Conformance to `Collection`
extension Headers: Collection {
    
    public var startIndex: HeadersIndex {
        return headers.startIndex
    }

    public var endIndex: HeadersIndex {
        return headers.endIndex
    }
    
    public typealias HeadersIndex = DictionaryIndex<String, [String]>
    
    public subscript(key: String) -> String? {
        get {
            return headers[key]?.first
        }
        
        set(newValue) {
            if let newValue = newValue {
                headers[key] = [newValue]
            } else {
                headers[key] = nil
            }
        }
    }
    
    public subscript(position: HeadersIndex) -> (String, String?) {
        get {
            let (key, value) = headers[position]
            return (key, value.first)
        }
    }
    
    public func index(after i: HeadersIndex) -> HeadersIndex {
        return headers.index(after: i)
    }
}

/// Various helper methods
extension Headers {

    /// Sets the location path
    ///
    /// - Parameter path: the path
    public mutating func setLocation(_ path: String) {
        var p = path
        if  p == "back" {
            if let referrer = self["referrer"] {
                p = referrer
            } else {
                p = "/"
            }
        }
        self["Location"] = p
    }

    /// Sets the Content-Type HTTP header
    ///
    /// - Parameter type: the type to set to
    /// - Parameter charset: the charset to specify
    public mutating func setType(_ type: String, charset: String? = nil) {
        if  let contentType = ContentType.sharedInstance.getContentType(forExtension: type) {
            var contentCharset = ""
            if let charset = charset {
                contentCharset = "; charset=\(charset)"
            }
            self["Content-Type"] = contentType + contentCharset
        }
    }

    /// Sets the Content-Disposition to "attachment" and optionally
    /// sets filename parameter in Content-Disposition and Content-Type
    ///
    /// - Parameter for: the file to set the filename to
    public mutating func addAttachment(for filePath: String? = nil) {
        guard let filePath = filePath else {
            self["Content-Disposition"] = "attachment"
            return
        }

        let filePaths = filePath.characters.split {$0 == "/"}.map(String.init)
        guard let fileName = filePaths.last else {
            return
        }
        self["Content-Disposition"] = "attachment; fileName = \"\(fileName)\""

        let contentType =  ContentType.sharedInstance.getContentType(forFileName: fileName)
        if  let contentType = contentType {
            self["Content-Type"] = contentType
        }
    }

    /// Adds a link with specified parameters to Link HTTP header
    ///
    /// - Parameter link: link value
    /// - Parameter linkParameters: the link parameters (according to RFC 5988) with their values
    public mutating func addLink(_ link: String, linkParameters: [LinkParameter: String]) {
        var headerValue = "<\(link)>"

        for (linkParamer, value) in linkParameters {
            headerValue += "; \(linkParamer.rawValue)=\"\(value)\""
        }

        self.append("Link", value: headerValue)
    }
}
