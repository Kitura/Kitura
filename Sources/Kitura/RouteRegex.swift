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

import KituraSys
import LoggerAPI

import Foundation

public class RouteRegex {
    public static let sharedInstance = RouteRegex()
    
    private var keyRegex: NSRegularExpression?
    private var nonKeyRegex: NSRegularExpression?
    
    private init () {
        do {
            keyRegex = try NSRegularExpression(pattern: "(.*)?(?:\\:(\\w+)(?:\\(((?:\\\\.|[^()])+)\\))?(?:([+*?])?))", options: [])
            nonKeyRegex = try NSRegularExpression(pattern: "(.*)?(?:(?:\\(((?:\\\\.|[^()])+)\\))(?:([+*?])?))", options: [])
        } catch {
            Log.error("Failed to create regular expressions used to parse Route patterns")
        }
    }
    
    ///
    /// Builds a regular expression from a String pattern
    ///
    /// - Parameter pattern: Optional string
    ///
    /// - Returns:
    ///
    internal func buildRegex(fromPattern pattern: String?, allowPartialMatch: Bool = false) -> (NSRegularExpression?, [String]?) {
        
        guard let pattern = pattern else {
            return (nil, nil)
        }
        var regexStr = "^"
        var keys: [String] = []
        var nonKeyIndex = 0
        
        #if os(Linux)
            let paths = pattern.bridge().componentsSeparatedByString("/")
        #else
            let paths = pattern.bridge().components(separatedBy: "/")
        #endif
        
        // Special case where only back slashes are specified
        if paths.filter({$0 != ""}).isEmpty {
            regexStr.append("/")
        }
        
        for path in paths {
            // If there was a leading slash, there will be an empty component in the split
            if  path.isEmpty {
                continue
            }
            
            var matched = false
            var prefix = ""
            var matchExp = "[^/]+?"
            var plusQuestStar = ""
            
            if  path == "*" {
                // Handle a path element of * specially
                matchExp = ".*"
                matched = true
            } else {
                let range = NSMakeRange(0, path.characters.count)
                guard let keyRegex = keyRegex else {
                    Log.error("RouteRegex has invalid state: missing keyRegex")
                    return(nil,nil)
                }
                guard let nonKeyRegex = nonKeyRegex else {
                    Log.error("RouteRegex element has invalid state: missing nonKeyRegex")
                    return(nil,nil)
                }
                #if os(Linux)
                    if let keyMatch = keyRegex.firstMatch(in: path, options: [], range: range) {
                        // We found a path element with a named/key capture
                        let prefixRange = keyMatch.rangeAtIndex(1)
                        if  prefixRange.location != NSNotFound  &&  prefixRange.location != -1 {
                            prefix = path.bridge().substringWithRange(prefixRange)
                        }
                        let matchExpRange = keyMatch.rangeAtIndex(3)
                        if  matchExpRange.location != NSNotFound  &&  matchExpRange.location != -1 {
                            matchExp = path.bridge().substringWithRange(matchExpRange)
                        }
                        let pqsRange = keyMatch.rangeAtIndex(4)
                        if  pqsRange.location != NSNotFound  &&  pqsRange.location != -1 {
                            plusQuestStar = path.bridge().substringWithRange(pqsRange)
                        }
                        keys.append(path.bridge().substringWithRange(keyMatch.rangeAtIndex(2)))
                        matched = true
                    } else if  let nonKeyMatch = nonKeyRegex.firstMatch(in: path, options: [], range: range) {
                        // We found a path element with an unnamed capture
                        let prefixRange = nonKeyMatch.rangeAtIndex(1)
                        if  prefixRange.location != NSNotFound  &&  prefixRange.location != -1 {
                            prefix = path.bridge().substringWithRange(prefixRange)
                        }
                        let matchExpRange = nonKeyMatch.rangeAtIndex(2)
                        if  matchExpRange.location != NSNotFound  &&  matchExpRange.location != -1 {
                            matchExp = path.bridge().substringWithRange(matchExpRange)
                        }
                        let pqsRange = nonKeyMatch.rangeAtIndex(3)
                        if  pqsRange.location != NSNotFound  &&  pqsRange.location != -1 {
                            plusQuestStar = path.bridge().substringWithRange(pqsRange)
                        }
                        keys.append(String(nonKeyIndex))
                        nonKeyIndex+=1
                        matched = true
                    }
                #else
                    if let keyMatch = keyRegex.firstMatch(in: path, options: [], range: range) {
                        // We found a path element with a named/key capture
                        let prefixRange = keyMatch.range(at: 1)
                        if  prefixRange.location != NSNotFound  &&  prefixRange.location != -1 {
                            prefix = path.bridge().substring(with: prefixRange)
                        }
                        let matchExpRange = keyMatch.range(at: 3)
                        if  matchExpRange.location != NSNotFound  &&  matchExpRange.location != -1 {
                            matchExp = path.bridge().substring(with: matchExpRange)
                        }
                        let pqsRange = keyMatch.range(at: 4)
                        if  pqsRange.location != NSNotFound  &&  pqsRange.location != -1 {
                            plusQuestStar = path.bridge().substring(with: pqsRange)
                        }
                        keys.append(path.bridge().substring(with: keyMatch.range(at: 2)))
                        matched = true
                    } else if  let nonKeyMatch = nonKeyRegex.firstMatch(in: path, options: [], range: range) {
                        // We found a path element with an unnamed capture
                        let prefixRange = nonKeyMatch.range(at: 1)
                        if  prefixRange.location != NSNotFound  &&  prefixRange.location != -1 {
                            prefix = path.bridge().substring(with: prefixRange)
                        }
                        let matchExpRange = nonKeyMatch.range(at: 2)
                        if  matchExpRange.location != NSNotFound  &&  matchExpRange.location != -1 {
                            matchExp = path.bridge().substring(with: matchExpRange)
                        }
                        let pqsRange = nonKeyMatch.range(at: 3)
                        if  pqsRange.location != NSNotFound  &&  pqsRange.location != -1 {
                            plusQuestStar = path.bridge().substring(with: pqsRange)
                        }
                        keys.append(String(nonKeyIndex))
                        nonKeyIndex+=1
                        matched = true
                    }
                #endif
            }
            
            if  matched  {
                // We have some kind of capture for this path element
                // Build the runtime regex depending on whether or not there is "repetition"
                switch(plusQuestStar) {
                case "+":
                    regexStr.append("/")
                    regexStr.append(prefix)
                    regexStr.append("(")
                    regexStr.append(matchExp)
                    regexStr.append("(?:/")
                    regexStr.append(matchExp)
                    regexStr.append(")*)")
                case "?":
                    if  prefix.isEmpty {
                        regexStr.append("(?:/(")
                        regexStr.append(matchExp)
                        regexStr.append("))?")
                    } else {
                        regexStr.append("/")
                        regexStr.append(prefix)
                        regexStr.append("(?:(")
                        regexStr.append(matchExp)
                        regexStr.append("))?")
                    }
                case "*":
                    if  prefix.isEmpty {
                        regexStr.append("(?:/(")
                        regexStr.append(matchExp)
                        regexStr.append("(?:/")
                        regexStr.append(matchExp)
                        regexStr.append(")*))?")
                    } else {
                        regexStr.append("/")
                        regexStr.append(prefix)
                        regexStr.append("(?:(")
                        regexStr.append(matchExp)
                        regexStr.append("(?:/")
                        regexStr.append(matchExp)
                        regexStr.append(")*))?")
                    }
                default:
                    regexStr.append("/")
                    regexStr.append(prefix)
                    regexStr.append("(?:(")
                    regexStr.append(matchExp)
                    regexStr.append("))")
                }
            } else {
                // A path element with no capture
                regexStr.append("/")
                regexStr.append(path)
            }
        }
        regexStr.append("(?:/(?=$))?")
        if !allowPartialMatch {
            regexStr.append("$")
        }
        
        var regex: NSRegularExpression? = nil
        do {
            regex = try NSRegularExpression(pattern: regexStr, options: [])
        } catch {
            Log.error("Failed to compile the regular expression for the route \(pattern)")
        }
        
        return (regex, keys)
    }
}
