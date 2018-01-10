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

import KituraNet
import Foundation

extension StaticFileServer {

    class CacheRelatedHeadersSetter: ResponseHeadersSetter {

        /// Uses the file system's last modified value.
        private let addLastModifiedHeader: Bool

        /// Value of max-age in Cache-Control header.
        private let maxAgeCacheControlHeader: Int

        /// Generate ETag.
        private var generateETag: Bool

        init(addLastModifiedHeader: Bool, maxAgeCacheControlHeader: Int, generateETag: Bool) {
            self.addLastModifiedHeader = addLastModifiedHeader
            self.maxAgeCacheControlHeader = maxAgeCacheControlHeader
            self.generateETag = generateETag
        }

        func setCustomResponseHeaders(response: RouterResponse, filePath _: String,
                                      fileAttributes: [FileAttributeKey : Any]) {
            addLastModified(response: response, fileAttributes: fileAttributes)
            addETag(response: response, fileAttributes: fileAttributes)
            setMaxAge(response: response)
        }

        private func addLastModified(response: RouterResponse,
                                     fileAttributes: [FileAttributeKey : Any]) {
            if addLastModifiedHeader {
                let date = fileAttributes[FileAttributeKey.modificationDate] as? Date
                if let date = date {
                    response.headers["Last-Modified"] = SPIUtils.httpDate(date)
                }
            }
        }

        private func addETag(response: RouterResponse,
                             fileAttributes: [FileAttributeKey : Any]) {
            if generateETag,
                let etag = CacheRelatedHeadersSetter.calculateETag(from: fileAttributes) {
                response.headers["Etag"] = etag
            }
        }

        private func setMaxAge(response: RouterResponse) {
            response.headers["Cache-Control"] = "max-age=\(maxAgeCacheControlHeader)"
        }

        static func calculateETag(from fileAttributes: [FileAttributeKey : Any]) -> String? {
            guard let date = fileAttributes[FileAttributeKey.modificationDate] as? Date,
                let size = fileAttributes[FileAttributeKey.size] as? NSNumber else {
                return nil
            }
            #if !os(Linux) || swift(>=4.0.2)
                // https://bugs.swift.org/browse/SR-5850
                let sizeHex = String(Int(truncating: size), radix: 16, uppercase: false)
            #else
                let sizeHex = String(Int(size), radix: 16, uppercase: false)
            #endif

            let timeHex = String(Int(date.timeIntervalSince1970), radix: 16, uppercase: false)
            let etag = "W/\"\(sizeHex)-\(timeHex)\""
            return etag
        }
    }
}
