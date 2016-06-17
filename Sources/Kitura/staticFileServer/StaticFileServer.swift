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

// MARK: StaticFileServer

public class StaticFileServer: RouterMiddleware {
    public struct Options {
        let possibleExtensions: [String]
        let serveIndexForDirectory: Bool
        let addLastModifiedHeader: Bool
        let maxAgeCacheControlHeader: Int
        let redirect: Bool
        let generateETag: Bool

        init(possibleExtensions: [String] = [], serveIndexForDirectory: Bool = true,
             addLastModifiedHeader: Bool = true, maxAgeCacheControlHeader: Int = 0,
             redirect: Bool = true, generateETag: Bool = true) {
            self.possibleExtensions = possibleExtensions
            self.serveIndexForDirectory = serveIndexForDirectory
            self.addLastModifiedHeader = addLastModifiedHeader
            self.maxAgeCacheControlHeader = maxAgeCacheControlHeader
            self.redirect = redirect
            self.generateETag = generateETag
        }
    }

    let fileServer: FileServer

    ///
    /// Initializes a StaticFileServer instance
    ///
    public init (path: String = "./public", options: Options = Options(),
                 customResponseHeadersSetter: ResponseHeadersSetter? = nil) {
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

        let cacheRelatedHeadersSetter =
            CacheRelatedHeadersSetter(addLastModifiedHeader: options.addLastModifiedHeader,
                                      maxAgeCacheControlHeader: options.maxAgeCacheControlHeader,
                                      generateETag: options.generateETag)

        let responseHeadersSetter = CompositeRelatedHeadersSetter(setters: cacheRelatedHeadersSetter,
                                                                  customResponseHeadersSetter)

        fileServer = FileServer(serveIndexForDirectory: options.serveIndexForDirectory,
                                redirect: options.redirect, servingFilesPath: path,
                                possibleExtensions: options.possibleExtensions,
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
