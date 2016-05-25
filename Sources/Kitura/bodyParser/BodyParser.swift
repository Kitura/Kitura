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
    private static let bufferSize = 2000


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

        guard request.headers["Content-Length"] != nil, let contentType = request.headers["Content-Type"] else {
            return next()
        }

        request.body = BodyParser.parse(request, contentType: contentType)
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
        
        if let parser = getParsingFunction(contentType: contentType) {
            return parse(message, parser: parser)
        }
        
        return nil
    }
    
    private class func getParsingFunction(contentType: String) -> ((NSMutableData) -> ParsedBody?)? {
        if let parser = parserMap[contentType] {
            return parser
        } else if let parser = parserMap["text"]
            where contentType.hasPrefix("text/") {
            return parser
        } else if contentType.hasPrefix("multipart/form-data") {
            guard let boundryIndex = contentType.range(of: "boundary=") else {
                return nil
            }
            let boundry = contentType.substring(from: boundryIndex.upperBound).replacingOccurrences(of: "\"", with: "")
            return  {(bodyData: NSMutableData) -> ParsedBody? in
                return parseMultipart(bodyData, boundary: boundry)
            }
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
            return .json(json)
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
                return .urlEncoded(parsedBody)
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
            return .text(bodyAsString)
        }
        return nil
    }
    
    ///
    /// Multipart form data parse function
    ///
    /// - Parameter bodyData: read data
    ///
    private class func parseMultipart(_ bodyData: NSMutableData, boundary: String) -> ParsedBody? {
        guard let bodyAsString = String(data: bodyData, encoding: NSUTF8StringEncoding) else {
            return nil
        }
        enum ParseState {
            case preamble, body
        }
        var state = ParseState.preamble
        var parts: [Part] = []
        var currentPart = Part()
        var data = NSMutableData()
        // divide body by lines
        let bodyAsStringLines = bodyAsString.components(separatedBy: NSCharacterSet.newlines()).filter({!$0.isEmpty})
        // main parse loop
        for bodyLine in bodyAsStringLines {
            switch(state) {
            case .preamble where bodyLine.hasPrefix("--" + boundary), .body where bodyLine.hasPrefix("--" + boundary):
                // boundary found
                if data.length > 0 {
                    if let parser = getParsingFunction(contentType: currentPart.type), let parsedBody = parser(data) {
                        currentPart.body = parsedBody
                    } else {
                        currentPart.body = .raw(data)
                    }
                    parts.append(currentPart)
                }
                currentPart = Part()
                data = NSMutableData()
                if bodyLine.hasPrefix("--" + boundary + "--") {
                    // end boundary found, end of parsing
                    return .multipart(parts)
                }
                state = .body
            case .preamble:
                // discard preamble text
                break
            case .body:
                // check if header
                if let labelRange = bodyLine.range(of: "content-type:", options: [.anchoredSearch, .caseInsensitiveSearch], range: Range<String.Index>(uncheckedBounds: (bodyLine.startIndex, bodyLine.endIndex))) {
                    currentPart.type = bodyLine.substring(from: bodyLine.index(after: labelRange.upperBound))
                    currentPart.headers[.type] = bodyLine
                } else if let labelRange = bodyLine.range(of: "content-disposition:", options: [.anchoredSearch, .caseInsensitiveSearch], range: Range<String.Index>(uncheckedBounds: (bodyLine.startIndex, bodyLine.endIndex))) {
                    if let nameRange = bodyLine.range(of: "name=", options: .caseInsensitiveSearch, range: Range<String.Index>(uncheckedBounds: (labelRange.upperBound, bodyLine.endIndex))) {
                        let valueStartIndex = bodyLine.index(after: nameRange.upperBound)
                        let valueEndIndex = bodyLine.range(of: "\"", range: Range<String.Index>(uncheckedBounds:(valueStartIndex, bodyLine.endIndex)))
                        currentPart.name = bodyLine.substring(with: Range<String.Index>(uncheckedBounds: (valueStartIndex, valueEndIndex?.lowerBound ?? bodyLine.endIndex)))
                    }
                    currentPart.headers[.disposition] = bodyLine
                } else if bodyLine.range(of: "content-transfer-encoding:", options: [.anchoredSearch, .caseInsensitiveSearch], range: Range<String.Index>(uncheckedBounds: (bodyLine.startIndex, bodyLine.endIndex))) != nil {
                    //TODO: Deal with this
                    currentPart.headers[.transferEncoding] = bodyLine
                } else {
                    // is data, add to data object
                    var dataLine = bodyLine
                    if data.length > 0 {
                        // data is multiline, add linebreaks back in
                        dataLine = "\r\n" + dataLine
                    }
                    if let lineData = dataLine.data(using: NSUTF8StringEncoding) {
                        data.append(lineData)
                    }
                }
            }
            
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
