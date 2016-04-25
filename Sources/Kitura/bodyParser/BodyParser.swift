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

import SwiftyJSON

import KituraSys
import KituraNet
import Socket
import LoggerAPI

import Foundation

// MARK: BodyParser


public class BodyParser: RouterMiddleware {

    ///
    /// Default buffer size (in bytes)
    ///
    private static let BUFFER_SIZE = 2000


    ///
    /// BodyParser archiver
    ///
    private static let parserMap: [String: ((NSMutableData) -> ParsedBody?)] = ["application/json": BodyParser.json,
                                                                                "application/x-www-form-urlencoded": BodyParser.urlencoded,
                                                                                "text": BodyParser.text]
    ///
    /// Initializes a BodyParser instance
    ///
    public init() {}

    ///
    /// Handle the request
    ///
    /// - Parameter request: the router request
    /// - Parameter response: the router response
    /// - Parameter next: the closure for the next execution block
    ///
    public func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {


        guard request.headers.getHeader("Content-Length") != nil, let contentType = request.headers.getHeader("Content-Type") else {
            return next()
        }

        request.body = BodyParser.parse(request, contentType: contentType.first)
        next()

    }

    ///
    /// Parse the incoming message
    ///
    /// - Parameter message: message coming from the socket
    /// - Parameter contentType: the contentType as a string
    ///
    public class func parse(message: SocketReader, contentType: String?) -> ParsedBody? {

        guard let contentType = contentType else {
            return nil
        }

        if let parser = parserMap[contentType] {
            return parse(message, parser: parser)
        } else if contentType.hasPrefix("text/") {
            return parse(message, parser: parserMap["text"]!)
        }

        return nil
    }

    ///
    /// Read incoming message for Parse
    ///
    /// - Parameter message: message coming from the socket
    /// - Parameter parser: ((NSMutableData) -> ParsedBody?) store at parserMap
    ///
    private class func parse(message: SocketReader, parser: ((NSMutableData) -> ParsedBody?)) -> ParsedBody? {
        do {
            let bodyData = try readBodyData(message)
            return parser(bodyData)
        } catch {
            Log.error("failed to read body data, error = \(error)")
        }
        return nil
    }

    ///
    /// Json parse Function
    ///
    /// - Parameter bodyData: read data
    ///
    private class func json(bodyData: NSMutableData)-> ParsedBody? {
        let json = JSON(data: bodyData)
        if json != JSON.null {
            return ParsedBody(json: json)
        }
        return nil
    }

    ///
    /// Urlencoded parse Function
    ///
    /// - Parameter bodyData: read data
    ///
    private class func urlencoded(bodyData: NSMutableData)-> ParsedBody? {
        var parsedBody = [String:String]()
        var success = true
        if let bodyAsString: String = String(data: bodyData, encoding: NSUTF8StringEncoding) {

#if os(Linux)
            let bodyAsArray = bodyAsString.bridge().componentsSeparatedByString("&")
#else
            let bodyAsArray = bodyAsString.componentsSeparated(by: "&")
#endif

            for element in bodyAsArray {

#if os(Linux)
                let elementPair = element.bridge().componentsSeparatedByString("=")
#else
                let elementPair = element.componentsSeparated(by: "=")
#endif

                if elementPair.count == 2 {
                    parsedBody[elementPair[0]] = elementPair[1]
                } else {
                    success = false
                }
            }
            if success && parsedBody.count > 0 {
                return ParsedBody(urlEncoded: parsedBody)
            }
        }
        return nil
    }

    ///
    /// text parse Function
    ///
    /// - Parameter bodyData: read data
    ///
    private class func text(bodyData: NSMutableData)-> ParsedBody? {
        // There was no support for the application/json MIME type
        if let bodyAsString: String = String(data: bodyData, encoding: NSUTF8StringEncoding) {
            return ParsedBody(text:  bodyAsString)
        }
        return nil
    }

    ///
    /// Read the Body data
    ///
    /// - Parameter reader: the socket reader
    ///
    /// - Throws: ???
    /// - Returns: data for the body
    ///
    public class func readBodyData(reader: SocketReader) throws -> NSMutableData {

        let bodyData = NSMutableData()

        var length = try reader.read(into: bodyData)
        while length != 0 {
            length = try reader.read(into: bodyData)
        }
        return bodyData
    }

}

// MARK: ParsedBody

public class ParsedBody {

    ///
    /// JSON body if the body is JSON
    ///
    private var jsonBody: JSON?

    ///
    /// URL encoded body
    ///
    private var urlEncodedBody: [String:String]?

    ///
    /// Plain-text body
    ///
    private var textBody: String?

    ///
    /// Initializes a ParsedBody instance
    ///
    /// - Parameter json: JSON formatted data
    ///
    /// - Returns: a ParsedBody instance
    ///
    public init (json: JSON) {

        jsonBody = json

    }

    ///
    /// Initializes a ParsedBody instance
    ///
    /// - Parameter urlEncoded: a list of String,String tuples
    ///
    /// - Returns a parsed body instance
    ///
    public init (urlEncoded: [String:String]) {
        urlEncodedBody = urlEncoded
    }

    ///
    /// Initializes a ParsedBody instance
    ///
    /// - Parameter text: the String plain-text
    ///
    /// - Returns a parsed body instance
    ///
    public init (text: String) {
        textBody = text
    }

    ///
    /// Returns the body as JSON
    ///
    /// - Returns: the JSON
    ///
    public func asJson() -> JSON? {
        return jsonBody
    }

    ///
    /// Returns the body as URL encoded strings
    ///
    /// - Returns: the list of string, string tuples
    ///
    public func asUrlEncoded() -> [String:String]? {
        return urlEncodedBody
    }

    ///
    /// Returns the body as plain-text
    ///
    /// - Returns: the plain text
    ///
    public func asText() -> String? {
        return textBody
    }

}
