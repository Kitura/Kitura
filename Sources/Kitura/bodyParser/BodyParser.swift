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

/// Router middleware for parsing the body of the request.
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
    public init() {}

    /// Handle the request, i.e. parse the body of the request.
    ///
    /// - Parameter request: the router request.
    /// - Parameter response: the router response.
    /// - Parameter next: the closure for the next execution block.
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

    /// Parse the body of the incoming message.
    ///
    /// - Parameter message: message coming from the socket.
    /// - Parameter contentType: the content type as a String.
    /// - Returns: the parsed body.
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
            contentTypeWithoutParameters = contentType.substring(to: parameterStart.lowerBound)
        }
        if let parser = parserMap[contentTypeWithoutParameters] {
            return parser
        } else if let parser = parserMap["text"], contentType.hasPrefix("text/") {
            return parser
        } else if contentType.hasPrefix("multipart/form-data") {
            guard let boundryIndex = contentType.range(of: "boundary=") else {
                return nil
            }
            var boundary = contentType.substring(from: boundryIndex.upperBound).replacingOccurrences(of: "\"", with: "")
            // remove any trailing parameters - as per RFC 2046 section 5.1.1., a semicolon cannot be part of a boundary
            if let parameterStart = boundary.range(of: ";") {
                boundary = boundary.substring(to: parameterStart.lowerBound)
            }
            return MultiPartBodyParser(boundary: boundary)
        } else { //Default: parse body as `.raw(Data)`
            return RawBodyParser()
        }
    }

    /// Read incoming message for Parse
    ///
    /// - Parameter message: message coming from the socket
    /// - Parameter parser: ((NSData) -> ParsedBody?) store at parserMap
    /// - Returns: the parsed body
    private class func parse(_ message: RouterRequest, parser: BodyParserProtocol) -> ParsedBody? {
        do {
            let bodyData = try readBodyData(with: message)
            return parser.parse(bodyData)
        } catch {
            Log.error("failed to read body data, error = \(error)")
        }
        return nil
    }

    /// Read the body data of the request.
    ///
    /// - Parameter with: the socket reader.
    /// - Throws: Socket.Error if an error occurred while reading from a socket.
    /// - Returns: data for the body.
    public class func readBodyData(with reader: RouterRequest) throws -> Data {
        var bodyData = Data()

        var length = try reader.read(into: &bodyData)
        while length != 0 {
            length = try reader.read(into: &bodyData)
        }
        return bodyData
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
