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

import KituraSys
import LoggerAPI

import Foundation

#if os(Linux)
    typealias RegularExpressionType = RegularExpression
#else
    typealias RegularExpressionType = NSRegularExpression
#endif

///
public class RouteRegex {
    public static let sharedInstance = RouteRegex()

    private let namedCaptureRegex: RegularExpressionType
    private let unnamedCaptureRegex: RegularExpressionType
    private let keyRegex: RegularExpressionType
    private let nonKeyRegex: RegularExpressionType

    private init() {
        do {
            namedCaptureRegex = try RegularExpressionType(pattern: "(.*)?(?:\\:(\\w+)(?:\\(((?:\\\\.|[^()])+)\\))?(?:([+*?])?))", options: [])
            unnamedCaptureRegex = try RegularExpressionType(pattern: "(.*)?(?:(?:\\(((?:\\\\.|[^()])+)\\))(?:([+*?])?))", options: [])
            keyRegex = namedCaptureRegex
            nonKeyRegex = unnamedCaptureRegex
        } catch {
            Log.error("Failed to create regular expressions used to parse Route patterns")
            exit(1)
        }
    }

    /// Builds a regular expression from a String pattern
    ///
    /// - Parameter pattern: Optional string
    /// - Parameter allowPartialMatch: True if a partial match is allowed. Defaults to false.
    /// - Returns: A tuple of the compiled `RegularExpressionType?` and array of keys
    internal func buildRegex(fromPattern: String?, allowPartialMatch: Bool = false) -> (RegularExpressionType?, [String]?) {
        guard let fromPattern = fromPattern else {
            return (nil, nil)
        }

        var pattern = fromPattern
        var regexStr = "^"
        var keys = [String]()
        var nonKeyIndex = 0

        if allowPartialMatch && pattern.hasSuffix("*") {
            pattern = String(pattern.characters.dropLast())
        }

        let paths = pattern.bridge().components(separatedBy: "/")

        // Special case where only back slashes are specified
        if paths.filter({$0 != ""}).isEmpty {
            regexStr.append("/")
        }

        for path in paths {
            (regexStr, keys, nonKeyIndex) =
                handlePath(path, regexStr: regexStr, keys: keys, nonKeyIndex: nonKeyIndex)
        }

        regexStr.append("(?:/(?=$))?")
        if !allowPartialMatch {
            regexStr.append("$")
        }

        var regex: RegularExpressionType? = nil
        do {
            regex = try RegularExpressionType(pattern: regexStr, options: [])
        } catch {
            Log.error("Failed to compile the regular expression for the route \(pattern)")
        }

        return (regex, keys)
    }

    func handlePath(_ path: String, regexStr: String, keys: [String], nonKeyIndex: Int) ->
        (regexStr: String, keys: [String], nonKeyIndex: Int) {
        var nonKeyIndex = nonKeyIndex
        var keys = keys
        var regexStr = regexStr

        // If there was a leading slash, there will be an empty component in the split
        if  path.isEmpty {
            return (regexStr, keys, nonKeyIndex)
        }

        let (matched, prefix, matchExp, plusQuestStar) =
            matchRangesInPath(path, nonKeyIndex: &nonKeyIndex, keys: &keys)

        let toAppend: String
        if  matched { // A path element with no capture
            toAppend = getStringToAppendToRegex(plusQuestStar: plusQuestStar,
                                                prefix: prefix, matchExp: matchExp)
        } else {
            toAppend = "/\(path)"  // A path element with no capture
        }
        regexStr.append(toAppend)

        return (regexStr, keys, nonKeyIndex)
    }

    func matchRangesInPath(_ path: String, nonKeyIndex: inout Int, keys: inout [String]) ->
        (match: Bool, prefix: String, matchExp: String, plusQuestStar: String) {
        var matched = false
        var prefix = ""
        var matchExp = "[^/]+?"
        var plusQuestStar = ""

        if  path == "*" {
            // Handle a path element of * specially
            return (true, prefix, ".*", plusQuestStar)
        }

        let range = NSMakeRange(0, path.characters.count)

        if let keyMatch = keyRegex.firstMatch(in: path, options: [], range: range) {
            // We found a path element with a named/key capture
            extract(fromPath: path, with: keyMatch, at: 1, to: &prefix)
            extract(fromPath: path, with: keyMatch, at: 3, to: &matchExp)
            extract(fromPath: path, with: keyMatch, at: 4, to: &plusQuestStar)

            #if os(Linux)
                let keyMatchRange = keyMatch.range(at: 2)
            #else
                let keyMatchRange = keyMatch.rangeAt(2)
            #endif
            keys.append(path.bridge().substring(with: keyMatchRange))
            matched = true
        } else if let nonKeyMatch = nonKeyRegex.firstMatch(in: path, options: [], range: range) {
            // We found a path element with an unnamed capture
            extract(fromPath: path, with: nonKeyMatch, at: 1, to: &prefix)
            extract(fromPath: path, with: nonKeyMatch, at: 2, to: &matchExp)
            extract(fromPath: path, with: nonKeyMatch, at: 3, to: &plusQuestStar)

            keys.append(String(nonKeyIndex))
            nonKeyIndex+=1
            matched = true
        }

        return (matched, prefix, matchExp, plusQuestStar)
    }

    #if os(Linux)
    typealias TextCheckingResultType = TextCheckingResult
    #else
    typealias TextCheckingResultType = NSTextCheckingResult
    #endif

    func extract(fromPath path: String, with match: TextCheckingResultType, at index: Int,
                 to string: inout String) {
        #if os(Linux)
            let range = match.range(at: index)
        #else
            let range = match.rangeAt(index)
        #endif
        if  range.location != NSNotFound  &&  range.location != -1 {
            string = path.bridge().substring(with: range)
        }
    }

    func getStringToAppendToRegex(plusQuestStar: String, prefix: String,
                                  matchExp: String) -> String {
        // We have some kind of capture for this path element
        // Build the runtime regex depending on whether or not there is "repetition"
        switch(plusQuestStar) {
        case "+":
            return "/\(prefix)(\(matchExp)(?:/\(matchExp))*)"
        case "?":
            if  prefix.isEmpty {
                return "(?:/(\(matchExp)))?"
            }
            return "/\(prefix)(?:(\(matchExp)))?"
        case "*":
            if  prefix.isEmpty {
                return "(?:/(\(matchExp)(?:/\(matchExp))*))?"
            }
            return "/\(prefix)(?:(\(matchExp)(?:/\(matchExp))*))?"
        default:
            return "/\(prefix)(?:(\(matchExp)))"
        }
    }
}
