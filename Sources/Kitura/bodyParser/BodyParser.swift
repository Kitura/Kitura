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

        guard request.serverRequest.headers["Content-Length"] != nil else {
            return next()
        }

        request.body = BodyParser.parse(request, contentType: request.serverRequest.headers["Content-Type"])
        next()

    }

    ///
    /// Parse the incoming message
    ///
    /// - Parameter message: message coming from the socket
    /// - Parameter contentType: the contentType as a string
    ///
    public class func parse(_ message: SocketReader, contentType: String?) -> ParsedBody? {

        guard let contentType = contentType else {
            return nil
        }

        if let parser = parserMap[contentType] {
            return parse(message, parser: parser)
        } else if let parserMap = parserMap["text"]
            where contentType.hasPrefix("text/") {
            return parse(message, parser: parserMap)
        }

        return nil
    }

    ///
    /// Read incoming message for Parse
    ///
    /// - Parameter message: message coming from the socket
    /// - Parameter parser: ((NSMutableData) -> ParsedBody?) store at parserMap
    ///
    private class func parse(_ message: SocketReader, parser: ((NSMutableData) -> ParsedBody?)) -> ParsedBody? {
        do {
            let bodyData = try readBodyData(with: message)
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
            return .Json(json)
        }
        return nil
    }

    ///
    /// Urlencoded parse Function
    ///
    /// - Parameter bodyData: read data
    ///
    private class func urlencoded(_ bodyData: NSMutableData)-> ParsedBody? {
        var parsedBody = [String:String]()
        var success = true
        if let bodyAsString: String = String(data: bodyData, encoding: NSUTF8StringEncoding) {

            let bodyAsArray = bodyAsString.components(separatedBy: "&")

            for element in bodyAsArray {

                let elementPair = element.components(separatedBy: "=")
                if elementPair.count == 2 {
                    parsedBody[elementPair[0]] = elementPair[1]
                } else {
                    success = false
                }
            }
            if success && parsedBody.count > 0 {
                return .UrlEncoded(parsedBody)
            }
        }
        return nil
    }

    ///
    /// text parse Function
    ///
    /// - Parameter bodyData: read data
    ///
    private class func text(_ bodyData: NSMutableData)-> ParsedBody? {
        // There was no support for the application/json MIME type
        if let bodyAsString: String = String(data: bodyData, encoding: NSUTF8StringEncoding) {
            return .Text(bodyAsString)
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
    public class func readBodyData(with reader: SocketReader) throws -> NSMutableData {

        let bodyData = NSMutableData()

        var length = try reader.read(into: bodyData)
        while length != 0 {
            length = try reader.read(into: bodyData)
        }
        return bodyData
    }

}
