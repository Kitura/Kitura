/*
 * Copyright IBM Corporation 2016,2017
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

// MARK: StaticFileServer

/// A router middleware that serves static files from a given path.
open class StaticFileServer: RouterMiddleware {

    /// Cache configuration options for StaticFileServer.
    public struct CacheOptions {
        let addLastModifiedHeader: Bool
        let maxAgeCacheControlHeader: Int
        let generateETag: Bool

        /// Initialize a CacheOptions instance.
        ///
        /// - Parameter addLastModifiedHeader: an indication whether to set
        /// "Last-Modified" header in the response.
        /// - Parameter maxAgeCacheControlHeader: a max-age in milliseconds for
        /// "max-age" value in "Cache-Control" header in the response
        /// - Parameter generateETag: an indication whether to set "Etag"
        /// header in the response.
        public init(addLastModifiedHeader: Bool = true, maxAgeCacheControlHeader: Int = 0,
             generateETag: Bool = true) {
            self.addLastModifiedHeader = addLastModifiedHeader
            self.maxAgeCacheControlHeader = maxAgeCacheControlHeader
            self.generateETag = generateETag
        }
    }

    /// Configuration options for StaticFileServer.
    public struct Options {
        let possibleExtensions: [String]
        let redirect: Bool
        let serveIndexForDirectory: Bool
        let cacheOptions: CacheOptions
        let acceptRanges: Bool

        /// Initialize an Options instance.
        ///
        /// - Parameter possibleExtensions: an array of file extensions to be added
        /// to the file name in case the file was not found. The extensions are 
        /// added in the order they appear in the array, and a new search is 
        /// performed.
        /// - Parameter serveIndexForDirectory: an indication whether to serve
        /// "index.html" file the requested path is a directory.
        /// - Parameter redirect: an indication whether to redirect to trailing
        /// "/" when the requested path is a directory.
        /// - Parameter cacheOptions: cache options for StaticFileServer.
        public init(possibleExtensions: [String] = [], serveIndexForDirectory: Bool = true,
             redirect: Bool = true, cacheOptions: CacheOptions = CacheOptions(), acceptRanges: Bool = true) {
            self.possibleExtensions = possibleExtensions
            self.serveIndexForDirectory = serveIndexForDirectory
            self.redirect = redirect
            self.cacheOptions = cacheOptions
            self.acceptRanges = acceptRanges
        }
    }

    public let absoluteRootPath: String

    let fileServer: FileServer

    /// Initializes a `StaticFileServer` instance.
    ///
    /// - Parameter path: a root directory for file serving.
    /// - Parameter options: configuration options for StaticFileServer.
    /// - Parameter customResponseHeadersSetter: an object of a class that
    /// implements `ResponseHeadersSetter` protocol providing a custom method to set
    /// the headers of the response.
    public init(path: String = "./public", options: Options = Options(),
                 customResponseHeadersSetter: ResponseHeadersSetter? = nil) {
        absoluteRootPath = StaticFileServer.ResourcePathHandler.getAbsolutePath(for: path)

        let cacheOptions = options.cacheOptions
        let cacheRelatedHeadersSetter =
            CacheRelatedHeadersSetter(addLastModifiedHeader: cacheOptions.addLastModifiedHeader,
                                      maxAgeCacheControlHeader: cacheOptions.maxAgeCacheControlHeader,
                                      generateETag: cacheOptions.generateETag)

        let responseHeadersSetter = CompositeRelatedHeadersSetter(setters: cacheRelatedHeadersSetter,
                                                                  customResponseHeadersSetter)

        fileServer = FileServer(servingFilesPath: absoluteRootPath, options: options,
                                responseHeadersSetter: responseHeadersSetter)
    }

    /// Handle the request - serve static file.
    ///
    /// - Parameter request: The `RouterRequest` object used to work with the incoming
    ///                     HTTP request.
    /// - Parameter response: The `RouterResponse` object used to respond to the
    ///                     HTTP request.
    /// - Parameter next: The closure called to invoke the next handler or middleware
    ///                     associated with the request.
    open func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        defer {
            next()
        }

        guard request.serverRequest.method == "GET" || request.serverRequest.method == "HEAD" else {
            return
        }

        guard let filePath = fileServer.getFilePath(from: request) else {
            return
        }

        guard let requestPath = request.parsedURLPath.path else {
            return
        }

        fileServer.serveFile(filePath, requestPath: requestPath, response: response)
    }
}
