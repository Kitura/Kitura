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

import KituraNet
import KituraSys

// For JSON parsing support
import SwiftyJSON

import Foundation
import LoggerAPI

// MARK: RouterResponse

public class RouterResponse {

    ///
    /// The server response
    ///
    let response: ServerResponse

    ///
    /// The router
    ///
    weak var router: Router?

    ///
    /// The associated request
    ///
    let request: RouterRequest

    ///
    /// The buffer used for output
    ///
    private let buffer = BufferList()

    ///
    /// Whether the response has ended
    ///
    var invokedEnd = false

    //
    // Current pre-flush lifecycle handler
    //
    private var preFlush: PreFlushLifecycleHandler = {request, response in }

    ///
    /// Set of cookies to return with the response
    ///
    public var cookies = [String: NSHTTPCookie]()

    ///
    /// Optional error value
    ///
    public var error: ErrorProtocol?
    
    public var statusCode: HttpStatusCode {
        get {
            return response.statusCode ?? .UNKNOWN
        }
        
        set(newValue) {
            response.statusCode = newValue
        }
    }

    ///
    /// Initializes a RouterResponse instance
    ///
    /// - Parameter response: the server response
    ///
    /// - Returns: a ServerResponse instance
    ///
    init(response: ServerResponse, router: Router, request: RouterRequest) {

        self.response = response
        self.router = router
        self.request = request
        status(HttpStatusCode.NOT_FOUND)
    }

    ///
    /// Ends the response
    ///
    /// - Throws: ???
    /// - Returns: a RouterResponse instance
    ///
    public func end() throws -> RouterResponse {

        preFlush(request: request, response: self)

        if  let data = buffer.data {
            let contentLength = getHeader("Content-Length")
            if  contentLength == nil {
                setHeader("Content-Length", value: String(buffer.count))
            }
            addCookies()

            if  request.method != .Head {
                try response.write(from: data)
            }
        }
        invokedEnd = true
        try response.end()
        return self
    }

    //
    // Add Set-Cookie headers
    //
    private func addCookies() {
        var cookieStrings = [String]()

        for  (_, cookie) in cookies {
            var cookieString = cookie.name + "=" + cookie.value + "; path=" + cookie.path + "; domain=" + cookie.domain
            if  let expiresDate = cookie.expiresDate {
                cookieString += "; expires=" + SpiUtils.httpDate(expiresDate)
            }
#if os(Linux)
            let isSecure = cookie.secure
#else
            let isSecure = cookie.isSecure
#endif
            if  isSecure  {
                cookieString += "; secure; HttpOnly"
            }

            cookieStrings.append(cookieString)
        }
        setHeader("Set-Cookie", value: cookieStrings)
    }

    ///
    /// Ends the response and sends a string
    ///
    /// - Parameter str: the String before the response ends
    ///
    /// - Throws: ???
    /// - Returns: a RouterResponse instance
    ///
    public func end(_ str: String) throws -> RouterResponse {
        
        send(str)
        try end()
        return self

    }

    ///
    /// Ends the response and sends data
    ///
    /// - Parameter data: the data to send before the response ends
    ///
    /// - Throws: ???
    /// - Returns: a RouterResponse instance
    ///
    public func end(_ data: NSData) throws -> RouterResponse {
        
        send(data: data)
        try end()
        return self

    }

    ///
    /// Sends a string
    ///
    /// - Parameter str: the string to send
    ///
    /// - Returns: a RouterResponse instance
    ///
    public func send(_ str: String) -> RouterResponse {
        
        if  let data = StringUtils.toUtf8String(str)  {
            buffer.append(data: data)
        }
        return self

    }

    ///
    /// Sends data
    ///
    /// - Parameter data: the data to send
    ///
    /// - Returns: a RouterResponse instance
    ///
    public func send(data: NSData) -> RouterResponse {
        
        buffer.append(data: data)
        return self

    }

    ///
    /// Sends a file
    ///
    /// - Parameter fileName: the name of the file to send.
    ///
    /// - Returns: a RouterResponse instance
    ///
    /// Note: Sets the Content-Type header based on the "extension" of the file
    ///       If the fileName is relative, it is relative to the current directory
    ///
    public func send(fileName: String) throws -> RouterResponse {
        let data = try NSData(contentsOfFile: fileName, options: [])

        let contentType =  ContentType.sharedInstance.contentTypeForFile(fileName)
        if  let contentType = contentType {
            setHeader("Content-Type", value: contentType)
        }

        buffer.append(data: data)

        return self
    }

    ///
    /// Sends JSON
    ///
    /// - Parameter json: the JSON object to send
    ///
    /// - Returns: a RouterResponse instance
    ///
    public func send(json: JSON) -> RouterResponse {
        
        let jsonStr = json.description
        type("json")
        send(jsonStr)
        return self
    }

    ///
    /// Set the status code
    ///
    /// - Parameter status: the status code object
    ///
    /// - Returns: a RouterResponse instance
    ///
    public func status(_ status: HttpStatusCode) -> RouterResponse {
        response.statusCode = status
        return self
    }

    ///
    /// Sends the status code
    ///
    /// - Parameter status: the status code object
    ///
    /// - Throws: ???
    /// - Returns: a RouterResponse instance
    ///
    public func send(status: HttpStatusCode) throws -> RouterResponse {
        
        self.status(status)
        send(Http.statusCodes[status.rawValue]!)
        return self

    }

    ///
    /// Gets the header
    ///
    /// - Parameter key: the key
    ///
    /// - Returns: the value for the key
    ///
    public func getHeader(_ key: String) -> String? {
        
        return response.getHeader(key)

    }

    ///
    /// Gets the header that contains multiple values
    ///
    /// - Parameter key: the key
    ///
    /// - Returns: the value for the key as a list
    ///
    public func getHeaders(_ key: String) -> [String]? {
        
        return response.getHeaders(key)

    }

    ///
    /// Set the header value
    ///
    /// - Parameter key: the key
    /// - Parameter value: the value
    ///
    /// - Returns: the value for the key as a list
    ///
    public func setHeader(_ key: String, value: String) {
        
        response.setHeader(key, value: value)

    }
    
    public func setHeader(_ key: String, value: [String]) {
        
        response.setHeader(key, value: value)

    }

    ///
    /// Append a value to the header
    ///
    /// - Parameter key: the header key
    ///
    public func append(_ key: String, value: String) {

        response.append(key: key, value: value)

    }

    ///
    /// Append values to the header
    ///
    /// - Parameter key: the key
    ///
    public func append(_ key: String, value: [String]) {

        response.append(key: key, value: value)

    }

    ///
    /// Remove the header by key
    ///
    /// - Parameter key: the key
    ///
    public func removeHeader(_ key: String) {
        
        response.removeHeader(key: key)
        
    }

    ///
    /// Redirect to path
    ///
    /// - Parameter: the path for the redirect
    ///
    /// - Returns: a RouterResponse instance
    ///
    public func redirect(_ path: String) throws -> RouterResponse {
        return try redirect(.MOVED_TEMPORARILY, path: path)
    }

    ///
    /// Redirect to path with status code
    ///
    /// - Parameter: the status code for the redirect
    /// - Parameter: the path for the redirect
    ///
    /// - Returns: a RouterResponse instance
    ///
    public func redirect(_ status: HttpStatusCode, path: String) throws -> RouterResponse {

        try self.status(status).location(path).end()
        return self

    }

    ///
    /// Sets the location path
    ///
    /// - Parameter path: the path
    ///
    /// - Returns: a RouterResponse instance
    ///
    public func location(_ path: String) -> RouterResponse {
        
        var p = path
        if  p == "back" {
            let referrer = getHeader("referrer")
            if  let r = referrer {
                p = r
            } else {
                p = "/"
            }
        }
        setHeader("Location", value: p)
        return self

    }

    ///
    /// Renders a resource using Router's template engine
    ///
    /// - Parameter resource: the resource name without extension
    ///
    /// - Returns: a RouterResponse instance
    ///
    // influenced by http://expressjs.com/en/4x/api.html#app.render
    public func render(_ resource: String, context: [ String: Any]) throws -> RouterResponse {
        guard let router = router else {
            throw InternalError.NilVariable(variable: "router")
        }
        let renderedResource = try router.render(resource, context: context)
        return send(renderedResource)
    }

    ///
    /// Sets the Content-Type HTTP header
    ///
    /// - Parameter type: the type to set to
    ///
    public func type(_ type: String, charset: String? = nil) {
        if  let contentType = ContentType.sharedInstance.contentTypeForExtension(type) {
            var contentCharset = ""
            if let charset = charset {
                contentCharset = "; charset=\(charset)"
            }
            setHeader("Content-Type", value:  contentType + contentCharset)
        }
    }

    ///
    /// Sets the Content-Disposition to "attachment" and optionally
    /// sets filename parameter in Content-Disposition and Content-Type
    ///
    /// - Parameter filePath: the file to set the filename to
    ///
    public func attachment(_ filePath: String? = nil) {
        guard let filePath = filePath else {
            setHeader("Content-Disposition", value: "attachment")
            return
        }

        let filePaths = filePath.characters.split {$0 == "/"}.map(String.init)
        let fileName = filePaths.last
        setHeader("Content-Disposition", value: "attachment; fileName = \"\(fileName!)\"")

        let contentType =  ContentType.sharedInstance.contentTypeForFile(fileName!)
        if  let contentType = contentType {
            setHeader("Content-Type", value: contentType)
        }
    }

    ///
    /// Sets headers and attaches file for downloading
    ///
    /// - Parameter filePath: the file to download
    ///
    public func download(_ filePath: String) throws {
        try send(fileName: filePath)
        attachment(filePath)
    }

    ///
    /// Sets the pre-flush lifecycle handler and returns the previous one
    ///
    /// - Parameter newPreFlush: The new pre-flush lifecycle handler
    public func setPreFlushHandler(_ newPreFlush: PreFlushLifecycleHandler) -> PreFlushLifecycleHandler {
        let oldPreFlush = preFlush
        preFlush = newPreFlush
        return oldPreFlush
    }
}

///
/// Type alias for "Before flush" (i.e. before headers and body are written) lifecycle handler
public typealias PreFlushLifecycleHandler = (request: RouterRequest, response: RouterResponse) -> Void
