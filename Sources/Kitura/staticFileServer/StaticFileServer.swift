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
    public enum Options {
        case possibleExtensions([String])
        case serveIndexForDir(Bool)
        case addLastModifiedHeader(Bool)
        case maxAgeCacheControlHeader(Int)
        case redirect(Bool)
        case customResponseHeadersSetter(ResponseHeadersSetter)
        case generateETag(Bool)
    }

    let fileServer: FileServer

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
        path = path.bridge().stringByExpandingTildeInPath
#else
        path = path.bridge().expandingTildeInPath
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

        let cacheRelatedHeadersSetter =
            CacheRelatedHeadersSetter(addLastModifiedHeader: addLastModifiedHeader,
                                      maxAgeCacheControlHeader: maxAgeCacheControlHeader,
                                      generateETag: generateETag)

        let responseHeadersSetter = CompositeRelatedHeadersSetter(setters: cacheRelatedHeadersSetter, customResponseHeadersSetter)

        fileServer = FileServer(serveIndexForDirectory: serveIndexForDirectory, redirect: redirect,
                                servingFilesPath: path, possibleExtensions: possibleExtensions,
                                responseHeadersSetter: responseHeadersSetter)
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

        guard let filePath = fileServer.getFilePath(from: request) else {
            return next()
        }

        guard let requestPath = request.parsedURL.path else {
            return next()
        }

        fileServer.serveFile(filePath, requestPath: requestPath, response: response)
        next()
    }
}
