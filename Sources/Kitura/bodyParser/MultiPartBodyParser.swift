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

import Foundation
import LoggerAPI

class MultiPartBodyParser: BodyParserProtocol {
    let boundaryData: NSData
    let endBoundaryData: NSData
    let newLineData: NSData
    let endHeaderData: NSData

    init(boundary: String) {
        guard let boundaryData = String("--" + boundary).data(using: NSUTF8StringEncoding),
            let endBoundaryData = "--".data(using: NSUTF8StringEncoding),
            let newLineData = "\r\n".data(using: NSUTF8StringEncoding),
            let endHeaderData = "\r\n\r\n".data(using: NSUTF8StringEncoding)
            else {
                Log.error("Error converting strings to data for multipart parsing")
                exit(1)
        }
        self.boundaryData = boundaryData
        self.endBoundaryData = endBoundaryData
        self.newLineData = newLineData
        self.endHeaderData = endHeaderData
    }

    func parse(_ data: NSData) -> ParsedBody? {
        var parts: [Part] = []
        // split the
        let componentParts = data.components(separatedBy: boundaryData)
        var skippedPreamble = false
        var endBoundaryEncountered = false
        for componentPart in componentParts {
            // skip the first component part - it's the preamble
            if skippedPreamble == false {
                skippedPreamble = true
                continue
            }
            // end when we see a component starting with endBoundaryData
            let endBoundary = componentPart.range(of: endBoundaryData, in: NSRange(location: 0, length: min(componentPart.length, endBoundaryData.length)))
            if endBoundary.location == 0 {
                endBoundaryEncountered = true
                break
            }
            if let part = getPart(componentPart) {
                parts.append(part)
            }
        }
        return endBoundaryEncountered ? .multipart(parts) : nil
    }

    private func getPart(_ componentPart: NSData) -> Part? {
        let found = componentPart.range(of: endHeaderData, in: NSRange(location: 0, length: componentPart.length))
        if found.location == NSNotFound {
            return nil
        }
        var part = Part()
        let headers = componentPart.subdata(with: NSRange(location: 0, length: found.location))
        let headerLines = headers.components(separatedBy: newLineData)
        // process the headers
        for header in headerLines {
            guard let header = String(data: header, encoding: NSUTF8StringEncoding) else {
                break
            }
            handleHeaderLine(header, part: &part)
        }
        // process the body
        var length = componentPart.length - (found.location + endHeaderData.length)
        // if the part ends with a \r\n, we delete it since it is part of the next boundary
        if componentPart.hasSuffix(newLineData) {
            length -= newLineData.length
        }
        let partData = componentPart.subdata(with: NSRange(location: found.location + endHeaderData.length, length: length))
        if partData.length > 0 {
            if let parser = BodyParser.getParser(contentType: part.type),
                let parsedBody = parser.parse(partData) {
                part.body = parsedBody
            } else {
                part.body = .raw(partData)
            }
        }
        return part
    }

    // returns true if it was header line
    private func handleHeaderLine(_ line: String, part: inout Part) {
        if let labelRange = getLabelRange(of: "content-type:", in: line) {
            part.type = line.substring(from: line.index(after: labelRange.upperBound))
            part.headers[.type] = line
            return
        }

        if let labelRange = getLabelRange(of: "content-disposition:", in: line) {
            if let nameRange = line.range(of: "name=", options: .caseInsensitiveSearch, range: labelRange.upperBound..<line.endIndex) {
                let valueStartIndex = line.index(after: nameRange.upperBound)
                let valueEndIndex = line.range(of: "\"", range: valueStartIndex..<line.endIndex)
                part.name = line.substring(with: valueStartIndex..<(valueEndIndex?.lowerBound ?? line.endIndex))
            }
            part.headers[.disposition] = line
            return
        }

        if line.range(of: "content-transfer-encoding:", options: [.anchoredSearch, .caseInsensitiveSearch], range: line.startIndex..<line.endIndex) != nil {
            //TODO: Deal with this
            part.headers[.transferEncoding] = line
            return
        }

        // custom headers could be handed here
    }

    private func getLabelRange(of searchedString: String, in containingString: String) ->
        Range<String.Index>? {
        return containingString.range(of: searchedString,
                                      options: [.anchoredSearch, .caseInsensitiveSearch],
                                      range: containingString.startIndex..<containingString.endIndex)
    }
}


extension NSData {
    
    func hasSuffix(_ data: NSData) -> Bool {
        if data.length > self.length {
            return false
        }
        return self.subdata(with: NSRange(location: self.length - data.length, length: data.length)).isEqual(to: data)
    }

    // mimic String.components(separatedBy separator: String) -> [String]
    func components(separatedBy separator: NSData) -> [NSData] {
        var parts: [NSData] = []
        
        var search = NSRange(location: 0, length: self.length)
        while true {
            // search for the next occurence of the separator
            let found = self.range(of: separator, in: search)
            if found.location == NSNotFound {
                parts.append(self.subdata(with: search))
                break
            }
            // add a part up to the found location
            let part = NSRange(location: search.location, length: found.location - search.location)
            parts.append(self.subdata(with: part))
            
            search.location = found.location + found.length
            search.length = self.length - search.location
        }
        return parts
    }
}
