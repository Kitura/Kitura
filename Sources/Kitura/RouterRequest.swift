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
import Socket
import LoggerAPI

import Foundation

// MARK: RouterRequest

/// Router request.
public class RouterRequest {

    /// The server request.
    let serverRequest: ServerRequest

    /// The hostname of the request.
    public var hostname: String {
        return urlComponents.host ?? ""
    }

    ///The port of the request.
    public var port: Int {
        return urlComponents.port ?? (urlComponents.scheme == "https" ? 443 : 80)
    }

    /// The domain name of the request.
    public private(set) lazy var domain: String = { [unowned self] in
        let pattern = "([a-z0-9][a-z0-9\\-]{1,63}\\.[a-z\\.]{2,6})$"
        do {
            let regex = try RegularExpressionType(pattern: pattern, options: [.caseInsensitive])

            let hostnameRange = NSMakeRange(0, self.hostname.utf8.count)

            guard let match = regex.matches(in: self.hostname, options: [], range: hostnameRange).first else {
                return self.hostname
            }

            let range = match.range

            return NSString(string: self.hostname).substring(with: range)
        } catch {
            Log.error("Failed to create regular expressions for domain property")
            return self.hostname
        }
    }()

    /// The subdomains string array of request.
    public private(set) lazy var subdomains: [String] = { [unowned self] in
        let backwards = String.CompareOptions.backwards
        let subdomainsString = self.hostname
            .replacingOccurrences(of: self.domain,
                                  with: "",
                                  options: [ backwards ],
                                  range: self.hostname.startIndex..<self.hostname.endIndex)

        var subdomains = subdomainsString.components(separatedBy: ".")

        return subdomains.filter { !$0.isEmpty }
    }()

    /// The HTTP version of the request.
    public let httpVersion: HTTPVersion

    /// The method of the request.
    public let method: RouterMethod

    /// The parsed URL.
    @available(*, deprecated, message: "use 'urlComponents' instead")
    public var parsedURL: URLParser {
        var path = urlComponents.percentEncodedPath
        if let query = urlComponents.percentEncodedQuery {
            path += "?" + query
        }
        let pathData = path.data(using: .utf8) ?? Data()
        return URLParser(url: pathData, isConnect: false)
    }

    /// The router as a String.
    public internal(set) var route: String?

    /// The currently matched section of the URL.
    public internal(set) var matchedPath = ""

    /// A Bool that indicates whether or not a partial match of the path by the pattern is
    /// sufficient. If true, subrouter will snip matchedPath from path before processing
    /// middleware
    var allowPartialMatch = true

    /// The original URL as a string.
    public var originalURL : String { return serverRequest.urlComponents.string ?? "" }

    /// The URL.
    /// This contains just the path and query parameters starting with '/'
    /// Use "urlComponents" for the full URL
    @available(*, deprecated, message:
        "This contains just the path and query parameters starting with '/'. use 'urlComponents' instead")
    public var url : String { return serverRequest.urlString }

    /// The URL from the request as URLComponents
    public internal(set) var urlComponents = URLComponents()

    /// List of HTTP headers with simple String values.
    public let headers: Headers

    /// IP address string of server.
    public var remoteAddress: String { return serverRequest.remoteAddress }

    /// Parsed Cookies, used to do a lazy parsing of the appropriate headers.
    public lazy var cookies: [String: HTTPCookie] = { [unowned self] in
        return Cookies.parse(headers: self.serverRequest.headers)
    }()

    /// List of URL parameters.
    public internal(set) var parameters: [String:String] = [:]

    /// List of query parameters.
    public lazy var queryParameters: [String:String] = { [unowned self] in
        var decodedParameters: [String:String] = [:]
        if let query = self.urlComponents.percentEncodedQuery {
            for item in query.components(separatedBy: "&") {
                if let range = item.range(of: "=") {
                    let key = item.substring(to: range.lowerBound)
                    let value = item.substring(from: range.upperBound)
                    let valueReplacingPlus = value.replacingOccurrences(of: "+", with: " ")
                    if let decodedValue = valueReplacingPlus.removingPercentEncoding {
                        decodedParameters[key] = decodedValue
                    } else {
                        Log.warning("Unable to decode query parameter \(key)")
                        decodedParameters[key] = valueReplacingPlus
                    }
                } else {
                    decodedParameters[item] = nil
                }
            }
        }
        return decodedParameters
    }()

    /// User info.
    public var userInfo: [String: Any] = [:]

    /// Body of the message.
    public internal(set) var body: ParsedBody?

    internal var handledNamedParameters = Set<String>()

    /// Initializes a `RouterRequest` instance
    ///
    /// - Parameter request: the server request
    init(request: ServerRequest) {
        serverRequest = request
        urlComponents = serverRequest.urlComponents
        httpVersion = HTTPVersion(major: serverRequest.httpVersionMajor ?? 1, minor: serverRequest.httpVersionMinor ?? 1)
        method = RouterMethod(fromRawValue: serverRequest.method)
        headers = Headers(headers: serverRequest.headers)
    }

    /// Read the body of the request as Data.
    ///
    /// - Parameter into: Data object in which the body of the request is returned.
    /// - Throws: Socket.Error if an error occurred while reading from a socket.
    /// - Returns: the number of bytes read.
    public func read(into data: inout Data) throws -> Int {
        return try serverRequest.read(into: &data)
    }

    /// Read the body of the request as String.
    ///
    /// - Throws: Socket.Error if an error occurred while reading from a socket.
    /// - Returns: the String with the request body.
    public func readString() throws -> String? {
        return try serverRequest.readString()
    }

    /// Check if passed in types are acceptable based on the request's header field
    /// specified in the first parameter.
    ///
    /// - Parameter header: name of request's header field to be checked.
    /// - Parameter types: array of content/mime type strings.
    /// - Returns: most acceptable type or nil if there are none.
    public func accepts(header: String = "Accept", types: [String]) -> String? {
        guard let acceptHeaderValue = headers[header] else {
            return nil
        }

        let headerValues = acceptHeaderValue.characters.split(separator: ",").map(String.init)
        return MimeTypeAcceptor.accepts(headerValues: headerValues, types: types)
    }

    /// Check if passed in types are acceptable based on the request's header field
    /// specified in the first parameter.
    ///
    /// - Parameter header: name of request's header field to be checked.
    /// - Parameter types: content/mime type strings.
    /// - Returns: most acceptable type or nil if there are none.
    public func accepts(header: String = "Accept", types: String...) -> String? {
        return accepts(header:header, types: types)
    }

    /// Check if passed in types are acceptable based on the request's header field
    /// specified in the first parameter.
    ///
    /// - Parameter header: name of request's header field to be checked.
    /// - Parameter type: content/mime type string.
    /// - Returns: most acceptable type or nil if there are none.
    public func accepts(header: String = "Accept", type: String) -> String? {
        return accepts(header:header, types: [type])
    }

}

private class Cookies {
    private static var separator: RegularExpressionType = {
        do {
            // matches that do not contain semicolons and do not start with whitespaces
            // effectively splits string by ";\\s*"
            return try RegularExpressionType(pattern: "[^;\\s][^;]*", options: [])
        } catch { // should never throw here, famous last words
            Log.error("Error creating cookie separator regex: \(error)")
            exit(1)
        }
    }()

    fileprivate static func parse(headers: HeadersContainer) -> [String: HTTPCookie] {
        var cookies = [String: HTTPCookie]()
        if let cookieHeaders = headers["cookie"] {
            for cookieHeader in cookieHeaders {
                let nsCookieHeader = NSString(string: cookieHeader)
                let results = Cookies.separator.matches(in: cookieHeader, options: [], range: NSMakeRange(0, nsCookieHeader.length))

                for result in results {
                    let match = nsCookieHeader.substring(with: NSMakeRange(result.range.location, result.range.length))
                    if let cookie = getCookie(cookieString: match) {
                        cookies[cookie.name] = cookie
                    }
                }
            }
        }
        return cookies
    }

    private static func getCookie(cookieString: String) -> HTTPCookie? {
        guard let range = cookieString.range(of: "=") else {
            return nil
        }

        let name = cookieString.substring(to: range.lowerBound)
        let value = cookieString.substring(from: range.upperBound)
        return HTTPCookie(properties:
            [HTTPCookiePropertyKey.domain: ".",
             HTTPCookiePropertyKey.path: "/",
             HTTPCookiePropertyKey.name: name ,
             HTTPCookiePropertyKey.value: value])
    }
}
