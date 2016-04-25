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

import KituraNet
import Socket

import Foundation

// MARK: RouterRequest

public class RouterRequest: SocketReader {

    ///
    /// The server request
    ///
    let serverRequest: ServerRequest

    ///
    /// The hostname of the request
    ///
    public var hostname: String {
        if  let host = headers.get("host")?.first {
#if os(Linux)
            let range = host.rangeOfString(":")
            return  range == nil ? host : host.substringToIndex(range!.startIndex)
#else
            let range = host.range(of: ":")
            return  range == nil ? host : host.substring(to: range!.startIndex)
#endif
        } else {
            return parsedUrl.host ?? ""
        }
    }

    ///
    /// The method of the request
    ///
    public let method: RouterMethod

    ///
    /// The parsed url
    ///
    let parsedUrl: UrlParser

    ///
    /// The router as a String
    ///
    public internal(set) var route: String?

    ///
    /// The currently matched section of the url
    ///
    public var matchedPath = ""

    ///
    /// The original url as a string
    ///
    public var originalUrl: String {
        return serverRequest.urlString
    }

    ///
    /// The URL
    ///
    public var url: String

    ///
    /// List of HTTP headers with simple String values
    ///
    public var headers: Headers { return serverRequest.headers }

    ///
    /// IP address string of server
    ///
    public var remoteAddress: String { return serverRequest.remoteAddress }

    //
    // Parsed Cookies, used to do a lazy parsing of the appropriate headers
    //
    private var _cookies: Cookies?

    ///
    /// Set of parsed cookies
    ///
    public var cookies: [String: NSHTTPCookie] {
        if  _cookies == nil {
            _cookies = Cookies(headers: headers)
        }
        return _cookies!.cookies
    }

    ///
    /// List of URL parameters
    ///
    public var params: [String:String] = [:]

    ///
    /// List of query parameters
    ///
    public var queryParams: [String:String] { return parsedUrl.queryParams }

    ///
    /// User info
    ///
    public var userInfo: [String: AnyObject] = [:]

    ///
    /// Body of the message
    ///
    public internal(set) var body: ParsedBody? = nil

    ///
    /// Initializes a RouterRequest instance
    ///
    /// - Parameter request: the server request
    ///
    /// - Returns: a RouterRequest instance
    ///
    init(request: ServerRequest) {
        serverRequest = request
        method = RouterMethod(string: serverRequest.method)
        parsedUrl = UrlParser(url: serverRequest.url, isConnect: false)
        url = String(serverRequest.urlString)
    }

    ///
    /// Read data
    ///
    /// - Parameter data: the data
    ///
    /// - Throws: ???
    /// - Returns: the number of bytes read
    ///
    public func read(into data: NSMutableData) throws -> Int {
        return try serverRequest.read(into: data)
    }

    ///
    /// Read string
    ///
    /// - Throws: ???
    /// - Returns: the String
    ///
    public func readString() throws -> String? {
        return try serverRequest.readString()
    }

    ///
    /// Finds the full mime type for a given extension
    ///
    /// - Parameter type: mime type extension String
    ///
    /// - Returns the full mime type
    ///
    private func extToMime(type: String) -> String {

        if let mimeType = ContentType.sharedInstance.contentTypeForExtension(type) {
            return mimeType
        }
        return type
    }

    ///
    /// Parse mime type string into a digestable tuple format
    ///
    /// - Parameter type: raw mime type String
    ///
    /// - Returns a tuple with the mime type and q parameter value if present, qValue defaults to 1
    ///
    private func parseMediaType(type: String) -> (type: String, qValue: Double) {
        var finishedPair = ("", 1.0)
#if os(Linux)
        let trimmed = type.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
#else
        let trimmed = type.trimmingCharacters(in: NSCharacterSet.whitespace())
#endif
        let components = trimmed.characters.split(separator: ";").map(String.init)

        if let mediaType = components.first {
            finishedPair.0 = mediaType
        }
        if let qPreference = components.last {
            let qualityComponents = qPreference.characters.split(separator: "=").map(String.init)
            if let q = qualityComponents.first, value = qualityComponents.last where q == "q" {
                finishedPair.1 = Double(value)!
            }
        }

        return finishedPair
    }

    ///
    /// Checks if passed in content types are acceptable based on the request's Accept header field
    ///
    /// - Parameter types: array of content/mime type strings
    ///
    /// - Returns most acceptable type or nil if there are none
    ///
    public func accepts(types: [String]) -> String? {

        guard let acceptHeaderValue = headers.get("accept")?.first else {
            return nil
        }

        let headerValues = acceptHeaderValue.characters.split(separator: ",").map(String.init)
        var criteriaMatches = [String : (priority: Int, qValue: Double)]()

        for rawHeaderValue in headerValues {
            for type in types {


                let parsedHeaderValue = parseMediaType(rawHeaderValue)
                let mimeType = extToMime(type)

                if parsedHeaderValue.type == mimeType { // exact match, e.g. text/html == text/html

                    criteriaMatches[type] = (priority: 1, qValue: parsedHeaderValue.qValue)
                } else if parsedHeaderValue.type == "*/*" {

                    if criteriaMatches[type] == nil { // else do nothing
                        criteriaMatches[type] = (priority: 3, qValue: parsedHeaderValue.qValue)
                    }
                } else {
#if os(Linux)
                    let rangeMatch = mimeType.rangeOfString(parsedHeaderValue.type, options: .RegularExpressionSearch)
#else
                    let rangeMatch = mimeType.range(of: parsedHeaderValue.type, options: .regularExpressionSearch)
#endif
                    if rangeMatch != nil { // partial match, e.g. text/html == text/*
                        if criteriaMatches[type]?.priority > 2 || criteriaMatches[type] == nil {
                            criteriaMatches[type] = (priority: 2, qValue: parsedHeaderValue.qValue)
                        }
                    }
                }
            }
        }
        // sort by priority and by qValue to determine best type to return
        let sortedMatches = Array(criteriaMatches).sorted {
            if $0.1.priority != $1.1.priority {
                return $0.1.priority < $1.1.priority
            } else {
                return $0.1.qValue > $1.1.qValue
            }
        }

        if let bestMatch = sortedMatches.first {
            return bestMatch.0
        }
        return nil
    }

    public func accepts(types: String...) -> String? {
        return accepts(types)
    }

    public func accepts(type: String) -> String? {
        return accepts([type])
    }

}

private class Cookies {
    //
    // Storage of parsed Cookie headers
    //
    private var cookies = [String: NSHTTPCookie]()

    //
    // Static for Cookie header key value
    //
    private let cookieHeader = "cookie"

    private init(headers: Headers) {

        guard let rawCookies = headers.get(cookieHeader) else {
            return
        }
        for cookie in rawCookies {
            #if os(Linux)
                let cookieNameValues = cookie.bridge().componentsSeparatedByString("; ")
            #else
                let cookieNameValues = cookie.componentsSeparated(by: "; ")
            #endif
            for  cookieNameValue  in  cookieNameValues  {
                #if os(Linux)
                    let cookieNameValueParts = cookieNameValue.bridge().componentsSeparatedByString("=")
                #else
                    let cookieNameValueParts = cookieNameValue.componentsSeparated(by: "=")
                #endif
                if   cookieNameValueParts.count == 2  {
                    let theCookie = NSHTTPCookie(properties:
                        [NSHTTPCookieDomain: ".",
                         NSHTTPCookiePath: "/",
                         NSHTTPCookieName: cookieNameValueParts[0] ,
                         NSHTTPCookieValue: cookieNameValueParts[1]])
                    cookies[cookieNameValueParts[0]] = theCookie
                }
            }
        }
    }
}
