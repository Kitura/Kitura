
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

import LoggerAPI
import Foundation

extension StaticFileServer {

    // MARK: ResourcePathHandler
    class ResourcePathHandler {
        static private let separatorCharacter: Character = "/"
        static private let separator = String(separatorCharacter)

        static func getAbsolutePath(for path: String) -> String {
            var path = path
            if path.hasSuffix(separator) && path != separator {
                path = String(path.dropLast())
            }

            // If we received a path with a tilde (~) in the front, expand it.
            path = NSString(string: path).expandingTildeInPath

            if isAbsolute(path: path) {
                return path
            }

            let fileManager = FileManager()
            let absolutePath: String
            #if os(iOS)
                guard let resourcePath = Bundle.main.resourcePath else {
                    return path
                }
                absolutePath = resourcePath + separator + path
            #else
                absolutePath = fileManager.currentDirectoryPath + separator + path
            #endif

            if fileManager.fileExists(atPath: absolutePath) {
                return absolutePath
            }

            // the file does not exist on a path relative to the current working directory
            // return the path relative to the original repository directory
            guard let originalRepositoryPath = getOriginalRepositoryPath() else {
                return absolutePath
            }

            return originalRepositoryPath + separator + path
        }

        static private func getOriginalRepositoryPath() -> String? {
        // this file is at
        // <original repository directory>/Sources/Kitura/staticFileServer/ResourcePathHandler.swift
        // the original repository directory is four path components up
            let currentFilePath = #file

            var pathComponents =
                currentFilePath.split(separator: separatorCharacter).map(String.init)
            let numberOfComponentsFromKituraRepositoryDirectoryToThisFile = 4

            guard pathComponents.count >= numberOfComponentsFromKituraRepositoryDirectoryToThisFile else {
                Log.error("unable to get original repository path for \(currentFilePath)")
                return nil
            }

            pathComponents.removeLast(numberOfComponentsFromKituraRepositoryDirectoryToThisFile)
            pathComponents = removePackagesDirectory(pathComponents: pathComponents)

            return separator + pathComponents.joined(separator: separator)
        }

        static private func removePackagesDirectory(pathComponents: [String]) -> [String] {
            var pathComponents = pathComponents
            let numberOfComponentsFromKituraPackageToDependentRepository = 3
            let packagesComponentIndex = pathComponents.endIndex - numberOfComponentsFromKituraPackageToDependentRepository
            if pathComponents.count > numberOfComponentsFromKituraPackageToDependentRepository &&
                pathComponents[packagesComponentIndex] == ".build"  &&
                pathComponents[packagesComponentIndex+1] == "checkouts" {
                pathComponents.removeLast(numberOfComponentsFromKituraPackageToDependentRepository)
            }
            else {
                let numberOfComponentsFromEditableKituraPackageToDependentRepository = 2
                let editablePackagesComponentIndex = pathComponents.endIndex - numberOfComponentsFromEditableKituraPackageToDependentRepository
                if pathComponents.count > numberOfComponentsFromEditableKituraPackageToDependentRepository &&
                    pathComponents[editablePackagesComponentIndex] == "Packages" {
                    pathComponents.removeLast(numberOfComponentsFromEditableKituraPackageToDependentRepository)
                }
            }
            return pathComponents
        }
        static private func isAbsolute(path: String) -> Bool {
            return path.hasPrefix(separator)
        }
    }
}
