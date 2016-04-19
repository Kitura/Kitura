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
import Foundation

public class Cookies {
    //
    // Storage of parsed Cookie headers
    //
    public var cookies = [String: NSHTTPCookie]()
    
    //
    // Static for Cookie header key value
    //
    private let cookieHeader = "cookie"
    
    public init(headers: SimpleHeaders) {
        var cookieString: String?
        for  (header, value)  in headers  {
            #if os(Linux)
                let lowercasedHeader = header.bridge().lowercaseString
            #else
                let lowercasedHeader = header.lowercased()
            #endif
            if  lowercasedHeader  == cookieHeader {
                cookieString = value
                break
            }
        }
        
        if  let cookieString = cookieString {
            #if os(Linux)
                let cookieNameValues = cookieString.bridge().componentsSeparatedByString("; ")
            #else
                let cookieNameValues = cookieString.componentsSeparated(by: "; ")
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
