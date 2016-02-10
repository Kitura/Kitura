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
import sys

import SwiftyJSON

import Foundation

public class RouterResponse {
    let response: ServerResponse
    private let buffer = BufferList()

    var invokedEnd = false
    
    public var error: NSError?
    
    init(response: ServerResponse) {
        self.response = response
        status(HttpStatusCode.NOT_FOUND)
    }
    
    public func end() throws -> RouterResponse {
        
        if  let data = buffer.data  {
            let contentLength = getHeader("Content-Length")
            if  contentLength == nil  {
                setHeader("Content-Length", value: String(buffer.count))
            }
            try response.writeData(data)
        }
        invokedEnd = true
        try response.end()
        return self
    }
    
    public func end(str: String) throws -> RouterResponse {
        send(str)
        try end()
        return self
    }
    
    public func end(data: NSData) throws -> RouterResponse {
        sendData(data)
        try end()
        return self
    }

    
    public func sendData(data: NSData) -> RouterResponse {
        buffer.appendData(data)
        return self
    }
    
    public func send(str: String) -> RouterResponse {
        if  let data = StringUtils.toUtf8String(str)  {
            buffer.appendData(data)
        }
        return self
    }
    
    public func sendJson(json: JSON) -> RouterResponse {
        let jsonStr = json.description
        setHeader("Content-Type", value: ContentType.contentTypeForExtension("json")!)
        send(jsonStr)
        return self
    }
    
    public func status(status: Int) -> RouterResponse {
        response.status = status
        return self
    }
    
    public func status(status: HttpStatusCode) -> RouterResponse {
        response.statusCode = status
        return self
    }
    
    public func sendStatus(status: Int) throws -> RouterResponse {
        self.status(status)
        if  let statusText = Http.statusCodes[status] {
            send(statusText)
        }
        else {
            send(String(status))
        }
        return self

    }
    
    public func sendStatus(status: HttpStatusCode) throws -> RouterResponse {
        self.status(status)
        send(Http.statusCodes[status.rawValue]!)
        return self

    }
    
    public func getHeader(key: String) -> String? {
        return response.getHeader(key)
    }
    
    public func getHeaders(key: String) -> [String]? {
        return response.getHeaders(key)
    }
    
    public func setHeader(key: String, value: String) {
        response.setHeader(key, value: value)
    }
    
    public func setHeader(key: String, value: [String]) {
        response.setHeader(key, value: value)
    }
    
    public func removeHeader(key: String) {
        response.removeHeader(key)
    }
    
    public func redirect(path: String) throws -> RouterResponse {
        return try redirect(.MOVED_TEMPORARILY, path: path)
    }
    
    public func redirect(status: HttpStatusCode, path: String) throws -> RouterResponse {
        try redirect(status.rawValue, path: path)
        return self
    }

    public func redirect(status: Int, path: String) throws -> RouterResponse {
        try self.status(status).location(path).end()
        return self
    }
    
    public func location(path: String) -> RouterResponse {
        var p = path
        if  p == "back" {
            let referrer = getHeader("referrer")
            if  let r = referrer {
                p = r
            }
            else {
                p = "/"
            }
        }
        setHeader("Location", value: p)
        return self
    }
}
