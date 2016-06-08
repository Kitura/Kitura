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
    /// Static buffer size (in bytes)
    ///
    private static let bufferSize = 2000


    ///
    /// BodyParser archiver
    ///
    private static let parserMap: [String: ((NSData) -> ParsedBody?)] =
        ["application/json": BodyParser.parseJSON,
         "application/x-www-form-urlencoded": BodyParser.parseURLencoded,
         "text": BodyParser.parseText]

    private class var newLineData: NSData {
        guard let newLineData = "\r\n".data(using: NSUTF8StringEncoding) else {
            Log.error("Error converting string to new line data for multipart parsing")
            exit(1)
        }
        return newLineData
    }

    ///
    /// Initializes a BodyParser instance
    /// Needed since default initalizer is internal
    ///
    public init() {}

    ///
    /// Handle the request
    ///
    /// - Parameter request: the router request
    /// - Parameter response: the router response
    /// - Parameter next: the closure for the next execution block
    ///
    public func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {

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
    
    private class func getParsingFunction(contentType: String) -> ((NSData) -> ParsedBody?)? {
        // Handle Content-Type with parameters.  For example, treat:
        // "application/x-www-form-urlencoded; charset=UTF-8" as
        // "application/x-www-form-urlencoded"
        var contentTypeWithoutParameters = contentType
        if let parameterStart = contentTypeWithoutParameters.range(of: ";") {
            contentTypeWithoutParameters = contentType.substring(to: parameterStart.lowerBound)
        }
        if let parser = parserMap[contentTypeWithoutParameters] {
            return parser
        } else if let parser = parserMap["text"]
            where contentType.hasPrefix("text/") {
            return parser
        } else if contentType.hasPrefix("multipart/form-data") {
            guard let boundryIndex = contentType.range(of: "boundary=") else {
                return nil
            }
            let boundary = contentType.substring(from: boundryIndex.upperBound).replacingOccurrences(of: "\"", with: "")
            return  {(bodyData: NSData) -> ParsedBody? in
                return parseMultipart(bodyData, boundary: boundary)
            }
        }
        return nil
    }

    ///
    /// Read incoming message for Parse
    ///
    /// - Parameter message: message coming from the socket
    /// - Parameter parser: ((NSData) -> ParsedBody?) store at parserMap
    ///
    private class func parse(_ message: SocketReader, parser: ((NSData) -> ParsedBody?)) -> ParsedBody? {
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
    private class func parseJSON(_ bodyData: NSData)-> ParsedBody? {
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
    private class func parseURLencoded(_ bodyData: NSData)-> ParsedBody? {
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
    private class func parseText(_ bodyData: NSData)-> ParsedBody? {
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
    private class func parseMultipart(_ bodyData: NSData, boundary: String) -> ParsedBody? {
        var parts: [Part] = []
        let bodyLines = divideDataByNewLines(data: bodyData, newLineData: newLineData)

        var bodyLineIterator = bodyLines.makeIterator()
        skipPreamble(bodyLineIterator: &bodyLineIterator, boundary: boundary)

        var endBoundaryEncountered = false
        var lastPartSeen: Part?
        repeat {
            (endBoundaryEncountered, lastPartSeen) =
                getNextPart(bodyLineIterator: &bodyLineIterator, boundary: boundary)
            if let part = lastPartSeen {
                parts.append(part)
            }
        }
        while !endBoundaryEncountered && lastPartSeen != nil

        return endBoundaryEncountered ? .multipart(parts) : nil
    }

    private class func skipPreamble(bodyLineIterator: inout IndexingIterator<Array<NSData>>,
                                    boundary: String) {
        guard let boundaryData = String("--" + boundary).data(using: NSUTF8StringEncoding) else {
                Log.error("Error converting strings to data for multipart parsing")
                return
        }

        while let bodyLine = bodyLineIterator.next() {
            if bodyLine.hasPrefix(boundaryData) {
                break
            }
        }
    }

    private class func getNextPart(bodyLineIterator: inout IndexingIterator<Array<NSData>>,
                                   boundary: String) -> (Bool, Part?){
        guard let boundaryData = String("--" + boundary).data(using: NSUTF8StringEncoding),
            let endBoundaryData = String("--" + boundary + "--").data(using: NSUTF8StringEncoding)
            else {
                Log.error("Error converting strings to data for multipart parsing")
                return (false, nil)
        }

        var part = Part()
        let partData = NSMutableData()

        while let bodyLine = bodyLineIterator.next() {
            if bodyLine.hasPrefix(boundaryData) {
                handleBoundary(partData: partData, part: &part)

                if bodyLine.hasPrefix(endBoundaryData) {
                    return (true, part)
                }
                return (false, part)
            }

            // process bodyLine as String
            guard let line = String(data: bodyLine, encoding: NSUTF8StringEncoding) else {
                // is data, add to data object
                if partData.length > 0 {
                    // data is multiline, add linebreaks back in
                    partData.append(newLineData)
                }
                partData.append(bodyLine)
                continue
            }

            let wasHeaderLine = handleHeaderLine(line, part: &part)

            if !wasHeaderLine && !line.isEmpty {
                // is data, add to data object
                if partData.length > 0 {
                    // data is multiline, add linebreaks back in
                    partData.append(newLineData)
                }
                partData.append(bodyLine)
            }
        }

        return (false, nil)
    }

    // returns true if it was header line
    private class func handleHeaderLine(_ line: String, part: inout Part) -> Bool {
        if let labelRange = line.range(of: "content-type:", options: [.anchoredSearch, .caseInsensitiveSearch], range: line.startIndex..<line.endIndex) {
            part.type = line.substring(from: line.index(after: labelRange.upperBound))
            part.headers[.type] = line
            return true
        }

        if let labelRange = line.range(of: "content-disposition:", options: [.anchoredSearch, .caseInsensitiveSearch], range: line.startIndex..<line.endIndex) {
            if let nameRange = line.range(of: "name=", options: .caseInsensitiveSearch, range: labelRange.upperBound..<line.endIndex) {
                let valueStartIndex = line.index(after: nameRange.upperBound)
                let valueEndIndex = line.range(of: "\"", range: valueStartIndex..<line.endIndex)
                part.name = line.substring(with: valueStartIndex..<(valueEndIndex?.lowerBound ?? line.endIndex))
            }
            part.headers[.disposition] = line
            return true
        }

        if line.range(of: "content-transfer-encoding:", options: [.anchoredSearch, .caseInsensitiveSearch], range: line.startIndex..<line.endIndex) != nil {
            //TODO: Deal with this
            part.headers[.transferEncoding] = line
            return true
        }

        return false
    }

    private class func handleBoundary(partData: NSData, part: inout Part) {
        if partData.length > 0 {
            if let parser = getParsingFunction(contentType: part.type),
                let parsedBody = parser(partData) {
                part.body = parsedBody
            } else {
                part.body = .raw(partData)
            }
        }
    }

    private class func divideDataByNewLines(data: NSData, newLineData: NSData) -> [NSData] {
        var dataLines = [NSData]()
        var lineStart = 0
        var currentPosition = 0
        while currentPosition < data.length - 1 {
            let newLineCanidate = data.subdata(with: NSRange(location: currentPosition, length: 2))
            if newLineCanidate.isEqual(to: newLineData) {
                dataLines.append(data.subdata(with: NSRange(location: lineStart, length: currentPosition - lineStart)))
                // skip new line characters
                currentPosition += 2
                lineStart = currentPosition
            } else {
                currentPosition += 1
            }
        }
        if lineStart != data.length {
            dataLines.append(data.subdata(with: NSRange(location: lineStart, length: data.length - lineStart)))
        }
        return dataLines
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

extension NSData {
    func hasPrefix(_ data: NSData) -> Bool {
        if data.length > self.length {
            return false
        }
        return self.subdata(with: NSRange(location: 0, length: data.length)).isEqual(to: data)
    }
}
