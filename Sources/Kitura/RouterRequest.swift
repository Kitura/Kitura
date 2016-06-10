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
import LoggerAPI

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
    public private(set) lazy var hostname: String = { [unowned self] () in
        guard let host = self.headers["host"] else {
            return self.parsedURL.host ?? ""
        }
        let range = host.range(of: ":")
        return  range == nil ? host : host.substring(to: range!.lowerBound)
    }()

    ///
    /// The domain name of request
    ///
    public private(set) lazy var domain: String = { [unowned self] in
        let pattern = "([a-z0-9][a-z0-9\\-]{1,63}\\.[a-z\\.]{2,6})$"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])

            let hostnameRange = NSMakeRange(0, self.hostname.utf8.count)

            guard let match = regex.matches(in: self.hostname, options: [], range: hostnameRange).first else {
                return self.hostname
            }

            let range = match.range

            return self.hostname.bridge().substring(with: range)
        } catch {
            Log.error("Failed to create regular expressions for domain property")
            return self.hostname
        }
    }()

    ///
    /// The subdomains string array of request
    ///
    public private(set) lazy var subdomains: [String] = { [unowned self] in
        let subdomainsString = self.hostname
            .replacingOccurrences(of: self.domain,
                                  with: "",
                                  options: [ .backwardsSearch ],
                                  range: self.hostname.startIndex..<self.hostname.endIndex)

        var subdomains = subdomainsString.components(separatedBy: ".")

        return subdomains.filter { !$0.isEmpty }
    }()

    ///
    /// The method of the request
    ///
    public let method: RouterMethod

    ///
    /// The parsed URL
    ///
    public let parsedURL: URLParser

    ///
    /// The router as a String
    ///
    public internal(set) var route: String?

    ///
    /// The currently matched section of the url
    ///
    public internal(set) var matchedPath = ""

    ///
    /// The original URL as a string
    ///
    public var originalURL: String {
        return serverRequest.urlString
    }

    ///
    /// The URL
    ///
    public let url: String

    ///
    /// List of HTTP headers with simple String values
    ///
    public let headers: Headers

    ///
    /// IP address string of server
    ///
    public var remoteAddress: String { return serverRequest.remoteAddress }

    //
    // Parsed Cookies, used to do a lazy parsing of the appropriate headers
    //
    private lazy var _cookies: Cookies = { [unowned self] in
        return Cookies(headers: self.serverRequest.headers)
    }()

    ///
    /// Set of parsed cookies
    ///
    public var cookies: [String: NSHTTPCookie] {
        return _cookies.cookies
    }

    ///
    /// List of URL parameters
    ///
    public internal(set) var parameters: [String:String] = [:]

    ///
    /// List of query parameters
    ///
    public var queryParameters: [String:String] { return parsedURL.queryParameters }

    ///
    /// User info
    ///
    public var userInfo: [String: Any] = [:]

    ///
    /// Body of the message
    ///
    public internal(set) var body: ParsedBody?

    ///
    /// Initializes a RouterRequest instance
    ///
    /// - Parameter request: the server request
    ///
    /// - Returns: a RouterRequest instance
    ///
    init(request: ServerRequest) {
        serverRequest = request
        method = RouterMethod(fromRawValue: serverRequest.method)
        parsedURL = URLParser(url: serverRequest.url, isConnect: false)
        url = String(serverRequest.urlString)
        headers = Headers(headers: serverRequest.headers)
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
    /// Checks if passed in content types are acceptable based on the request's Accept header field
    ///
    /// - Parameter types: array of content/mime type strings
    ///
    /// - Returns most acceptable type or nil if there are none
    ///
    public func accepts(_ types: [String]) -> String? {
        guard let acceptHeaderValue = headers["accept"] else {
            return nil
        }

        let headerValues = acceptHeaderValue.characters.split(separator: ",").map(String.init)
        return MimeTypeAcceptor.accepts(headerValues: headerValues, types: types)
    }

    public func accepts(_ types: String...) -> String? {
        return accepts(types)
    }

    public func accepts(_ type: String) -> String? {
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

    private init(headers: HeadersContainer) {

        guard let rawCookies = headers[cookieHeader] else {
            return
        }
        for cookie in rawCookies {
            let cookieNameValues = cookie.components(separatedBy: "; ")
            for  cookieNameValue  in  cookieNameValues  {
                let cookieNameValueParts = cookieNameValue.components(separatedBy: "=")
                if   cookieNameValueParts.count == 2  {
#if os(Linux)
                    let cookieName = cookieNameValueParts[0]
                    let cookieValue = cookieNameValueParts[1]
#else
                    let cookieName = cookieNameValueParts[0] as NSString
                    let cookieValue = cookieNameValueParts[1] as NSString
#endif
                    let theCookie = NSHTTPCookie(properties:
                        [NSHTTPCookieDomain: ".",
                         NSHTTPCookiePath: "/",
                         NSHTTPCookieName: cookieName ,
                         NSHTTPCookieValue: cookieValue])
                    cookies[cookieNameValueParts[0]] = theCookie
                }
            }
        }
    }
}
