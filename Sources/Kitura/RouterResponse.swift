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

import KituraNet
import KituraTemplateEngine
import LoggerAPI
import Foundation
import KituraContracts


// MARK: RouterResponse

/// Router response that the server sends as a reply to `RouterRequest`.
public class RouterResponse {

    struct State {
        weak var response: RouterResponse?

        /// Whether the response has ended
        var invokedEnd = false

        /// Whether data has been added to buffer
        var invokedSend = false {
            didSet {
                if invokedSend && response?.statusCode == .unknown {
                    // change statusCode to .OK
                    response?.statusCode = .OK
                }
            }
        }
    }

    /// A set of functions called during the life cycle of a Request.
    /// As The life cycle functions/closures may capture various things including the
    /// response object in question, each life cycle function needs a reset function
    /// to clear out any reference cycles that may have occurred.
    struct Lifecycle {

        /// Lifecycle hook called on end()
        var onEndInvoked: LifecycleHandler = {}

        /// Current pre-write lifecycle handler
        var writtenDataFilter: WrittenDataFilter = { body in
            return body
        }

        mutating func resetOnEndInvoked() {
            onEndInvoked = {}
        }

        mutating func resetWrittenDataFilter() {
            writtenDataFilter = { body in
                return body
            }
        }
    }

    /// The server response
    let response: ServerResponse

    /// The router stack
    private var routerStack: Stack<Router>

    /// The associated request
    let request: RouterRequest

    /// The buffer used for output
    private let buffer = BufferList()

    /// State of the request
    var state = State()

    private var lifecycle = Lifecycle()

    private let encoder = JSONEncoder()

    // regex used to sanitize javascript identifiers
    fileprivate static let sanitizeJSIdentifierRegex: NSRegularExpression! = {
        do {
            return try NSRegularExpression(pattern: "[^\\[\\]\\w$.]", options: [])
        } catch { // pattern is a known valid literal, should never throw
            Log.error("Error initializing sanitizeJSIdentifierRegex: \(error)")
            return nil
        }
    }()

    /// Set of cookies to return with the response.
    public var cookies = [String: HTTPCookie]()

    /// Optional error value.
    public var error: Swift.Error?

    /// HTTP headers of the response.
    public var headers: Headers

    /// HTTP status code of the response.
    public var statusCode: HTTPStatusCode {
        get {
            return response.statusCode ?? .unknown
        }

        set(newValue) {
            response.statusCode = newValue
        }
    }

    /// User info.
    /// Can be used by middlewares and handlers to store and pass information on to subsequent handlers.
    public var userInfo: [String: Any] = [:]
    
    /// Initialize a `RouterResponse` instance
    ///
    /// - Parameter response: The `ServerResponse` object to work with
    /// - Parameter routerStack: The stack of `Router` instances that this `RouterResponse` is
    ///                    working with.
    /// - Parameter request: The `RouterRequest` object that is paired with this
    ///                     `RouterResponse` object.
    init(response: ServerResponse, routerStack: Stack<Router>, request: RouterRequest) {
        self.response = response
        self.routerStack = routerStack
        self.request = request
        headers = Headers(headers: response.headers)
        statusCode = .unknown
        state.response = self
    }

    deinit {
        if !state.invokedEnd {
            if !state.invokedSend && statusCode == .unknown {
                statusCode = .serviceUnavailable
            }

            do {
                try end()
            } catch {
                Log.warning("Error in RouterResponse end(): \(error)")
            }
        }
    }

    /// End the response.
    ///
    /// - Throws: Socket.Error if an error occurred while writing to a socket.
    public func end() throws {
        guard !state.invokedEnd else {
            Log.warning("RouterResponse end() invoked more than once for \(self.request.urlURL)")
            return
        }
        lifecycle.onEndInvoked()
        lifecycle.resetOnEndInvoked()

        // Sets status code if unset
        if statusCode == .unknown {
            statusCode = .OK
        }

        let content = lifecycle.writtenDataFilter(buffer.data)
        lifecycle.resetWrittenDataFilter()

        let contentLength = headers["Content-Length"]
        if  contentLength == nil {
            headers["Content-Length"] = String(content.count)
        }

        if cookies.count > 0 {
            addCookies()
        }

        if  request.method != .head {
            try response.write(from: content)
        }
        state.invokedEnd = true
        try response.end()
    }

    /// Add Set-Cookie headers
    private func addCookies() {
        var cookieStrings = [String]()

        for  (_, cookie) in cookies {
            var cookieString = cookie.name + "=" + cookie.value + "; path=" + cookie.path + "; domain=" + cookie.domain
            if  let expiresDate = cookie.expiresDate {
                cookieString += "; expires=" + SPIUtils.httpDate(expiresDate)
            }

            if  cookie.isSecure {
                cookieString += "; secure; HTTPOnly"
            }

            cookieStrings.append(cookieString)
        }
        response.headers.append("Set-Cookie", value: cookieStrings)
    }

    /// Send a string.
    ///
    /// - Parameter str: the string to send.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func send(_ str: String) -> RouterResponse {
        guard !state.invokedEnd else {
            Log.warning("RouterResponse send(str:) invoked after end() for \(self.request.urlURL)")
            return self
        }
        let utf8Length = str.lengthOfBytes(using: .utf8)
        let bufferLength = utf8Length + 1  // Add room for the NULL terminator
        var utf8: [CChar] = [CChar](repeating: 0, count: bufferLength)
        if str.getCString(&utf8, maxLength: bufferLength, encoding: .utf8) {
            let rawBytes = UnsafeRawPointer(UnsafePointer(utf8))
            buffer.append(bytes: rawBytes.assumingMemoryBound(to: UInt8.self), length: utf8Length)
            state.invokedSend = true
        }
        return self
    }
    
    /// Send an optional string.
    ///
    /// - Parameter str: the string to send.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func send(_ str: String?) -> RouterResponse {
        guard !state.invokedEnd else {
            Log.warning("RouterResponse send(str:) invoked after end() for \(self.request.urlURL)")
            return self
        }
        guard let str = str else {
            Log.warning("RouterResponse send(str:) invoked with a nil value")
            return send("")
        }
        return send(str)
    }

    /// Send data.
    ///
    /// - Parameter data: the data to send.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func send(data: Data) -> RouterResponse {
        guard !state.invokedEnd else {
            Log.warning("RouterResponse send(data:) invoked after end() for \(self.request.urlURL)")
            return self
        }
        buffer.append(data: data)
        state.invokedSend = true
        return self
    }

    /// Send a file.
    ///
    /// - Parameter fileName: the name of the file to send.
    /// - Throws: An error in the Cocoa domain, if the file cannot be read.
    /// - Returns: this RouterResponse.
    ///
    /// - Note: Sets the Content-Type header based on the "extension" of the file.
    ///       If the fileName is relative, it is relative to the current directory.
    @discardableResult
    public func send(fileName: String) throws -> RouterResponse {
        guard !state.invokedEnd else {
            Log.warning("RouterResponse send(fileName:) invoked after end() for \(self.request.urlURL)")
            return self
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: fileName))

        let contentType = ContentType.sharedInstance.getContentType(forFileName: fileName)
        if  let contentType = contentType {
            headers["Content-Type"] = contentType
        }

        send(data: data)

        return self
    }

    typealias JSONSerializationType = JSONSerialization

    /// Send JSON.
    ///
    /// - Parameter json: The array to send in JSON format.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func send(json: [Any]) -> RouterResponse {
        guard !state.invokedEnd else {
            Log.warning("RouterResponse send(json:) invoked after end() for \(self.request.urlURL)")
            return self
        }

        do {
            let jsonData = try JSONSerializationType.data(withJSONObject: json, options:.prettyPrinted)
            headers.setType("json")
            send(data: jsonData)
        } catch {
            Log.warning("Failed to convert JSON for sending: \(error.localizedDescription)")
        }
        
        return self
    }

    /// Send JSON.
    ///
    /// - Parameter json: The Dictionary to send in JSON format as a hash.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func send(json: [String: Any]) -> RouterResponse {
        guard !state.invokedEnd else {
            Log.warning("RouterResponse send(json:) invoked after end() for \(self.request.urlURL)")
            return self
        }

        do {
            let jsonData = try JSONSerializationType.data(withJSONObject: json, options:.prettyPrinted)
            headers.setType("json")
            send(data: jsonData)
        } catch {
            Log.warning("Failed to convert JSON for sending: \(error.localizedDescription)")
        }

        return self
    }

    /// Set the status code.
    ///
    /// - Parameter status: the HTTP status code object.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func status(_ status: HTTPStatusCode) -> RouterResponse {
        response.statusCode = status
        return self
    }

    /// Send the HTTP status code.
    ///
    /// - Parameter status: the HTTP status code.
    /// - Returns: this RouterResponse.
    public func send(status: HTTPStatusCode) -> RouterResponse {
        guard !state.invokedEnd else {
            Log.warning("RouterResponse send(status:) invoked after end() for \(self.request.urlURL)")
            return self
        }
        self.status(status)
        send(HTTPURLResponse.localizedString(forStatusCode: status.rawValue))
        return self
    }

    /// Redirect to path with status code.
    ///
    /// - Parameter: the path for the redirect.
    /// - Parameter: the status code for the redirect.
    /// - Throws: Socket.Error if an error occurred while writing to a socket.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func redirect(_ path: String, status: HTTPStatusCode = .movedTemporarily) throws -> RouterResponse {
        headers.setLocation(path)
        try self.status(status).end()
        return self
    }

    // influenced by http://expressjs.com/en/4x/api.html#app.render
    /// Render a resource using Router's template engine.
    ///
    /// - Parameter resource: the resource name without extension.
    /// - Parameter context: a dictionary of local variables of the resource.
    /// - Parameter options: rendering options, specific per template engine
    /// - Throws: TemplatingError if no file extension was specified or there is no template engine defined for the extension.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func render(_ resource: String, context: [String:Any],
                       options: RenderingOptions = NullRenderingOptions()) throws -> RouterResponse {
        guard let router = getRouterThatCanRender(resource: resource) else {
            throw TemplatingError.noTemplateEngineForExtension(extension: "")
        }
        let renderedResource = try router.render(template: resource, context: context, options: options)
        return send(renderedResource)
    }
    
    /// Render a resource using Router's template engine.
    ///
    /// - Parameter resource: the resource name without extension.
    /// - Parameter with: a value that conforms to Encodable that is used to generate the content.
    /// - Parameter forKey: A value used to match the Encodable value to the correct variable in a template file.
    ///                                 The `forKey` value should match the desired variable in the template file.
    /// - Parameter options: rendering options, specific per template engine
    /// - Throws: TemplatingError if no file extension was specified or there is no template engine defined for the extension.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func render<T: Encodable>(_ resource: String, with value: T, forKey key: String? = nil,
                       options: RenderingOptions = NullRenderingOptions()) throws -> RouterResponse {
        
        guard let router = getRouterThatCanRender(resource: resource) else {
            throw TemplatingError.noTemplateEngineForExtension(extension: "")
        }
        
        let renderedResource = try router.render(template: resource, with: value, forKey: key, options: options)
        return send(renderedResource)
    }
    
    /// Render a resource using Router's template engine.
    ///
    /// - Parameter resource: the resource name without extension.
    /// - Parameter with: an array of tuples of type (Identifier, Encodable). The Encodable values are used to generate the content.
    /// - Parameter forKey: A value used to match the Encodable values to the correct variable in a template file.
    ///                                 The `forKey` value should match the desired variable in the template file.
    /// - Parameter options: rendering options, specific per template engine
    /// - Throws: TemplatingError if no file extension was specified or there is no template engine defined for the extension.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func render<I: Identifier, T: Encodable>(_ resource: String, with values: [(I, T)], forKey key: String,
                                   options: RenderingOptions = NullRenderingOptions()) throws -> RouterResponse {
        guard let router = getRouterThatCanRender(resource: resource) else {
            throw TemplatingError.noTemplateEngineForExtension(extension: "")
        }
        let items: [T] = values.map { $0.1 }
        
        let renderedResource = try router.render(template: resource, with: items, forKey: key, options: options)
        return send(renderedResource)
    }

    private func getRouterThatCanRender(resource: String) -> Router? {
        var routerStackToTraverse = routerStack

        while routerStackToTraverse.topItem != nil {
            let router = routerStackToTraverse.pop()

            if router.getTemplateEngine(template: resource) != nil {
                return router
            }
        }
        return nil
    }

    /// Push router into router stack
    ///
    /// - Parameter: router - router to push
    func push(router: Router) {
        routerStack.push(router)
    }

    /// Pop router from router stack
    func popRouter() {
        let _ = routerStack.pop()
    }

    /// Set headers and attach file for downloading.
    ///
    /// - Parameter download: the file to download.
    /// - Throws: An error in the Cocoa domain, if the file cannot be read.
    public func send(download: String) throws {
        guard !state.invokedEnd else {
            Log.warning("RouterResponse send(download:) invoked after end() for \(self.request.urlURL)")
            return
        }
        try send(fileName: StaticFileServer.ResourcePathHandler.getAbsolutePath(for: download))
        headers.addAttachment(for: download)
    }

    /// Set the pre-flush lifecycle handler and return the previous one.
    ///
    /// - Parameter newOnEndInvoked: The new pre-flush lifecycle handler.
    /// - Returns: The old pre-flush lifecycle handler.
    public func setOnEndInvoked(_ newOnEndInvoked: @escaping LifecycleHandler) -> LifecycleHandler {
        let oldOnEndInvoked = lifecycle.onEndInvoked
        lifecycle.onEndInvoked = newOnEndInvoked
        return oldOnEndInvoked
    }

    /// Set the written data filter and return the previous one.
    ///
    /// - Parameter newWrittenDataFilter: The new written data filter.
    /// - Returns: The old written data filter.
    public func setWrittenDataFilter(_ newWrittenDataFilter: @escaping WrittenDataFilter) -> WrittenDataFilter {
        let oldWrittenDataFilter = lifecycle.writtenDataFilter
        lifecycle.writtenDataFilter = newWrittenDataFilter
        return oldWrittenDataFilter
    }

    /// Perform content-negotiation on the Accept HTTP header on the request, when present.
    ///
    /// Uses request.accepts() to select a handler for the request, based on the acceptable types ordered by their
    /// quality values. If the header is not specified, the default callback is invoked. When no match is found,
    /// the server invokes the default callback if exists, or responds with 406 “Not Acceptable”.
    /// The Content-Type response header is set when a callback is selected.
    ///
    /// - Parameter callbacks: a dictionary that maps content types to handlers.
    /// - Throws: Socket.Error if an error occurred while writing to a socket.
    public func format(callbacks: [String : ((RouterRequest, RouterResponse) -> Void)]) throws {
        let callbackTypes = Array(callbacks.keys)
        if let acceptType = request.accepts(types: callbackTypes) {
            headers["Content-Type"] = acceptType
            callbacks[acceptType]!(request, self)
        } else if let defaultCallback = callbacks["default"] {
            defaultCallback(request, self)
        } else {
            try status(.notAcceptable).end()
        }
    }
}

extension RouterResponse {

    /// Send Encodable Object.
    ///
    /// - Parameter obj: the Codable object to send.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func send<T : Encodable>(_ obj: T) -> RouterResponse {
        guard !state.invokedEnd else {
            Log.warning("RouterResponse send(_ obj:) invoked after end() for \(self.request.urlURL)")
            return self
        }
        do {
            headers.setType("json")
            send(data: try encoder.encode(obj))
        } catch {
            Log.warning("Failed to encode Codable object for sending: \(error.localizedDescription)")
        }

        return self
    }

    /// Send Encodable Object JSON Convienence Method
    ///
    /// - Parameter json: the Encodable object to send.
    /// - Returns: this RouterResponse.
    @discardableResult
    public func send<T : Encodable>(json: T) -> RouterResponse {
        return send(json)
    }

    /// Send JSON with JSONP callback.
    ///
    /// - Parameter json: the JSON object to send.
    /// - Parameter callbackParameter: the name of the URL query
    /// parameter whose value contains the JSONP callback function.
    ///
    /// - Throws: `JSONPError.invalidCallbackName` if the the callback
    /// query parameter of the request URL is missing or its value is
    /// empty or contains invalid characters (the set of valid characters
    /// is the alphanumeric characters and `[]$._`).
    /// - Returns: this RouterResponse.
    public func send<T : Encodable>(jsonp: T, callbackParameter: String = "callback") throws -> RouterResponse {
        guard !state.invokedEnd else {
            Log.warning("RouterResponse send(jsonp:) invoked after end() for \(self.request.urlURL)")
            return self
        }
        func sanitizeJSIdentifier(_ ident: String) -> String {
            return RouterResponse.sanitizeJSIdentifierRegex.stringByReplacingMatches(in: ident, options: [],
                                                                                     range: NSRange(location: 0, length: ident.utf16.count), withTemplate: "")
        }
        func validJsonpCallbackName(_ name: String?) -> String? {
            if let name = name {
                if name.count > 0 && name == sanitizeJSIdentifier(name) {
                    return name
                }
            }
            return nil
        }
        func jsonToJS(_ json: String) -> String {
            // Translate JSON characters that are invalid in javascript
            return json.replacingOccurrences(of: "\u{2028}", with: "\\u2028")
                .replacingOccurrences(of: "\u{2029}", with: "\\u2029")
        }

        let jsonStr = String(data: try encoder.encode(jsonp), encoding: .utf8)!

        let taintedJSCallbackName = request.queryParameters[callbackParameter]

        if let jsCallbackName = validJsonpCallbackName(taintedJSCallbackName) {
            headers.setType("js")
            // Set header "X-Content-Type-Options: nosniff" and prefix body with
            // "/**/ " as security mitigation for Flash vulnerability
            // CVE-2014-4671, CVE-2014-5333 "Abusing JSONP with Rosetta Flash"
            headers["X-Content-Type-Options"] = "nosniff"
            send("/**/ " + jsCallbackName + "(" + jsonToJS(jsonStr) + ")")
        } else {
            throw JSONPError.invalidCallbackName(name: taintedJSCallbackName)
        }
        return self
    }
}

/// Type alias for "Before flush" (i.e. before headers and body are written) lifecycle handler.
public typealias LifecycleHandler = () -> Void

/// Type alias for written data filter, i.e. pre-write lifecycle handler.
public typealias WrittenDataFilter = (Data) -> Data
