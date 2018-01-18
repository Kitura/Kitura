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

// MARK RouteRegex

/// A set of helper functions for router path matching using regular expression.
public class RouteRegex {
    /// A shared instance of RouteRegex.
    public static let sharedInstance = RouteRegex()

    private let namedCaptureRegex: NSRegularExpression
    private let unnamedCaptureRegex: NSRegularExpression
    private let keyRegex: NSRegularExpression
    private let nonKeyRegex: NSRegularExpression
    private let complexRouteCharacters = CharacterSet(charactersIn: "*.:+?()[]\\")

    private init() {
        do {
            namedCaptureRegex = try NSRegularExpression(pattern: "(.*)?(?:\\:(\\w+)(?:\\(((?:\\\\.|[^()])+)\\))?(?:([+*?])?))", options: [])
            unnamedCaptureRegex = try NSRegularExpression(pattern: "(.*)?(?:(?:\\(((?:\\\\.|[^()])+)\\))(?:([+*?])?))", options: [])
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
    /// - Returns: A tuple of the compiled `NSRegularExpression?`, a bool as to whether or not
    ///            this is a simple String compare, and array of keys
    internal func buildRegex(fromPattern: String?, allowPartialMatch: Bool = false) -> (NSRegularExpression?, Bool, [String]?) {
        guard let pattern = fromPattern else {
            return (nil, false, nil)
        }

        // Check and see if the pattern is a simple string (no captures and not a regular expression)
        if pattern.rangeOfCharacter(from: complexRouteCharacters) == nil {
            return (nil, true, nil)
        }

        var regexStr = "^"
        var keys = [String]()
        var nonKeyIndex = 0

        let paths = pattern.components(separatedBy: "/")

        for path in paths {
            (regexStr, keys, nonKeyIndex) =
                handlePath(path, regexStr: regexStr, keys: keys, nonKeyIndex: nonKeyIndex)
        }

        if allowPartialMatch {
            // Allows the route to match exactly, or match any additional text after its trailing '/'
            // i.e. the route defined on the path "/hello" will match "/hello/foo/bar"
            regexStr.append("(?:/(?=$))?(?=/|$)")
        } else {
            // Allows the route to match exactly, or with a trailing '/'
            // i.e. the route defined on the path "/hello" will match only "/hello" or "/hello/"
            regexStr.append("(?:/(?=$))?$")
        }

        var regex: NSRegularExpression? = nil
        do {
            regex = try NSRegularExpression(pattern: regexStr, options: [])
        } catch {
            Log.error("Failed to compile the regular expression for the route \(pattern)")
        }

        return (regex, false, keys)
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

            let range = NSRange(location: 0, length: path.count)
            let nsPath = NSString(string: path)           // Needed for substring

            if let keyMatch = keyRegex.firstMatch(in: path, options: [], range: range) {
                // We found a path element with a named/key capture
                extract(fromPath: nsPath, with: keyMatch, at: 1, to: &prefix)
                extract(fromPath: nsPath, with: keyMatch, at: 3, to: &matchExp)
                extract(fromPath: nsPath, with: keyMatch, at: 4, to: &plusQuestStar)

                let keyMatchRange = keyMatch.range(at: 2)
                keys.append(nsPath.substring(with: keyMatchRange))
                matched = true
            } else if let nonKeyMatch = nonKeyRegex.firstMatch(in: path, options: [], range: range) {
                // We found a path element with an unnamed capture
                extract(fromPath: nsPath, with: nonKeyMatch, at: 1, to: &prefix)
                extract(fromPath: nsPath, with: nonKeyMatch, at: 2, to: &matchExp)
                extract(fromPath: nsPath, with: nonKeyMatch, at: 3, to: &plusQuestStar)

                keys.append(String(nonKeyIndex))
                nonKeyIndex+=1
                matched = true
            }

            return (matched, prefix, matchExp, plusQuestStar)
    }

    func extract(fromPath path: NSString, with match: NSTextCheckingResult, at index: Int,
                 to string: inout String) {
        let range = match.range(at: index)

        if  range.location != NSNotFound  &&  range.location != -1 {
            string = path.substring(with: range)
        }
    }

    func getStringToAppendToRegex(plusQuestStar: String, prefix: String,
                                  matchExp: String) -> String {
        // We have some kind of capture for this path element
        // Build the runtime regex depending on whether or not there is "repetition"
        switch plusQuestStar {
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
