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
import BlueSocket

import Foundation

// MARK: RouterRequest

public class RouterRequest: BlueSocketReader {

    ///
    /// The server request
    ///
    let serverRequest: ServerRequest

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
    public var headers: SimpleHeaders { return serverRequest.headers }

    ///
    /// List of HTTP headers with String array values
    ///
    public var headersAsArrays: ArrayHeaders { return serverRequest.headersAsArrays }

    //
    // Parsed Cookies, used to do a lazy parsing of the appropriate headers
    //
    private var _cookies: Cookies?

    ///
    /// Set of parsed cookies
    ///
    public var cookies: [String: NSHTTPCookie] {
        if  _cookies == nil  {
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
    public func readData(data: NSMutableData) throws -> Int {
        return try serverRequest.readData(data)
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

}

private class Cookies {
    //
    // Storage o parsed Cookie headers
    //
    private var cookies = [String: NSHTTPCookie]()

    //
    // Static for Cookie header key value
    //
    private let cookieHeader = "cookie"

    private init(headers: SimpleHeaders) {
        var cookieString: String?
        for  (header, value)  in headers  {
            if  header.bridge().lowercaseString == cookieHeader {
                cookieString = value
                break
            }
        }

        if  let cookieString = cookieString {
            let cookieNameValues = cookieString.bridge().componentsSeparatedByString("; ")
            for  cookieNameValue  in  cookieNameValues  {
                let cookieNameValueParts = cookieNameValue.bridge().componentsSeparatedByString("=")
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
