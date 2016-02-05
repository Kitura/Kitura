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

import net
import BlueSocket

import Foundation

public class RouterRequest: ETReader {
    let serverRequest: ServerRequest
    let parsedUrl: UrlParser
    
    public internal(set) var route: String?
    
    public var originalUrl: String {
        return serverRequest.urlString
    }
    
    public var url: String
    
    
    public var headers: [String:String] { return serverRequest.headers }
    public var params: [String:String] = [:]
    public var queryParams: [String:String] { return parsedUrl.queryParams }
    public var userInfo: [String: AnyObject] = [:]

    public internal(set) var body: ParsedBody? = nil
    
    init(request: ServerRequest) {
        serverRequest = request
        parsedUrl = UrlParser(url: serverRequest.url, isConnect: false)
        url = String(serverRequest.urlString)
    }
    
    public func readData(data: NSMutableData) throws -> Int {
        return try serverRequest.readData(data)
    }
    
    public func readString() throws -> String? {
        return try serverRequest.readString()
    }
}
