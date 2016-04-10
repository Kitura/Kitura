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

import Foundation

// MARK: StaticFileServer

public class StaticFileServer : RouterMiddleware {

    //
    // If a file is not found, the given extensions will be added to the file name and searched for. The first that exists will be served. Example: ['html', 'htm'].
    //
    private var possibleExtensions : [String]?

    //
    // Serve "index.html" files in response to a request on a directory.  Defaults to true.
    //
    private var serveIndexForDir = true

    //
    // Uses the file system's last modified value.  Defaults to true.
    //
    private var addLastModifiedHeader = true

    //
    // Value of max-age in Cache-Control header.  Defaults to 0.
    //
    private var maxAgeCacheControlHeader = 0

    //
    // Redirect to trailing "/" when the pathname is a dir. Defaults to true.
    //
    private var redirect = true

    //
    // A setter for custom response headers.
    //
    private var customResponseHeadersSetter : ResponseHeadersSetter?

    //
    // Generate ETag. Defaults to true.
    //
    private var generateETag = true



    private var path : String

    public convenience init (options: [Options]) {
        self.init(path: "./public", options: options)
    }

    public convenience init () {
        self.init(path: "./public", options: nil)
    }

    ///
    /// Initializes a StaticFileServer instance
    ///
    public init (path: String, options: [Options]?) {
        if path.hasSuffix("/") {
            self.path = String(path.characters.dropLast())
        }
        else {
            self.path = path
        }
        // If we received a path with a tlde (~) in the front, expand it.
#if os(Linux)  
        self.path = self.path.bridge().stringByExpandingTildeInPath
#else
        self.path = self.path.bridge().expandingTildeInPath
#endif
        if let options = options {
            for option in options {
                switch option {
                case .PossibleExtensions(let value):
                    possibleExtensions = value
                case .ServeIndexForDir(let value):
                    serveIndexForDir = value
                case .AddLastModifiedHeader(let value):
                    addLastModifiedHeader = value
                case .MaxAgeCacheControlHeader(let value):
                    maxAgeCacheControlHeader = value
                case .Redirect(let value):
                    redirect = value
                case .CustomResponseHeadersSetter(let value):
                    customResponseHeadersSetter = value
                case .GenerateETag (let value):
                    generateETag = value
                }
            }
        }
    }
    
    ///
    /// Handle the request
    ///
    /// - Parameter request: the router request
    /// - Parameter response: the router response
    /// - Parameter next: the closure for the next execution block
    ///
    public func handle (request: RouterRequest, response: RouterResponse, next: () -> Void) {
        if (request.serverRequest.method != "GET" && request.serverRequest.method != "HEAD") {
            next()
            return
        }
        
        var filePath = path
        let originalUrl = request.originalUrl
        if let requestRoute = request.route {
            var route = requestRoute
            if route.hasSuffix("*") {
                route = String(route.characters.dropLast())
            }
            if !route.hasSuffix("/") {
                route += "/"
            }

            if originalUrl.hasPrefix(route) {
                let url = String(originalUrl.characters.dropFirst(route.characters.count))
                filePath += "/" + url
            }
        }

        if filePath.hasSuffix("/") {
            if serveIndexForDir {
                filePath += "index.html"
            }
            else {
                next()
                return
            }
        }
        
        let fileManager = NSFileManager()
        var isDirectory = ObjCBool(false)
#if os(Linux)  
        let fileExists = fileManager.fileExistsAtPath(filePath, isDirectory: &isDirectory)
#else
        let fileExists = fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory)
#endif
        if fileExists {
            if isDirectory.boolValue {
                if redirect {
                    do {
                        try response.redirect(originalUrl + "/")
                    }
                    catch {
                        response.error = Router.Error.FailedToRedirectRequest
                    }
                }
            }
            else {
                serveFile(filePath, fileManager: fileManager, response: response)
            }
        }
        else {
            if let _ = possibleExtensions {
                for ext in possibleExtensions! {
                    let newFilePath = filePath + "." + ext
#if os(Linux)  
                    let newFileExists = fileManager.fileExistsAtPath(newFilePath, isDirectory: &isDirectory)
#else
                    let newFileExists = fileManager.fileExists(atPath: newFilePath, isDirectory: &isDirectory)
#endif
                    if newFileExists {
                        if !isDirectory.boolValue {
                            serveFile(newFilePath, fileManager: fileManager, response: response)
                            break
                        }
                    }
                }
            }
        }

        next()

    }

    private func serveFile(filePath: String, fileManager: NSFileManager, response: RouterResponse) {
        // Check that no-one is using ..'s in the path to poke around the filesystem
        let tempAbsoluteBasePath = NSURL(fileURLWithPath: path).absoluteString
        let tempAbsoluteFilePath = NSURL(fileURLWithPath: filePath).absoluteString
        let absoluteBasePath = tempAbsoluteBasePath
        let absoluteFilePath = tempAbsoluteFilePath

        if  absoluteFilePath.hasPrefix(absoluteBasePath)  {
            do {
#if os(Linux)  
                let attributes = try fileManager.attributesOfItemAtPath(filePath)
#else
                let attributes = try fileManager.attributesOfItem(atPath: filePath)
#endif
                response.setHeader("Cache-Control", value: "max-age=\(maxAgeCacheControlHeader)")
                if addLastModifiedHeader {
                    if let date = attributes[NSFileModificationDate] as? NSDate {
                        response.setHeader("Last-Modified", value: SpiUtils.httpDate(date))
                    }
                }
                if generateETag {
                    if let date = attributes[NSFileModificationDate] as? NSDate,
                        let size = attributes[NSFileSize] as? Int {
                            let sizeHex = String(size, radix: 16, uppercase: false)
                            let timeHex = String(Int(date.timeIntervalSince1970), radix: 16, uppercase: false)
                            let etag = "W/\"\(sizeHex)-\(timeHex)\""
                        response.setHeader("Etag", value: etag)
                    }
                }
                if let _ = customResponseHeadersSetter {
                    customResponseHeadersSetter!.setCustomResponseHeaders(response, filePath: filePath, fileAttributes: attributes)
                }

                try response.sendFile(filePath)
            }
            catch {
                // Nothing
            }
            response.status(HttpStatusCode.OK)
        }
    }

    public enum Options {
        case PossibleExtensions([String])
        case ServeIndexForDir(Bool)
        case AddLastModifiedHeader(Bool)
        case MaxAgeCacheControlHeader(Int)
        case Redirect(Bool)
        case CustomResponseHeadersSetter(ResponseHeadersSetter)
        case GenerateETag(Bool)
    }

}

#if os(Linux)
    public typealias CustomResponseHeaderAttributes = [String : Any]
#else
    public typealias CustomResponseHeaderAttributes = [String : AnyObject]
#endif

public protocol ResponseHeadersSetter {
    
    func setCustomResponseHeaders (response: RouterResponse, filePath: String, fileAttributes: CustomResponseHeaderAttributes)
    
}



