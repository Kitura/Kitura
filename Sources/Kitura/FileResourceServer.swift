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

class FileResourceServer {

    /// if file found - send it in response
    func sendIfFound(resource: String, usingResponse response: RouterResponse) {
        guard let resourceFileName = getFilePath(for: resource) else {
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
        #if os(Linux)
            let fileManager = FileManager.default()
        #else
            let fileManager = FileManager.default
        #endif
        let potentialResource = getResourcePathBasedOnSourceLocation(for: resource)

        let fileExists = fileManager.fileExists(atPath: potentialResource)
        if fileExists {
            return potentialResource
        } else {
            return getResourcePathBasedOnCurrentDirectory(for: resource, withFileManager: fileManager)
        }
    }

    private func getResourcePathBasedOnSourceLocation(for resource: String) -> String {
        let fileName = NSString(string: #file)
        let resourceFilePrefixRange: NSRange
        let lastSlash = fileName.range(of: "/", options: .backwards)
        if  lastSlash.location != NSNotFound {
            resourceFilePrefixRange = NSMakeRange(0, lastSlash.location+1)
        } else {
            resourceFilePrefixRange = NSMakeRange(0, fileName.length)
        }
        return fileName.substring(with: resourceFilePrefixRange) + "resources/" + resource
    }

    private func getResourcePathBasedOnCurrentDirectory(for resource: String, withFileManager fileManager: FileManager) -> String? {
        do {
            let packagePath = fileManager.currentDirectoryPath + "/Packages"
            let packages = try fileManager.contentsOfDirectory(atPath: packagePath)
            for package in packages {
                let potentalResource = "\(packagePath)/\(package)/Sources/Kitura/resources/\(resource)"
                let resourceExists = fileManager.fileExists(atPath: potentalResource)
                if resourceExists {
                    return potentalResource
                }
            }
        } catch {
            return nil
        }
        return nil
    }
}
