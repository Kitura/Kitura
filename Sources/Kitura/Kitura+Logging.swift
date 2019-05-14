/*
 * Copyright IBM Corporation 2015-2019
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
import Logging

extension Kitura {

    /**
     Instructs Kitura and LoggerAPI to log messages to a Swift Logger that you provide.
     Usage example:
     ```
     import Kitura
     import Logging

     var logger = Logger(label: "MyLogger")
     logger.logLevel = .debug
     Kitura.logTo(logger)
     ```
    */
    public static func logTo(_ logger: Logging.Logger) {
        Log.swiftLogger = logger
        Log.verbose("Kitura will log to Logger '\(logger.label)'")
    }

}
