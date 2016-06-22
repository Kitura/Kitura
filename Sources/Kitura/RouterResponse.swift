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
    struct State {
        ///
        /// Whether the response has ended
        ///
        var invokedEnd = false

        ///
        /// Whether data has been added to buffer
        ///
        var invokedSend = false
    }

    ///
    /// The server response
    ///
    let response: ServerResponse

    ///
    /// The router
    ///
    unowned let router: Router

    ///
    /// The associated request
    ///
    let request: RouterRequest

    ///
    /// The buffer used for output
    ///
    private let buffer = BufferList()

    ///
    /// State of the request
    ///
    var state = State()

    //
    // Lifecycle hook called on end()
    //
    private var onEndInvoked: LifecycleHandler = {}
    
    //
    // Current pre-write lifecycle handler
    //
    private var writtenDataFilter: WrittenDataFilter = {body in return body}

    ///
    /// Set of cookies to return with the response
    ///
    public var cookies = [String: NSHTTPCookie]()

    ///
    /// Optional error value
    ///
    public var error: ErrorProtocol?
    
    public var headers: Headers

    public var statusCode: HTTPStatusCode {
        get {
            return response.statusCode ?? .unknown
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
        headers = Headers(headers: response.headers)
        statusCode = .unknown
    }

    ///
    /// Ends the response
    ///
    /// - Throws: ???
    /// - Returns: a RouterResponse instance
    ///
    @discardableResult
    public func end() throws {

        onEndInvoked()
        
        // Sets status code if unset
        if statusCode == .unknown {
            statusCode = .OK
        }

        if  let data = buffer.data {
            let content = writtenDataFilter(body: data)
            let contentLength = headers["Content-Length"]
            if  contentLength == nil {
                headers["Content-Length"] = String(content.length)
            }
            addCookies()

            if  request.method != .head {
                try response.write(from: content)
            }
        }
        state.invokedEnd = true
        try response.end()
    }

    //
    // Add Set-Cookie headers
    //
    private func addCookies() {
        var cookieStrings = [String]()

        for  (_, cookie) in cookies {
            var cookieString = cookie.name + "=" + cookie.value + "; path=" + cookie.path + "; domain=" + cookie.domain
            if  let expiresDate = cookie.expiresDate {
                cookieString += "; expires=" + SPIUtils.httpDate(expiresDate)
            }

            if  cookie.isSecure  {
                cookieString += "; secure; HTTPOnly"
            }

            cookieStrings.append(cookieString)
        }
        response.headers.append("Set-Cookie", value: cookieStrings)
    }

    ///
    /// Ends the response and sends a string
    ///
    /// - Parameter str: the String before the response ends
    ///
    /// - Throws: ???
    /// - Returns: a RouterResponse instance
    ///
    public func end(_ str: String) throws {

        send(str)
        try end()

    }

    ///
    /// Ends the response and sends data
    ///
    /// - Parameter data: the data to send before the response ends
    ///
    /// - Throws: ???
    /// - Returns: a RouterResponse instance
    ///
    public func end(_ data: NSData) throws {

        send(data: data)
        try end()

    }

    ///
    /// Sends a string
    ///
    /// - Parameter str: the string to send
    ///
    /// - Returns: a RouterResponse instance
    ///
    @discardableResult
    public func send(_ str: String) -> RouterResponse {

        if  let data = StringUtils.toUtf8String(str)  {
            send(data: data)
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
    @discardableResult
    public func send(data: NSData) -> RouterResponse {

        buffer.append(data: data)
        state.invokedSend = true
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
    @discardableResult
    public func send(fileName: String) throws -> RouterResponse {
        let data = try NSData(contentsOfFile: fileName, options: [])

        let contentType =  ContentType.sharedInstance.getContentType(forFileName: fileName)
        if  let contentType = contentType {
            headers["Content-Type"] = contentType
        }

        send(data: data)

        return self
    }

    ///
    /// Sends JSON
    ///
    /// - Parameter json: the JSON object to send
    ///
    /// - Returns: a RouterResponse instance
    ///
    @discardableResult
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
    @discardableResult
    public func status(_ status: HTTPStatusCode) -> RouterResponse {
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
    public func send(status: HTTPStatusCode) throws -> RouterResponse {

        self.status(status)
        if let statusCode = HTTP.statusCodes[status.rawValue] {
            send(statusCode)
        }
        return self

    }

    ///
    /// Redirect to path
    ///
    /// - Parameter: the path for the redirect
    ///
    /// - Returns: a RouterResponse instance
    ///
    @discardableResult
    public func redirect(_ path: String) throws -> RouterResponse {
        return try redirect(.movedTemporarily, path: path)
    }

    ///
    /// Redirect to path with status code
    ///
    /// - Parameter: the status code for the redirect
    /// - Parameter: the path for the redirect
    ///
    /// - Returns: a RouterResponse instance
    ///
    public func redirect(_ status: HTTPStatusCode, path: String) throws -> RouterResponse {

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
            if let referrer = headers["referrer"] {
                p = referrer
            } else {
                p = "/"
            }
        }
        headers["Location"] = p
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
        let renderedResource = try router.render(template: resource, context: context)
        return send(renderedResource)
    }

    ///
    /// Sets the Content-Type HTTP header
    ///
    /// - Parameter type: the type to set to
    ///
    public func type(_ type: String, charset: String? = nil) {
        if  let contentType = ContentType.sharedInstance.getContentType(forExtension: type) {
            var contentCharset = ""
            if let charset = charset {
                contentCharset = "; charset=\(charset)"
            }
            headers["Content-Type"] = contentType + contentCharset
        }
    }

    ///
    /// Sets the Content-Disposition to "attachment" and optionally
    /// sets filename parameter in Content-Disposition and Content-Type
    ///
    /// - Parameter filePath: the file to set the filename to
    ///
    public func prepareAttachment(for filePath: String? = nil) {
        guard let filePath = filePath else {
            headers["Content-Disposition"] = "attachment"
            return
        }

        let filePaths = filePath.characters.split {$0 == "/"}.map(String.init)
        guard let fileName = filePaths.last else {
            return
        }
        headers["Content-Disposition"] = "attachment; fileName = \"\(fileName)\""

        let contentType =  ContentType.sharedInstance.getContentType(forFileName: fileName)
        if  let contentType = contentType {
            headers["Content-Type"] = contentType
        }
    }

    ///
    /// Sets headers and attaches file for downloading
    ///
    /// - Parameter filePath: the file to download
    ///
    public func send(download: String) throws {
        try send(fileName: download)
        prepareAttachment(for: download)
    }

    ///
    /// Sets the pre-flush lifecycle handler and returns the previous one
    ///
    /// - Parameter newPreFlush: The new pre-flush lifecycle handler
    public func setOnEndInvoked(_ newOnEndInvoked: LifecycleHandler) -> LifecycleHandler {
        let oldOnEndInvoked = onEndInvoked
        onEndInvoked = newOnEndInvoked
        return oldOnEndInvoked
    }

    
    ///
    /// Sets the written data filter and returns the previous one
    ///
    /// - Parameter newWrittenDataFilter: The new written data filter
    public func setWrittenDataFilter(_ newWrittenDataFilter: WrittenDataFilter) -> WrittenDataFilter {
        let oldWrittenDataFilter = writtenDataFilter
        writtenDataFilter = newWrittenDataFilter
        return oldWrittenDataFilter
    }

    ///
    /// Performs content-negotiation on the Accept HTTP header on the request, when present. It uses
    /// request.accepts() to select a handler for the request, based on the acceptable types ordered by their
    /// quality values. If the header is not specified, the default callback is invoked. When no match is found,
    /// the server invokes the default callback if exists, or responds with 406 “Not Acceptable”.
    /// The Content-Type response header is set when a callback is selected.
    ///
    /// - Parameter callbacks: a dictionary that maps content types to handlers
    ///
    public func format(callbacks: [String : ((RouterRequest, RouterResponse) -> Void)]) throws {
        let callbackTypes = Array(callbacks.keys)
        if let acceptType = request.accepts(types: callbackTypes) {
            headers["Content-Type"] = acceptType
            callbacks[acceptType]!(request, self)
        }
        else if let defaultCallback = callbacks["default"] {
            defaultCallback(request, self)
        }
        else {
            try status(.notAcceptable).end()
        }
    }

    ///
    /// Adds a link with specified parameters to Link HTTP header
    ///
    /// - Parameter link: link value
    /// - Parameter linkParameters: the link parameters (according to RFC 5988) with their values
    ///
    /// - Returns: a RouterResponse instance
    ///
    public func addLink(_ link: String, linkParameters: [LinkParameter: String]) -> RouterResponse {
        var headerValue = "<\(link)>"

        for (linkParamer, value) in linkParameters {
            headerValue += "; \(linkParamer.rawValue)=\"\(value)\""
        }

        headers.append("Link", value: headerValue)
        return self
    }
}

///
/// Type alias for "Before flush" (i.e. before headers and body are written) lifecycle handler
public typealias LifecycleHandler = () -> Void

//
/// Type alias for written data filter, i.e. pre-write lifecycle handler
public typealias WrittenDataFilter = (body: NSData) -> NSData

