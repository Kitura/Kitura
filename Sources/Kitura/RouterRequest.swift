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
import KituraNet
import Socket
import LoggerAPI
import KituraContracts

// MARK: RouterRequest

/**
 The `RouterRequest` class is used to interact with incoming HTTP requests to the Router.
 It contains and allows access to the request's `Headers` and `Body` as well as other properties of the request.
 It can also perform content negotiation based on the request’s "Accept" header.
 ### Usage Example: ###
 In this example "request" is an instance of the class `RouterRequest`.
 It is used by the server to read the body of the request as a String and send it back to the user.
 ```swift
 let router = Router()
 router.post("/") { request, response, next in
     let body = request.readString()
     response.send(body)
     next()
 }
 ```
 */
public class RouterRequest {

    /// The server request.
    let serverRequest: ServerRequest
    
    /// The Data decoder generator for the request content-type
    let decoder: BodyDecoder?

    // MARK: Properties
    
    /// The hostname of the request.
    public var hostname: String {
        return urlURL.host ?? ""
    }

    ///The port of the request.
    public var port: Int {
        return urlURL.port ?? (urlURL.scheme == "https" ? 443 : 80)
    }

    /// The domain name of the request.
    public private(set) lazy var domain: String = { [unowned self] in
        let pattern = "([a-z0-9][a-z0-9\\-]{1,63}\\.[a-z\\.]{2,6})$"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])

            let hostnameRange = NSRange(location: 0, length: self.hostname.utf8.count)

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

    /// The router as a String.
    public internal(set) var route: String?
    
    /// IP address string of server.
    public var remoteAddress: String { return serverRequest.remoteAddress }
    
    // MARK: URL
    
    private var _parsedURL: URLParser?
    internal let parsedURLPath: URLParser

    /// The parsed URL.
    public private(set) lazy var parsedURL: URLParser = { [unowned self] in
        if let result = self._parsedURL {
            return result
        } else {
            let result = URLParser(url: Data(self.serverRequest.urlURL.absoluteString.utf8), isConnect: false)
            self._parsedURL = result
            return result
        }
        }()

    /// The currently matched section of the URL.
    public internal(set) var matchedPath = ""

    /// A Bool that indicates whether or not a partial match of the path by the pattern is
    /// sufficient. If true, subrouter will snip matchedPath from path before processing
    /// middleware
    var allowPartialMatch = true

    /// The original URL as a string.
    public var originalURL: String { return serverRequest.urlURL.absoluteString }

    /// The URL.
    /// This contains just the path and query parameters starting with '/'
    /// Use 'urlURL' for the full URL
    @available(*, deprecated, message:
    "This contains just the path and query parameters starting with '/'. use 'urlURL' instead")
    public var url: String { return serverRequest.urlString }

    /// The URL from the request as URLComponents
    /// URLComponents has a memory leak on linux as of swift 3.0.1. Use 'urlURL' instead
    @available(*, deprecated, message:
    "URLComponents has a memory leak on linux as of swift 3.0.1. use 'urlURL' instead")
    public var urlComponents: URLComponents { return serverRequest.urlComponents }

    /// The URL from the request
    public var urlURL: URL { return serverRequest.urlURL }
    
    /// List of URL parameters.
    public internal(set) var parameters: [String:String] = [:]
    
    // MARK: Headers

    /// List of HTTP headers with simple String values.
    public let headers: Headers

    /// Parsed Cookies, used to do a lazy parsing of the appropriate headers.
    public lazy var cookies: [String: HTTPCookie] = { [unowned self] in
        return Cookies.parse(headers: self.serverRequest.headers)
        }()

    // MARK: Query parameters

    /// List of query parameters and comma-separated values.
    public lazy var queryParameters: [String:String] = { [unowned self] in
        return self.urlURL.query?.urlDecodedFieldValuePairs ?? [:]
        }()

    /// Query parameters with values as an array.
    public lazy var queryParametersMultiValues: [String: [String]] = { [unowned self] in
        return self.urlURL.query?.urlDecodedFieldMultiValuePairs ?? [:]
    }()

    /// Convert query parameters into a QueryParam type
    ///
    /// - Parameter type: The QueryParam type describing the expected query parameters
    /// - Returns: The route's Query parameters as a QueryParam object
    public func getQueryParameters<T: QueryParams>(as type: T.Type) -> T? {
        return try? QueryDecoder(dictionary: self.queryParameters).decode(type)
    }
    
    // MARK: Shared dictionary
    
    /// User info.
    /// Can be used by middlewares and handlers to store and pass information on to subsequent handlers.
    public var userInfo: [String: Any] = [:]

    // MARK: Request Body
    
    /// Body of the message.
    public internal(set) var body: ParsedBody?

    internal var handledNamedParameters = Set<String>()

    internal var hasBodyParserBeenUsed = false
    
    /// Initializes a `RouterRequest` instance
    ///
    /// - Parameter request: the server request
    /// - Parameter decoder: the decoder generator to use when decoding the request body.
    init(request: ServerRequest, decoder: BodyDecoder?) {
        serverRequest = request
        parsedURLPath = URLParser(url: request.url, isConnect: false)
        httpVersion = HTTPVersion(major: serverRequest.httpVersionMajor ?? 1, minor: serverRequest.httpVersionMinor ?? 1)
        method = RouterMethod(fromRawValue: serverRequest.method)
        headers = Headers(headers: serverRequest.headers)
        self.decoder = decoder
    }

    /// Read the body of the request as Data.
    ///
    /// - Parameter into: Data object in which the body of the request is returned.
    /// - Throws: Socket.Error if an error occurred while reading from a socket.
    /// - Returns: the number of bytes read.
    public func read(into data: inout Data) throws -> Int {
        return try serverRequest.read(into: &data)
    }
    
    /**
     Read the body of the request as a Codable object using a `BodyDecoder`
     that was selected based on the Content-Type header.
     Defaults to `JSONDecoder()` if no decoder is provided.
     ### Usage Example: ###
     The example below defines a `User` struct and then decodes a `User` from the body of a request.
     ```swift
     public struct User: Codable {
        let name: String
     }
     let router = Router()
     router.post("/example") { request, response, next in
         let user = try request.read(as: User.self)
         print(user.name)
         next()
     }
     ```
     - Parameter as: Codable object to which the body of the request will be converted.
     - Throws: Socket.Error if an error occurred while reading from a socket.
     - Throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
     - Throws: An error if any value throws an error during decoding.
     - Returns: The instantiated Codable object
     */
    public func read<T: Decodable>(as type: T.Type) throws -> T {
        var data = Data()
        _ = try serverRequest.read(into: &data)
        let decoder = self.decoder ?? JSONDecoder()
        return try decoder.decode(type, from: data)
    }
    
    /// Read the body of the request as String.
    ///
    /// - Throws: Socket.Error if an error occurred while reading from a socket.
    /// - Returns: the String with the request body.
    public func readString() throws -> String? {
        return try serverRequest.readString()
    }

    // MARK: Accepts
    
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

        let headerValues = acceptHeaderValue.split(separator: ",").map(String.init)
        // special header value that matches all types
        let matchAllPattern: String
        // This function can perform content negotiation for the various Accept* headers.
        // Check whether this is the 'Accept' header, which has a type/subtype structure,
        // or another (eg. 'Accept-Charset'), which is has single values.
        if header.equalsLowercased("accept") {
            matchAllPattern = "*/*"
        } else {
            matchAllPattern = "*"
        }
        return MimeTypeAcceptor.accepts(headerValues: headerValues, types: types, matchAllPattern: matchAllPattern)
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
    fileprivate static func parse(headers: HeadersContainer) -> [String: HTTPCookie] {
        var cookies = [String: HTTPCookie]()
        guard let cookieHeaders = headers["cookie"] else {
            return cookies
        }

        for cookieHeader in cookieHeaders {
            for cookie in cookieHeader.split(separator: ";") {
                let trimmedCookie = String(cookie.trimASCIIWhitespace())
                if let cookie = getCookie(cookie: trimmedCookie) {
                    cookies[cookie.name] = cookie
                }
            }
        }
        return cookies
    }

    private static func getCookie(cookie: String) -> HTTPCookie? {
        #if swift(>=4.2)
        guard let index = cookie.firstIndex(of: "=") else {
            return nil
        }
        #else
        guard let index = cookie.index(of: "=") else {
            return nil
        }
        #endif

        let name = String(cookie[..<index].trimASCIIWhitespace())
        var value = String(cookie[cookie.index(after: index)...].trimASCIIWhitespace())

        let chars = value
        if chars.count >= 2 && chars.first == "\"" && chars.last == "\"" {
            // unquote value
            value.remove(at: value.startIndex)
            value.remove(at: value.index(before: value.endIndex))
        }

        return HTTPCookie(properties:
            [HTTPCookiePropertyKey.domain: ".",
             HTTPCookiePropertyKey.path: "/",
             HTTPCookiePropertyKey.name: name,
             HTTPCookiePropertyKey.value: value])
    }
}
