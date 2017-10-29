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

import Foundation
import LoggerAPI

class MultiPartBodyParser: BodyParserProtocol {
    let boundaryData: Data
    let endBoundaryData: Data
    let newLineData: Data
    let endHeaderData: Data

    init(boundary: String) {
        guard let boundaryData = String("--" + boundary).data(using: .utf8),
            let endBoundaryData = "--".data(using: .utf8),
            let newLineData = "\r\n".data(using: .utf8),
            let endHeaderData = "\r\n\r\n".data(using: .utf8)
            else {
                Log.error("Error converting strings to data for multipart parsing")
                exit(1)
        }

        self.boundaryData = boundaryData
        self.endBoundaryData = endBoundaryData
        self.newLineData = newLineData
        self.endHeaderData = endHeaderData
    }

    func parse(_ data: Data) -> ParsedBody? {
        var parts: [Part] = []
        // split the body into component parts separated by the boundary, drop the preamble part
        let componentParts = data.components(separatedBy: boundaryData).dropFirst()

        var endBoundaryEncountered = false
        for componentPart in componentParts {
            // end when we see a component starting with endBoundaryData
            if componentPart.hasPrefix(endBoundaryData) {
                endBoundaryEncountered = true
                break
            }

            if let part = getPart(componentPart) {
                parts.append(part)
            }
        }
        return endBoundaryEncountered ? .multipart(parts) : nil
    }

    private func getPart(_ componentPart: Data) -> Part? {
        guard let found = componentPart.range(of: endHeaderData, in: 0 ..< componentPart.count) else {
            return nil
        }

        var part = Part()
        let headers = componentPart.subdata(in: 0 ..< found.lowerBound)
        let headerLines = headers.components(separatedBy: newLineData)
        // process the headers
        for header in headerLines {
            guard let header = String(data: header, encoding: String.Encoding.utf8) else {
                break
            }
            handleHeaderLine(header, part: &part)
        }
        // process the body
        var length = componentPart.count - (found.lowerBound + endHeaderData.count)
        // if the part ends with a \r\n, we delete it since it is part of the next boundary
        if componentPart.hasSuffix(newLineData) {
            length -= newLineData.count
        }
        let partData = componentPart.subdata(in: found.lowerBound + endHeaderData.count ..< found.lowerBound + endHeaderData.count + length)
        if partData.count > 0 {
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
            part.type = String(line[line.index(after: labelRange.upperBound)...])
            part.headers[.type] = line
            return
        }

        if let labelRange = getLabelRange(of: "content-disposition:", in: line) {
            let caseInsensitiveSearch = String.CompareOptions.caseInsensitive
            if let nameRange = line.range(of: "name=", options: caseInsensitiveSearch, range: labelRange.upperBound..<line.endIndex) {
                let valueStartIndex = line.index(after: nameRange.upperBound)
                let valueEndIndex = line.range(of: "\"", range: valueStartIndex..<line.endIndex)
                part.name = String(line[valueStartIndex..<(valueEndIndex?.lowerBound ?? line.endIndex)])
            }
            if let filenameRange = line.range(of: "filename=", options: caseInsensitiveSearch, range: labelRange.upperBound..<line.endIndex) {
                let valueStartIndex = line.index(after: filenameRange.upperBound)
                let valueEndIndex = line.range(of: "\"", range: valueStartIndex..<line.endIndex)
                part.filename = String(line[valueStartIndex..<(valueEndIndex?.lowerBound ?? line.endIndex)])
            }
            part.headers[.disposition] = line
            return
        }

        let options: String.CompareOptions  = [.anchored, .caseInsensitive]
        if line.range(of: "content-transfer-encoding:", options: options, range: line.startIndex..<line.endIndex) != nil {
            // swiftlint:disable todo
            //TODO: Deal with this
            // swiftlint:enable todo
            part.headers[.transferEncoding] = line
            return
        }

        if let _ = getLabelRange(of: "content-range:", in: line) {
            part.headers[.contentRange] = line
            return
        }

        // custom headers could be handed here
    }

    private func getLabelRange(of searchedString: String, in containingString: String) ->
        Range<String.Index>? {
            let options: String.CompareOptions = [.anchored, .caseInsensitive]

            return containingString.range(of: searchedString,
                                          options: options,
                                          range: containingString.startIndex..<containingString.endIndex)
    }
}

extension Data {
    func hasSuffix(_ data: Data) -> Bool {
        if data.count > self.count {
            return false
        }
        return self.subdata(in: self.count - data.count ..< self.count) == data
    }

    // mimic String.components(separatedBy separator: String) -> [String]
    func components(separatedBy separator: Data) -> [Data] {
        var parts: [Data] = []

        var search: Range = 0 ..< self.count
        while true {
            // search for the next occurence of the separator
            guard let found = self.range(of: separator, in: search) else {
                parts.append(self.subdata(in: search))
                break
            }
            // add a part up to the found location
            parts.append(self.subdata(in: search.lowerBound ..< found.lowerBound))

            search = found.upperBound ..< self.count
        }
        return parts
    }
}
