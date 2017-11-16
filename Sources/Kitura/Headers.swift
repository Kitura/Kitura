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

/// The struct containing the HTTP headers and implements the headers APIs for the
/// `RouterRequest` and `RouterResponse` classes.
public struct Headers {

    /// The header storage
    internal var headers: HeadersContainer

    /// Initialize a `Headers` instance
    ///
    /// - Parameter headers: The container for the headers
    init(headers: HeadersContainer) {
        self.headers = headers
    }

    /// Append values to the header
    ///
    /// - Parameter key: The key of the header to append a value to.
    /// - Parameter value: The value to be appended to the specified header.
    public mutating func append(_ key: String, value: String) {
        headers.append(key, value: value)
    }
}

/// Conformance to the `Collection` protocol
extension Headers: Collection {

    /// The starting index of the `Headers` collection
    public var startIndex: HeadersIndex {
        return headers.startIndex
    }

    /// The ending index of the `Headers` collection
    public var endIndex: HeadersIndex {
        return headers.endIndex
    }

    /// The type of an Index of the `Headers` collection.
    public typealias HeadersIndex = HeadersContainer.Index

    /// Get the value of a HTTP header
    ///
    /// - Parameter key: The HTTP header key whose value is to be retrieved
    ///
    /// - Returns: The value of the specified HTTP header, or nil, if it doesn't exist.
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

    /// Get a (key value) tuple from the `Headers` collection at the specified position.
    ///
    /// - Parameter position: The position in the `Headers` collection of the (key, value)
    ///                      tuple to return.
    ///
    /// - Returns: A (key, value) tuple.
    public subscript(position: HeadersIndex) -> (String, String?) {
        get {
            let (key, value) = headers[position]
            return (key, value.first)
        }
    }

    /// Get the next Index in the `Headers` collection after the one specified.
    ///
    /// - Parameter after: The Index whose successor is to be returned.
    ///
    /// - Returns: The Index in the `Headers` collection after the one specified.
    //  swiftlint:disable variable_name
    public func index(after i: HeadersIndex) -> HeadersIndex {
        return headers.index(after: i)
    }
    //  swiftlint:enable variable_name
}

/// Various convenience methods for setting various HTTP headers
extension Headers {

    /// Sets the Location HTTP header
    ///
    /// - Parameter path: the path to set into the header or the special reserved word "back".
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
    /// - Parameter type: The type to set in the Content-Type header
    /// - Parameter charset: The charset to specify in the Content-Type header.
    public mutating func setType(_ type: String, charset: String? = nil) {
        if  let contentType = ContentType.sharedInstance.getContentType(forExtension: type) {
            var contentCharset = ""
            if let charset = charset {
                contentCharset = "; charset=\(charset)"
            }
            self["Content-Type"] = contentType + contentCharset
        }
    }

    /// Sets the HTTP header Content-Disposition to "attachment", optionally
    /// adding the filename parameter. If a file is specified the HTTP header
    /// Content-Type will be set based on the extension of the specified file.
    ///
    /// - Parameter for: The file to set the filename to
    public mutating func addAttachment(for filePath: String? = nil) {
        guard let filePath = filePath else {
            self["Content-Disposition"] = "attachment"
            return
        }

        let filePaths = filePath.split {$0 == "/"}.map(String.init)
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
    /// - Parameter linkParameters: The link parameters (according to RFC 5988) with their values
    public mutating func addLink(_ link: String, linkParameters: [LinkParameter: String]) {
        var headerValue = "<\(link)>"

        for (linkParamer, value) in linkParameters {
            headerValue += "; \(linkParamer.rawValue)=\"\(value)\""
        }

        self.append("Link", value: headerValue)
    }
}
