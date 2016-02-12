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

import sys
import net
import BlueSocket

import Foundation

public class BodyParser : RouterMiddleware {
  private static let BUFFER_SIZE = 2000

  public init() {}

  public func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    request.body = BodyParser.parse(request, contentType: request.serverRequest.headers["Content-Type"])
    next()
  }

  public class func parse(message: ETReader, contentType: String?) -> ParsedBody? {
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

            let bodyAsArray = bodyAsString.bridge().componentsSeparatedByString("&")
            for element in bodyAsArray {
              let elementPair = element.bridge().componentsSeparatedByString("=")
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

  public class func readBodyData(reader: ETReader) throws -> NSMutableData {
    let bodyData = NSMutableData()

    var length = try reader.readData(bodyData)
    while length != 0 {
      length = try reader.readData(bodyData)
    }
    return bodyData
  }

}

public class ParsedBody {
  private var jsonBody: JSON?
  private var urlEncodedBody: [String:String]?
  private var textBody: String?

  public init (json: JSON) {
      jsonBody = json
  }

  public init (urlEncoded: [String:String]) {
    urlEncodedBody = urlEncoded
  }

  public init (text: String) {
    textBody = text
  }

  public func asJson() -> JSON? {
      return jsonBody
  }

  public func asUrlEncoded() -> [String:String]? {
    return urlEncodedBody
  }

  public func asText() -> String? {
    return textBody
  }
}
