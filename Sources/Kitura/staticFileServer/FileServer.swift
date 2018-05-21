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

import LoggerAPI
import Foundation

extension StaticFileServer {

    // MARK: FileServer
    class FileServer {

        /// Serve "index.html" files in response to a request on a directory.
        private let serveIndexForDirectory: Bool

        /// Redirect to trailing "/" when the pathname is a dir.
        private let redirect: Bool

        /// the path from where the files are served
        private let servingFilesPath: String

        /// If a file is not found, the given extensions will be added to the file name and searched for.
        /// The first that exists will be served.
        private let possibleExtensions: [String]

        /// A setter for response headers.
        private let responseHeadersSetter: ResponseHeadersSetter?

        /// Whether accepts range requests or not
        let acceptRanges: Bool

        init(servingFilesPath: String, options: StaticFileServer.Options,
             responseHeadersSetter: ResponseHeadersSetter?) {
            self.possibleExtensions = options.possibleExtensions
            self.serveIndexForDirectory = options.serveIndexForDirectory
            self.redirect = options.redirect
            self.acceptRanges = options.acceptRanges
            self.servingFilesPath = servingFilesPath
            self.responseHeadersSetter = responseHeadersSetter
        }

        func getFilePath(from request: RouterRequest) -> String? {
            var filePath = servingFilesPath
            guard let requestPath = request.parsedURLPath.path else {
                return nil
            }
            var matchedPath = request.matchedPath
            if matchedPath.hasSuffix("*") {
                matchedPath = String(matchedPath.dropLast())
            }
            if !matchedPath.hasSuffix("/") {
                matchedPath += "/"
            }

            if requestPath.hasPrefix(matchedPath) {
                filePath += "/"
                let url = String(requestPath.dropFirst(matchedPath.count))
                if let decodedURL = url.removingPercentEncoding {
                    filePath += decodedURL
                } else {
                    Log.warning("unable to decode url \(url)")
                    filePath += url
                }
            }

            if filePath.hasSuffix("/") {
                if serveIndexForDirectory {
                    filePath += "index.html"
                } else {
                    return nil
                }
            }

            return filePath
        }

        func serveFile(_ filePath: String, requestPath: String, response: RouterResponse) {
            let fileManager = FileManager()
            var isDirectory = ObjCBool(false)

            if fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory) {
                #if !os(Linux) || swift(>=4.1)
                    let isDirectoryBool = isDirectory.boolValue
                #else
                    let isDirectoryBool = isDirectory
                #endif
                serveExistingFile(filePath, requestPath: requestPath,
                                  isDirectory: isDirectoryBool, response: response)
                return
            }

            tryToServeWithExtensions(filePath, response: response)
        }

        private func tryToServeWithExtensions(_ filePath: String, response: RouterResponse) {
            let filePathWithPossibleExtensions = possibleExtensions.map { filePath + "." + $0 }
            for filePathWithExtension in filePathWithPossibleExtensions {
                serveIfNonDirectoryFile(atPath: filePathWithExtension, response: response)
            }
        }

        private func serveExistingFile(_ filePath: String, requestPath: String, isDirectory: Bool,
                                       response: RouterResponse) {
            if isDirectory {
                if redirect {
                    do {
                        try response.redirect(requestPath + "/")
                    } catch {
                        response.error = Error.failedToRedirectRequest(path: requestPath + "/", chainedError: error)
                    }
                }
            } else {
                serveNonDirectoryFile(filePath, response: response)
            }
        }

        @discardableResult
        private func serveIfNonDirectoryFile(atPath path: String, response: RouterResponse) -> Bool {
            var isDirectory = ObjCBool(false)
            if FileManager().fileExists(atPath: path, isDirectory: &isDirectory) {
                #if !os(Linux) || swift(>=4.1)
                    let isDirectoryBool = isDirectory.boolValue
                #else
                    let isDirectoryBool = isDirectory
                #endif
                if !isDirectoryBool {
                    serveNonDirectoryFile(path, response: response)
                    return true
                }
            }
            return false
        }

        private func serveNonDirectoryFile(_ filePath: String, response: RouterResponse) {
            if  !isValidFilePath(filePath) {
                return
            }

            do {
                let fileAttributes = try FileManager().attributesOfItem(atPath: filePath)

                // At this point only GET or HEAD are expected
                let request = response.request
                let method = request.serverRequest.method
                response.headers["Accept-Ranges"] = acceptRanges ? "bytes" : "none"
                responseHeadersSetter?.setCustomResponseHeaders(response: response,
                                                                filePath: filePath,
                                                                fileAttributes: fileAttributes)
                // Check headers to see if it is a Range request
                if acceptRanges,
                    method == "GET", // As per RFC, Only GET request can be Range Request
                    let rangeHeader = request.headers["Range"],
                    RangeHeader.isBytesRangeHeader(rangeHeader),
                    let fileSize = (fileAttributes[FileAttributeKey.size] as? NSNumber)?.uint64Value {
                    // At this point it looks like the client requested a Range Request
                    if let rangeHeaderValue = try? RangeHeader.parse(size: fileSize, headerValue: rangeHeader),
                        rangeHeaderValue.type == "bytes",
                        !rangeHeaderValue.ranges.isEmpty {
                        // At this point range is valid and server is able to serve it
                        if ifRangeHeaderShouldPreventPartialReponse(requestHeaders: request.headers, fileAttributes: fileAttributes) {
                            // If-Range header prevented a partial response. Send the entire file
                            try response.send(fileName: filePath)
                            response.statusCode = .OK
                        } else {
                            // Send a partial response
                            serveNonDirectoryPartialFile(filePath, fileSize: fileSize, ranges: rangeHeaderValue.ranges, response: response)
                        }
                    } else {
                        // Send not satisfiable response
                        serveNotSatisfiable(filePath, fileSize: fileSize, response: response)
                    }
                } else {
                    // Regular request OR Syntactically invalid range request OR fileSize was not available
                    if method == "HEAD" {
                        // Send only headers
                        _ = response.send(status: .OK)
                    } else {
                        // Send the entire file
                        try response.send(fileName: filePath)
                        response.statusCode = .OK
                    }
                }
            } catch {
                Log.error("serving file at path \(filePath), error: \(error)")
            }
        }

        private func isValidFilePath(_ filePath: String) -> Bool {
            guard let absoluteBasePath = NSURL(fileURLWithPath: servingFilesPath).standardizingPath?.absoluteString,
                let standardisedPath = NSURL(fileURLWithPath: filePath).standardizingPath?.absoluteString else {
                return false
            }
            return  standardisedPath.hasPrefix(absoluteBasePath)
        }

        private func serveNotSatisfiable(_ filePath: String, fileSize: UInt64, response: RouterResponse) {
            response.headers["Content-Range"] = "bytes */\(fileSize)"
            _ = response.send(status: .requestedRangeNotSatisfiable)
        }

        private func serveNonDirectoryPartialFile(_ filePath: String, fileSize: UInt64, ranges: [Range<UInt64>], response: RouterResponse) {
            let contentType =  ContentType.sharedInstance.getContentType(forFileName: filePath)
            if ranges.count == 1 {
                let data = FileServer.read(contentsOfFile: filePath, inRange: ranges[0])
                // Send a single part response
                response.headers["Content-Type"] =  contentType
                response.headers["Content-Range"] = "bytes \(ranges[0].lowerBound)-\(ranges[0].upperBound)/\(fileSize)"
                response.send(data: data ?? Data())
                response.statusCode = .partialContent

            } else {
                // Send multi part response
                let boundary = "KituraBoundary\(UUID().uuidString)" // Maybe a better boundary can be calculated in the future
                response.headers["Content-Type"] =  "multipart/byteranges; boundary=\(boundary)"
                var data = Data()
                ranges.forEach { range in
                    let fileData = FileServer.read(contentsOfFile: filePath, inRange: range) ?? Data()
                    var partHeader = "--\(boundary)\r\n"
                    partHeader += "Content-Range: bytes \(range.lowerBound)-\(range.upperBound)/\(fileSize)\r\n"
                    partHeader += (contentType == nil ? "" : "Content-Type: \(contentType!)\r\n")
                    partHeader += "\r\n"
                    data.append(partHeader.data(using: .utf8)!)
                    data.append(fileData)
                    data.append("\r\n".data(using: .utf8)!)
                }
                data.append("--\(boundary)--".data(using: .utf8)!)
                response.send(data: data)
                response.statusCode = .partialContent
            }
        }


        private func ifRangeHeaderShouldPreventPartialReponse(requestHeaders headers: Headers, fileAttributes: [FileAttributeKey : Any]) -> Bool {
            // If-Range is optional
            guard let ifRange = headers["If-Range"], !ifRange.isEmpty else {
                return false
            }
            // If-Range can be one of two values: ETag or Last-Modified but not both.
            // If-Range as ETag
            if (ifRange.contains("\"")) {
                if let etag = CacheRelatedHeadersSetter.calculateETag(from: fileAttributes),
                    !etag.isEmpty,
                    ifRange.contains(etag) {
                    return false
                }
                return true
            }
            // If-Range as Last-Modified
            if let ifRangeLastModified = FileServer.date(from: ifRange),
                let lastModified = fileAttributes[FileAttributeKey.modificationDate] as? Date,
                floor(lastModified.timeIntervalSince1970) > floor(ifRangeLastModified.timeIntervalSince1970) {
                return true
            }
            return false
        }

        /// Helper function to convert http date Strings into Date
        static func date(from httpDate: String) -> Date? {
            let df = DateFormatter()
            df.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"
            return df.date(from:httpDate)
        }

        /// Helper function to read bytes (of a given range) of a file into data
        static func read(contentsOfFile filePath: String, inRange range: Range<UInt64>) -> Data? {
            let file = FileHandle(forReadingAtPath: filePath)
            file?.seek(toFileOffset: range.lowerBound)
            // range is inclusive to make sure to increate upper bound by 1
            let data = file?.readData(ofLength: range.count + 1)
            file?.closeFile()
            return data
        }
    }
}
