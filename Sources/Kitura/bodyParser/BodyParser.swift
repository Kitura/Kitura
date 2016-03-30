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

import SwiftyJSON

import KituraSys
import KituraNet
import Socket

import Foundation

// MARK: BodyParser

public class BodyParser : RouterMiddleware {

    ///
    /// Default buffer size (in bytes)
    ///
    private static let BUFFER_SIZE = 2000

    /// 
    /// Initializes a BodyParser instance
    ///
    public init() {}

    ///
    /// Handle the request
    ///
    /// - Parameter request: the router request
    /// - Parameter response: the router response
    /// - Parameter next: the closure for the next execution block 
    ///
    public func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        request.body = BodyParser.parse(request, contentType: request.serverRequest.headers["Content-Type"])
        next()
        
    }

    ///
    /// Parse the incoming message
    ///
    /// - Parameter message: message coming from the socket
    /// - Parameter contentType: the contentType as a string 
    ///
    public class func parse(message: SocketReader, contentType: String?) -> ParsedBody? {
        
        if let contentType = contentType {
            do {

        if ContentType.isType(contentType, typeDescriptor: "json") {
            let bodyData = try readBodyData(message)
            let json = JSON(data: bodyData)
            if json != JSON.null {
               return ParsedBody(json: json)
            }
        }
        else if ContentType.isType(contentType, typeDescriptor: "urlencoded") {
          let bodyData = try readBodyData(message)
          var parsedBody = [String:String]()
          var success = true
          if let bodyAsString: String = String(data: bodyData, encoding: NSUTF8StringEncoding) {

            let bodyAsArray = bodyAsString.bridge().componentsSeparated(by: "&")
            for element in bodyAsArray {
              let elementPair = element.bridge().componentsSeparated(by: "=")
              if elementPair.count == 2 {
                parsedBody[elementPair[0]] = elementPair[1]
              }
              else {
                success = false
              }
            }
            if success && parsedBody.count > 0 {
              return ParsedBody(urlEncoded: parsedBody)
            }
          }
        }
        // There was no support for the application/json MIME type
        else if (ContentType.isType(contentType, typeDescriptor: "text/*") ||
          ContentType.isType(contentType, typeDescriptor: "application/json")) {
          let bodyData = try readBodyData(message)
          if let bodyAsString: String = String(data: bodyData, encoding: NSUTF8StringEncoding) {
            return ParsedBody(text:  bodyAsString)
          }
        }
      }
      catch {
        // response.error = error
      }
    }

    return nil
  }

    ///
    /// Read the Body data
    ///
    /// - Parameter reader: the socket reader 
    ///
    /// - Throws: ???
    /// - Returns: data for the body 
    ///
    public class func readBodyData(reader: SocketReader) throws -> NSMutableData {
        
        let bodyData = NSMutableData()

        var length = try reader.read(into: bodyData)
        while length != 0 {
            length = try reader.read(into: bodyData)
        }
        return bodyData
    }

}

// MARK: ParsedBody

public class ParsedBody {
    
    ///
    /// JSON body if the body is JSON
    ///
    private var jsonBody: JSON?
  
    ///
    /// URL encoded body
    ///
    private var urlEncodedBody: [String:String]?
    
    ///
    /// Plain-text body
    ///
    private var textBody: String?

    /// 
    /// Initializes a ParsedBody instance
    ///
    /// - Parameter json: JSON formatted data
    ///
    /// - Returns: a ParsedBody instance
    ///
    public init (json: JSON) {
        
        jsonBody = json
        
    }

    ///
    /// Initializes a ParsedBody instance
    ///
    /// - Parameter urlEncoded: a list of String,String tuples
    ///
    /// - Returns a parsed body instance
    ///
    public init (urlEncoded: [String:String]) {
        urlEncodedBody = urlEncoded
    }

    ///
    /// Initializes a ParsedBody instance
    ///
    /// - Parameter text: the String plain-text
    ///
    /// - Returns a parsed body instance
    ///
    public init (text: String) {
        textBody = text
    }

    ///
    /// Returns the body as JSON
    ///
    /// - Returns: the JSON 
    ///
    public func asJson() -> JSON? {
      return jsonBody
    }

    ///
    /// Returns the body as URL encoded strings
    ///
    /// - Returns: the list of string, string tuples
    ///
    public func asUrlEncoded() -> [String:String]? {
        return urlEncodedBody
    }

    ///
    /// Returns the body as plain-text 
    ///
    /// - Returns: the plain text
    ///
    public func asText() -> String? {
        return textBody
    }
    
}
