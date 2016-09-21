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

    // MARK: ResourcePathHandler
    class ResourcePathHandler {
        static private let separatorCharacter: Character = "/"
        static private let separator = String(separatorCharacter)

        static func getAbsolutePath(for path: String) -> String {
            var path = path
            if path.hasSuffix(separator) {
                path = String(path.characters.dropLast())
            }

            // If we received a path with a tilde (~) in the front, expand it.
            path = NSString(string: path).expandingTildeInPath

            if isAbsolute(path: path) {
                return path
            }


            let fileManager = FileManager()

            let absolutePath = fileManager.currentDirectoryPath + separator + path
            if fileManager.fileExists(atPath: absolutePath) {
                return absolutePath
            }

            // the file does not exist on a path relative to the current working directory
            // return the path relative to the original repository directory
            return getOriginalRepositoryPath() + separator + path
        }

        static private func getOriginalRepositoryPath() -> String {
        // this file is at
        // <original repository directory>/Sources/Kitura/staticFileServer/ResourcePathHandler.swift
        // the original repository directory is four path components up
            let currentFilePath = #file

            var pathComponents =
                currentFilePath.characters.split(separator: separatorCharacter).map(String.init)
            let numberOfComponentsFromOriginalRepositoryDirectoryToThisFile = 4
            pathComponents.removeLast(numberOfComponentsFromOriginalRepositoryDirectoryToThisFile)
            return separator + pathComponents.joined(separator: separator)
        }

        static private func isAbsolute(path: String) -> Bool {
            return path.hasPrefix(separator)
        }

        static private func isSeparator(_ string: String) -> Bool {
            return string == separator
        }
    }
}
