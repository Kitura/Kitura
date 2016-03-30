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

import Foundation

extension Router {
    internal enum ErrorCode: Int {
        case FailedToRedirectRequest = 1
        case NoDefaultTemplateEngineAndNoExtensionSpecified
        case NoTemplateEngineForExtension
        case InternalError
    }

    internal class Error {
        private static let Domain = "Kitura-router"
        internal static let FailedToRedirectRequest =
                            NSError(domain: Domain, code: ErrorCode.FailedToRedirectRequest.rawValue,
                                    userInfo: [NSLocalizedDescriptionKey: "Failed to redirect a request for directory"])
        internal static let NoDefaultTemplateEngineAndNoExtensionSpecified  =
                            NSError(domain: Domain, code: ErrorCode.NoDefaultTemplateEngineAndNoExtensionSpecified.rawValue,
                                    userInfo: [NSLocalizedDescriptionKey: "No default template engine set and no file extension specified "])
        internal static func getNoTemplateEngineForExtensionError(fileExtension: String) -> NSError {
            return NSError(domain: Domain, code: ErrorCode.NoTemplateEngineForExtension.rawValue,
                           userInfo: [NSLocalizedDescriptionKey: "No template engine defined for extension \(fileExtension)"])
        }
        internal static let InternalError = NSError(domain: Domain, code: ErrorCode.InternalError.rawValue,
                                                    userInfo: [NSLocalizedDescriptionKey: "Internal Error"])
    }
}
