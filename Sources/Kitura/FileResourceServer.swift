/*
 * Copyright IBM Corporation 2016, 2017
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

class FileResourceServer {

    /// if file found - send it in response
    func sendIfFound(resource: String, usingResponse response: RouterResponse) {
        guard let resourceFileName = getFilePath(for: resource) else {
            do {
                try response.send("Cannot find resource: \(resource)").status(.notFound).end()
            } catch {
                Log.error("failed to send not found response for resource: \(resource)")
            }
            return
        }

        do {
            try response.send(fileName: resourceFileName)
            try response.status(.OK).end()
        } catch {
            Log.error("failed to send response with resource \(resourceFileName)")
        }
    }

    private func getFilePath(for resource: String) -> String? {
        var candidatePath: String? = nil
        var basePath: String? = nil
        let fileManager = FileManager.default
        var potentialResource = getResourcePathBasedOnSourceLocation(for: resource)

        if potentialResource.hasSuffix("/") {
            potentialResource += "index.html"
        }

        let fileExists = fileManager.fileExists(atPath: potentialResource)
        if fileExists {
            candidatePath = potentialResource
            basePath = getResourcePathBasedOnSourceLocation(for: "")
        } else {
            candidatePath = getResourcePathBasedOnCurrentDirectory(for: resource, withFileManager: fileManager)
            basePath = getResourcePathBasedOnCurrentDirectory(for: "", withFileManager: fileManager)
        }
        // We need to ensure we are only serving kitura resources so need to decode the file path and then check it has Sources/Kitura/resources before the last element
        guard isValidPath(resourcePath: candidatePath, basePath: basePath) else {
            return nil
        }
        return candidatePath
    }

    func isValidPath(resourcePath: String?, basePath: String?) -> Bool {
        guard let resource = resourcePath,
            let base = basePath,
            let absoluteBasePath = NSURL(fileURLWithPath: base).standardizingPath?.absoluteString,
            let standardisedPath = NSURL(fileURLWithPath: resource).standardizingPath?.absoluteString else {
            return false
        }
        return  standardisedPath.hasPrefix(absoluteBasePath)
    }

    private func getResourcePathBasedOnSourceLocation(for resource: String) -> String {
        let fileName = NSString(string: #file)
        let resourceFilePrefixRange: NSRange
        let lastSlash = fileName.range(of: "/", options: .backwards)
        if  lastSlash.location != NSNotFound {
            resourceFilePrefixRange = NSRange(location: 0, length: lastSlash.location+1)
        } else {
            resourceFilePrefixRange = NSRange(location: 0, length: fileName.length)
        }
        return fileName.substring(with: resourceFilePrefixRange) + "resources/" + resource
    }

    private func getResourcePathBasedOnCurrentDirectory(for resource: String, withFileManager fileManager: FileManager) -> String? {
        for suffix in ["/Packages", "/.build/checkouts"] {
            let packagePath: String
            #if os(iOS)
                guard let resourcePath = Bundle.main.resourcePath else {
                    continue
                }
                packagePath = resourcePath + suffix
            #else
                packagePath = fileManager.currentDirectoryPath + suffix
            #endif

            do {
                let packages = try fileManager.contentsOfDirectory(atPath: packagePath)
                for package in packages {
                    let potentialResource = "\(packagePath)/\(package)/Sources/Kitura/resources/\(resource)"
                    let resourceExists = fileManager.fileExists(atPath: potentialResource)
                    if resourceExists {
                        return potentialResource
                    }
                }
            } catch {
              Log.error("No packages found in \(packagePath)")
            }
        }
        return nil
    }
}
