/*
 * Copyright IBM Corporation 2017
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

extension String {
    
    var asUrlEncoded: [String : String] {
        var decodedParameters: [String:String] = [:]
        
        for item in self.components(separatedBy: "&") {
            guard let range = item.range(of: "=") else {
                continue
            }
            
            let key = item.substring(to: range.lowerBound)
            let value = item.substring(from: range.upperBound)
            let valueReplacingPlus = value.replacingOccurrences(of: "+", with: " ")
            if let decodedValue = valueReplacingPlus.removingPercentEncoding {
                decodedParameters[key] = decodedValue
            } else {
                Log.warning("Unable to decode query parameter \(key)")
                decodedParameters[key] = valueReplacingPlus
            }
        }
        
        return decodedParameters
    }
}
