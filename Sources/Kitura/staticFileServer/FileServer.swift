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

        init(servingFilesPath: String, options: StaticFileServer.Options,
             responseHeadersSetter: ResponseHeadersSetter?) {
            self.possibleExtensions = options.possibleExtensions
            self.serveIndexForDirectory = options.serveIndexForDirectory
            self.redirect = options.redirect
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
                matchedPath = String(matchedPath.characters.dropLast())
            }
            if !matchedPath.hasSuffix("/") {
                matchedPath += "/"
            }

            if requestPath.hasPrefix(matchedPath) {
                filePath += "/"
                let url = String(requestPath.characters.dropFirst(matchedPath.characters.count))
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
                #if os(Linux)
                    let isDirectoryBool = isDirectory
                #else
                    let isDirectoryBool = isDirectory.boolValue
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
                #if os(Linux)
                    let isDirectoryBool = isDirectory
                #else
                    let isDirectoryBool = isDirectory.boolValue
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
                responseHeadersSetter?.setCustomResponseHeaders(response: response,
                                                                filePath: filePath,
                                                                fileAttributes: fileAttributes)

                try response.send(fileName: filePath)
            } catch {
                Log.error("serving file at path \(filePath) error: \(error)")
            }
            response.statusCode = .OK
        }
        
        func streamFile(_ filePath: String, request: RouterRequest, response: RouterResponse) {
            let fileManager = FileManager()
            var isDirectory = ObjCBool(false)
            
            if fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory) {
                #if os(Linux)
                    let isDirectoryBool = isDirectory
                #else
                    let isDirectoryBool = isDirectory.boolValue
                #endif
                
                if !isDirectoryBool {
                    streamNonDirectoryFile(filePath, request: request, response: response)
                    return
                }
            }
        }
        
        @discardableResult
        private func streamNonDirectoryFile(_ filePath: String, request: RouterRequest, response: RouterResponse) -> Bool {
            if  !isValidFilePath(filePath) {
                return false
            }
            
            do {
                let fileAttributes = try FileManager().attributesOfItem(atPath: filePath)
                responseHeadersSetter?.setCustomResponseHeaders(response: response,
                                                                filePath: filePath,
                                                                fileAttributes: fileAttributes)
                
                let rangeInfo = request.headers["Range"]?.components(separatedBy: "=")
                
                guard let rangeUnit = rangeInfo?.first,
                    rangeUnit == "bytes",
                    var byteRanges = rangeInfo?.last?.components(separatedBy: "-"),
                    byteRanges.count == 2 else {
                    response.statusCode = .badRequest
                    return false
                }
                
                guard let streamData = try? Data(contentsOf: URL(fileURLWithPath: filePath), options: [.mappedIfSafe]) else {
                    return false
                }
                
                let startByte, stopByte: Int
                
                if byteRanges[0] == "" {
                    startByte = max(0, streamData.count - (Int(byteRanges[1]) ?? 1))
                    stopByte = streamData.count - 1
                } else {
                    startByte = max(0, Int(byteRanges[0]) ?? 0)
                    stopByte = min(streamData.count - 1, Int(byteRanges[1]) ?? streamData.count - 1)
                }
                
                guard startByte < stopByte else {
                    response.statusCode = .badRequest
                    return false
                }
                
                let dataRange = streamData.subdata(in: startByte..<stopByte + 1)
                
                let contentType = ContentType.sharedInstance.getContentType(forFileName: filePath)
                if let contentType = contentType {
                    response.headers["Content-Type"] = contentType
                }
                response.headers["Content-Range"] = "bytes \(startByte)-\(stopByte)/\(streamData.count)"
                response.headers["Accept-Ranges"] = "bytes"
                response.headers["Content-Length"] = String(describing: stopByte - startByte + 1)
                
                response.send(data: dataRange)
            } catch {
                Log.error("serving file at path \(filePath) error: \(error)")
            }
            
            response.statusCode = .partialContent
            
            return true
        }

        private func isValidFilePath(_ filePath: String) -> Bool {
            // Check that no-one is using ..'s in the path to poke around the filesystem
            let absoluteBasePath = NSURL(fileURLWithPath: servingFilesPath).absoluteString
            let absoluteFilePath = NSURL(fileURLWithPath: filePath).absoluteString
            #if os(Linux)
                return  absoluteFilePath.hasPrefix(absoluteBasePath)
            #else
                return  absoluteFilePath!.hasPrefix(absoluteBasePath!)
            #endif
        }
    }
}
