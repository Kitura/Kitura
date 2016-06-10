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


import KituraNet
import LoggerAPI
import Foundation

// MARK: StaticFileServer

public class StaticFileServer: RouterMiddleware {
    private struct Configuration {
        //
        // If a file is not found, the given extensions will be added to the file name and searched for. The first that exists will be served. Example: ['html', 'htm'].
        //
        private let possibleExtensions: [String]

        //
        // Serve "index.html" files in response to a request on a directory.  Defaults to true.
        //
        private let serveIndexForDirectory: Bool

        //
        // Uses the file system's last modified value.  Defaults to true.
        //
        private let addLastModifiedHeader: Bool

        //
        // Value of max-age in Cache-Control header.  Defaults to 0.
        //
        private let maxAgeCacheControlHeader: Int

        //
        // Redirect to trailing "/" when the pathname is a dir. Defaults to true.
        //
        private let redirect: Bool

        //
        // Generate ETag. Defaults to true.
        //
        private var generateETag: Bool
    }

    //
    // configuration
    //
    private let configuration: Configuration


    //
    // A setter for custom response headers.
    //
    private let customResponseHeadersSetter: ResponseHeadersSetter?

    private let path: String

    public convenience init (options: [Options]) {
        self.init(path: "./public", options: options)
    }

    public convenience init () {
        self.init(path: "./public")
    }

    ///
    /// Initializes a StaticFileServer instance
    ///
    public init (path: String, options: [Options] = [Options]()) {
        var path = path
        if path.hasSuffix("/") {
            path = String(path.characters.dropLast())
        }

        // If we received a path with a tlde (~) in the front, expand it.
#if os(Linux)
        self.path = path.bridge().stringByExpandingTildeInPath
#else
        self.path = path.bridge().expandingTildeInPath
#endif

        var possibleExtensions = [String]()
        var serveIndexForDirectory = true
        var addLastModifiedHeader = true
        var maxAgeCacheControlHeader = 0
        var redirect = true
        var generateETag = true
        var customResponseHeadersSetter: ResponseHeadersSetter?

        for option in options {
            switch option {
            case .possibleExtensions(let value):
                possibleExtensions = value
            case .serveIndexForDir(let value):
                serveIndexForDirectory = value
            case .addLastModifiedHeader(let value):
                addLastModifiedHeader = value
            case .maxAgeCacheControlHeader(let value):
                maxAgeCacheControlHeader = value
            case .redirect(let value):
                redirect = value
            case .customResponseHeadersSetter(let value):
                customResponseHeadersSetter = value
            case .generateETag (let value):
                generateETag = value
            }
        }

        self.customResponseHeadersSetter = customResponseHeadersSetter
        configuration = Configuration(possibleExtensions: possibleExtensions, serveIndexForDirectory: serveIndexForDirectory, addLastModifiedHeader: addLastModifiedHeader, maxAgeCacheControlHeader: maxAgeCacheControlHeader, redirect: redirect, generateETag: generateETag)
    }

    ///
    /// Handle the request
    ///
    /// - Parameter request: the router request
    /// - Parameter response: the router response
    /// - Parameter next: the closure for the next execution block
    ///
    public func handle (request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard request.serverRequest.method == "GET" || request.serverRequest.method == "HEAD" else {
            return next()
        }

        guard let filePath = getFilePath(from: request) else {
            return next()
        }

        guard let requestPath = request.parsedURL.path else {
            return next()
        }

        serveFile(filePath, requestPath: requestPath, response: response)
        next()
    }

    private func getFilePath(from request: RouterRequest) -> String? {
        var filePath = path
        guard let requestPath = request.parsedURL.path else {
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
            let url = String(requestPath.characters.dropFirst(matchedPath.characters.count))
            filePath += "/" + url
        }

        if filePath.hasSuffix("/") {
            if configuration.serveIndexForDirectory {
                filePath += "index.html"
            } else {
                return nil
            }
        }

        return filePath
    }

    private func serveFile(_ filePath: String, requestPath: String, response: RouterResponse) {
        let fileManager = NSFileManager()
        var isDirectory = ObjCBool(false)

        if fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory) {
            serveExistingFile(filePath, requestPath: requestPath,
                              isDirectory: isDirectory.boolValue, response: response)
            return
        }

        tryToServeWithExtensions(filePath, response: response)
    }

    private func tryToServeWithExtensions(_ filePath: String, response: RouterResponse) {
        let filePathWithPossibleExtensions = configuration.possibleExtensions.map { filePath + "." + $0 }
        for filePathWithExtension in filePathWithPossibleExtensions {
            let fileManager = NSFileManager()
            var isDirectory = ObjCBool(false)
            if fileManager.fileExists(atPath: filePathWithExtension, isDirectory: &isDirectory) {
                if !isDirectory.boolValue {
                    serveNonDirectoryFile(filePathWithExtension, response: response)
                    break
                }
            }
        }
    }

    private func serveExistingFile(_ filePath: String, requestPath: String, isDirectory: Bool,
                                   response: RouterResponse) {
        if isDirectory {
            if configuration.redirect {
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

    private func serveNonDirectoryFile(_ filePath: String, response: RouterResponse) {
        let fileManager = NSFileManager()

        // Check that no-one is using ..'s in the path to poke around the filesystem
        let tempAbsoluteBasePath = NSURL(fileURLWithPath: path).absoluteString
        let tempAbsoluteFilePath = NSURL(fileURLWithPath: filePath).absoluteString
        let absoluteBasePath = tempAbsoluteBasePath
        let absoluteFilePath = tempAbsoluteFilePath

        if  !absoluteFilePath.hasPrefix(absoluteBasePath) {
            return
        }

        do {
            let attributes = try fileManager.attributesOfItem(atPath: filePath)

            response.headers["Cache-Control"] = "max-age=\(configuration.maxAgeCacheControlHeader)"
            addLastModifiedHeader(response: response, attributes: attributes)
            addETag(response: response, attributes: attributes)

            customResponseHeadersSetter?.setCustomResponseHeaders(response: response,
                                                                  filePath: filePath,
                                                                  fileAttributes: attributes)

            try response.send(fileName: filePath)
        } catch {
            Log.error("serving file at path \(filePath) error: \(error)")
        }
        response.statusCode = .OK
    }

    private func addLastModifiedHeader(response: RouterResponse, attributes: [String : AnyObject]) {
        if configuration.addLastModifiedHeader {
            if let date = attributes[NSFileModificationDate] as? NSDate {
                response.headers["Last-Modified"] = SPIUtils.httpDate(date)
            }
        }
    }

    private func addETag(response: RouterResponse, attributes: [String : AnyObject]) {
        if configuration.generateETag {
            if let date = attributes[NSFileModificationDate] as? NSDate,
                let size = attributes[NSFileSize] as? Int {
                let sizeHex = String(size, radix: 16, uppercase: false)
                let timeHex = String(Int(date.timeIntervalSince1970), radix: 16, uppercase: false)
                let etag = "W/\"\(sizeHex)-\(timeHex)\""
                response.headers["Etag"] = etag
            }
        }
    }

    public enum Options {
        case possibleExtensions([String])
        case serveIndexForDir(Bool)
        case addLastModifiedHeader(Bool)
        case maxAgeCacheControlHeader(Int)
        case redirect(Bool)
        case customResponseHeadersSetter(ResponseHeadersSetter)
        case generateETag(Bool)
    }

}
