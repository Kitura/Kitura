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

        private static let kituraResourcePrefix = "/@@Kitura-router@@/"

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

        internal func isRequestForKituraResource(in request: RouterRequest) -> Bool {
            guard let requestPath = request.parsedURLPath.path else {
                return false
            }
            if requestPath.hasPrefix(FileServer.kituraResourcePrefix) {
                return true
            }
            return false
        }

        internal func getKituraResourcePath(from request: RouterRequest, for response: RouterResponse) -> String? {
            var filePath = servingFilesPath + "/"
            guard let requestPath = request.parsedURLPath.path else {
                return nil
            }
            #if swift(>=3.2)
                let url = String(requestPath[FileServer.kituraResourcePrefix.endIndex...])
            #else
                let url = requestPath.substring(from: FileServer.kituraResourcePrefix.endIndex)
            #endif
            if let decodedURL = url.removingPercentEncoding {
                filePath += decodedURL
            } else {
                Log.warning("unable to decode url \(url)")
                do {
                    try response.status(.badRequest).end()
                } catch {
                    Log.error("Unable to send \"Invalid Request\" for url: \(url) from request path: \(requestPath)")
                }
                return nil
            }

            if filePath.hasSuffix("/") {
                filePath += "index.html"
            }
            return filePath
        }

        func getFilePath(from request: RouterRequest, for response: RouterResponse) -> String? {
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
                    do {
                        try response.status(.badRequest).end()
                    } catch {
                        Log.error("Unable to send \"Invalid Request\" for url: \(url) from request path: \(requestPath)")
                    }
                    return nil
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
            if  !isValidFilePath(filePath) {
                Log.error("Invalid request for resource: \(filePath) from request path: \(requestPath)")
                do {
                    try response.status(.badRequest).end()
                } catch {
                    Log.error("Unable to send \"Invalid Request\" for: \(filePath) from request path: \(requestPath)")
                }
                return
            }
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

            if !tryToServeWithExtensions(filePath, response: response) {
                do {
                    try response.send("Cannot GET \(requestPath)").status(.notFound).end()
                } catch {
                    Log.error("failed to send not found response for resource: \(filePath)")
                }
            }
        }

        private func tryToServeWithExtensions(_ filePath: String, response: RouterResponse) -> Bool {
            let filePathWithPossibleExtensions = possibleExtensions.map { filePath + "." + $0 }
            for filePathWithExtension in filePathWithPossibleExtensions {
                if serveIfNonDirectoryFile(atPath: filePathWithExtension, response: response) {
                    return true
                }
            }
            return false
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
                    return serveNonDirectoryFile(path, response: response)
                }
            }
            return false
        }

        @discardableResult
        private func serveNonDirectoryFile(_ filePath: String, response: RouterResponse) -> Bool {
            do {
                let fileAttributes = try FileManager().attributesOfItem(atPath: filePath)
                responseHeadersSetter?.setCustomResponseHeaders(response: response,
                                                                filePath: filePath,
                                                                fileAttributes: fileAttributes)

                try response.send(fileName: filePath)
            } catch {
                Log.error("serving file at path \(filePath) error: \(error)")
                return false
            }
            response.statusCode = .OK
            return true
        }

        private func isValidFilePath(_ filePath: String) -> Bool {
            // Check that no-one is using ..'s in the path to poke around the filesystem
            guard let absoluteBasePath = NSURL(fileURLWithPath: servingFilesPath).standardizingPath?.absoluteString, let standardisedPath = NSURL(fileURLWithPath: filePath).standardizingPath?.absoluteString else {
                return false
            }
            return  standardisedPath.hasPrefix(absoluteBasePath)
        }
    }
}
