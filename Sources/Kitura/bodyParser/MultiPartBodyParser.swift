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
import Foundation
import LoggerAPI

class MultiPartBodyParser: BodyParserProtocol {
    let boundaryData: NSData
    let endBoundaryData: NSData
    let newLineData: NSData

    init(boundary: String) {
        guard let boundaryData = String("--" + boundary).data(using: NSUTF8StringEncoding),
            let endBoundaryData = String("--" + boundary + "--").data(using: NSUTF8StringEncoding),
            let newLineData = "\r\n".data(using: NSUTF8StringEncoding)
            else {
                Log.error("Error converting strings to data for multipart parsing")
                exit(1)
        }
        self.boundaryData = boundaryData
        self.endBoundaryData = endBoundaryData
        self.newLineData = newLineData
    }

    func parse(_ data: NSData) -> ParsedBody? {
        var parts: [Part] = []
        let bodyLines = divideDataByNewLines(data: data, newLineData: newLineData)

        var bodyLineIterator = bodyLines.makeIterator()
        skipPreamble(bodyLineIterator: &bodyLineIterator)

        var endBoundaryEncountered = false
        var lastPartSeen: Part?
        repeat {
            (endBoundaryEncountered, lastPartSeen) =
                getNextPart(bodyLineIterator: &bodyLineIterator)
            if let part = lastPartSeen {
                parts.append(part)
            }
        }
        while !endBoundaryEncountered && lastPartSeen != nil

        return endBoundaryEncountered ? .multipart(parts) : nil
    }

    private func skipPreamble(bodyLineIterator: inout IndexingIterator<Array<NSData>>) {
        while let bodyLine = bodyLineIterator.next() {
            if bodyLine.hasPrefix(boundaryData) {
                break
            }
        }
    }

    private func getNextPart(bodyLineIterator: inout IndexingIterator<Array<NSData>>) -> (Bool, Part?){
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
    private func handleHeaderLine(_ line: String, part: inout Part) -> Bool {
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

    private func handleBoundary(partData: NSData, part: inout Part) {
        if partData.length > 0 {
            if let parser = BodyParser.getParser(contentType: part.type),
                let parsedBody = parser.parse(partData) {
                part.body = parsedBody
            } else {
                part.body = .raw(partData)
            }
        }
    }

    private func divideDataByNewLines(data: NSData, newLineData: NSData) -> [NSData] {
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
}

