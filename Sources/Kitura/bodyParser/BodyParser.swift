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

import Socket
import LoggerAPI

import Foundation

// MARK: BodyParser

/// The `BodyParser` parses the body of the request prior to sending it to the handler. It reads the Content-Type of the message header and populates the `RouterRequest` body field with a corresponding `ParsedBody` enumeration.
/// 
/// In order for the BodyParser to be used it must first be registered with any routes that are interested in the `ParsedBody` payload.
/// 
/// ### ParsedBody enumeration: ###
/// 
/// The mappings from the incoming Content-Type to an internal representation of the body are as follows:
/// 
/// ```swift
///    .json([String: Any])          // "application/json"
///    .text(String)                 // "text/*"
///    .urlEncoded([String:String])  // "application/x-www-form-urlencoded"
///    .multipart([Part])            // "multipart/form-data"
///    .raw(Data)                    // Any other Content-Type
/// ```
///
/// Each case has a corresponding convenience property, e.g. `asURLEncoded: [String:String]`, for accessing the associated data.
/// 
/// __Note__: If you have not declared a Content-Type header, `ParsedBody` will be `nil`.
/// 
/// ### Usage Example: ###
/// 
/// In this example, all routes to the BodyParser middleware are registered to the `BodyParser` middleware. A request with "application/json", ContentType header is received. It is then parsed as JSON and the value for "name" is returned in the response.
/// ```swift
/// router.all("/name", middleware: BodyParser())
/// router.post("/name") { request, response, next in
///     guard let jsonBody = request.parsedBody?.asJSON else {
///         next()
///         return
///     }
///     let name = jsonBody["name"] as? String ?? ""
///     try response.send("Hello \(name)").end()
/// }
/// ```
/// __Note__: When using Codable Routing in Kitura 2.x the BodyParser should not be registered to any codable routes (doing so will log the following error "No data in request. Codable routes do not allow the use of a BodyParser." and the route handler will not be executed).
public class BodyParser: RouterMiddleware {

    /// Static buffer size (in bytes)
    private static let bufferSize = 2000

    /// BodyParser archiver
    private static let parserMap: [String: BodyParserProtocol] =
        ["application/json": JSONBodyParser(),
         "application/x-www-form-urlencoded": URLEncodedBodyParser(),
         "text": TextBodyParser()]

    /// Initializes a BodyParser instance.
    /// Needed since default initalizer is internal.
    ///### Usage Example: ###
    ///```swift
    /// let middleware = BodyParser()
    ///```
    public init() {}

    /// This function is called by the Kitura `Router` when an incoming request matches the route provided when the BodyParser was registered with the `Router`. It performs the parsing of the body content using `parse(_:contentType)`. We don't expect a user to call this function directly.
    /// - Parameter request: The `RouterRequest` object used to work with the incoming
    ///                     HTTP request.
    /// - Parameter response: The `RouterResponse` object used to respond to the
    ///                     HTTP request.
    /// - Parameter next: The closure called to invoke the next handler or middleware
    ///                     associated with the request.
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard request.body == nil else {
            return next() // the body was already parsed
        }

        guard request.headers["Content-Length"] != nil,
            let contentType = request.headers["Content-Type"] else {
                return next()
        }

        request.body = BodyParser.parse(request, contentType: contentType)
        next()
    }

    /// This function is called by the Kitura `Router` when an incoming request matches the route provided when the BodyParser was registered with the `Router`. The `middleware.handle(...)` function will parse the body content of an incoming request using this function. A user can call this function directly but ordinarily won't need to.
    ///
    ///### Usage Example: ###
    ///In this example, the body of the request is parsed to be of the passed in contentType.
    ///```swift
    ///request.body = BodyParser.parse(request, contentType: contentType)
    ///```
    ///
    /// - Parameter message: Message coming from the socket.
    /// - Parameter contentType: The content type as a String.
    /// - Returns: The parsed body.
    public class func parse(_ message: RouterRequest, contentType: String?) -> ParsedBody? {
        guard let contentType = contentType else {
            return nil
        }

        if let parser = getParser(contentType: contentType) {
            return parse(message, parser: parser)
        }

        return nil
    }

    class func getParser(contentType: String) -> BodyParserProtocol? {
        // Handle Content-Type with parameters.  For example, treat:
        // "application/x-www-form-urlencoded; charset=UTF-8" as
        // "application/x-www-form-urlencoded"
        var contentTypeWithoutParameters = contentType
        if let parameterStart = contentTypeWithoutParameters.range(of: ";") {
            contentTypeWithoutParameters = String(contentType[..<parameterStart.lowerBound])
        }
        if let parser = parserMap[contentTypeWithoutParameters] {
            return parser
        } else if let parser = parserMap["text"], contentType.hasPrefix("text/") {
            return parser
        } else if contentType.hasPrefix("multipart/form-data") {
            guard let boundryIndex = contentType.range(of: "boundary=") else {
                return nil
            }

            #if os(Linux)
                // https://bugs.swift.org/browse/SR-5727
                // ETA post-4.0
                var boundary = String(contentType[boundryIndex.upperBound...]).replacingOccurrences(of: "\"", with: "")
            #else
                var boundary = contentType[boundryIndex.upperBound...].replacingOccurrences(of: "\"", with: "")
            #endif

            // remove any trailing parameters - as per RFC 2046 section 5.1.1., a semicolon cannot be part of a boundary
            if let parameterStart = boundary.range(of: ";") {
                boundary.removeSubrange(parameterStart.lowerBound..<boundary.endIndex)
            }
            return MultiPartBodyParser(boundary: boundary)
        } else { //Default: parse body as `.raw(Data)`
            return RawBodyParser()
        }
    }

    /// Read incoming message for Parse.
    ///
    ///### Usage Example: ###
    ///In this example, the request body is parsed using a parser which complies to `BodyParserProtocol`.
    ///```swift
    ///request.body = BodyParser.parse(request, parser: bodyParser)
    ///```
    /// - Parameter message: Message coming from the socket
    /// - Parameter parser: ((NSData) -> ParsedBody?) store at parserMap
    /// - Returns: The parsed body
    private class func parse(_ message: RouterRequest, parser: BodyParserProtocol) -> ParsedBody? {
        message.hasBodyParserBeenUsed = true
        do {
            let bodyData = try readBodyData(with: message)
            return parser.parse(bodyData)
        } catch {
            Log.error("failed to read body data, error = \(error)")
        }
        return nil
    }

    /// Read the body data of the request.
    ///### Usage Example: ###
    ///In this example, the body of the request is read into a constant (called bodyData) using an instance of `RouterRequest` (called request).
    ///```swift
    ///let bodyData = try readBodyData(with: request)
    ///```
    /// - Parameter with: The socket reader.
    /// - Throws: Socket.Error if an error occurred while reading from a socket.
    /// - Returns: The body data associated with the request.
    public class func readBodyData(with reader: RouterRequest) throws -> Data {
        var bodyData = Data()
        var length = 0

        repeat {
            length = try reader.read(into: &bodyData)
        } while length != 0

        return bodyData
    }
}

public class BodyParserMultiValue: BodyParser {
    override class func getParser(contentType: String) -> BodyParserProtocol? {
        if contentType.hasPrefix("application/x-www-form-urlencoded") {
            return URLEncodedMultiValueBodyParser()
        }
        else {
            return super.getParser(contentType: contentType)
        }
    }

    /// This function is called by the Kitura `Router` when an incoming request matches the route provided when the BodyParser was registered with the `Router`. It performs the parsing of the body content using `parse(_:contentType)`. We don't expect a user to call this function directly.
    /// - Parameter request: The `RouterRequest` object used to work with the incoming
    ///                     HTTP request.
    /// - Parameter response: The `RouterResponse` object used to respond to the
    ///                     HTTP request.
    /// - Parameter next: The closure called to invoke the next handler or middleware
    ///                     associated with the request.
    override public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard request.body == nil else {
            return next() // the body was already parsed
        }

        guard request.headers["Content-Length"] != nil,
            let contentType = request.headers["Content-Type"] else {
                return next()
        }

        request.body = BodyParserMultiValue.parse(request, contentType: contentType)
        next()
    }
}

extension Data {
    func hasPrefix(_ data: Data) -> Bool {
        if data.count > self.count {
            return false
        }
        return self.subdata(in: 0 ..< data.count) == data
    }
}
