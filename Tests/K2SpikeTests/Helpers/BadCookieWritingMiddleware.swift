//
//  BadCookieWritingMiddleware.swift
//  K2Spike
//
//  Created by Carl Brown on 5/1/17.
//
//

import Foundation
import Dispatch
import LoggerAPI
import K2Spike
import SwiftServerHttp

class BadCookieWritingMiddleware {
    
    var UUIDString:String?
    let cookieName:String
    let urlForUUIDFetch: URL
    
    private class HTTPResponseWriterAddingCookie : HTTPResponseWriter {
        let oldResponseWriter: HTTPResponseWriter
        let cookieValue: String
        
        init(oldResponseWriter: HTTPResponseWriter, cookieValue: String) {
            self.oldResponseWriter = oldResponseWriter
            self.cookieValue = cookieValue
        }
        
        func writeResponse(_ response: HTTPResponse) {
            var responseWithCookie = response
            
            responseWithCookie.headers["Set-Cookie"] = [self.cookieValue]
            
            oldResponseWriter.writeResponse(responseWithCookie)
        }
        
        func writeContinue(headers: HTTPHeaders?) { return oldResponseWriter.writeContinue(headers:headers) }
        
        
        func writeTrailer(key: String, value: String) { return oldResponseWriter.writeTrailer(key:key, value:value) }
        
        func writeBody(data: DispatchData, completion: @escaping (Result<POSIXError, ()>) -> Void) {
            return oldResponseWriter.writeBody(data:data, completion: completion)
        }

        func writeBody(data: DispatchData) { return oldResponseWriter.writeBody(data:data) }
        
        func writeBody(data: Data, completion: @escaping (Result<POSIXError, ()>) -> Void) {
            return oldResponseWriter.writeBody(data:data, completion: completion)
        }
        func writeBody(data: Data)  { return oldResponseWriter.writeBody(data:data) }
        
        func done() { return oldResponseWriter.done() }
        func done(completion: @escaping (Result<POSIXError, ()>) -> Void) {
            return oldResponseWriter.done(completion:completion)
        }
        func abort()  { return oldResponseWriter.abort() }

    }
    
    init(cookieName: String, urlForUUIDFetch: URL) {
        self.cookieName = cookieName
        self.urlForUUIDFetch = urlForUUIDFetch
    }
    
    func preProcess (_ req: HTTPRequest, _ context: RequestContext, _ completionHandler: @escaping (_ req: HTTPRequest, _ context: RequestContext) -> ()) -> HTTPPreProcessingStatus {
        //Go grab a UUID from the web - not because we need to, but because we want to test Async().
        //FIXME: Get this to not fail when offline
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: urlForUUIDFetch) { (responseBody, rawResponse, error) in
            guard let body = responseBody, let uuidString = String(data: body, encoding: .utf8) else {
                Log.error("failed to retrive UUID")
                completionHandler(req, context)
                return
            }
            let urlResponse = rawResponse as? HTTPURLResponse
            guard let response = urlResponse else {
                Log.error("failed to get status code")
                completionHandler(req, context)
                return
            }
            if response.statusCode != 200 {
                Log.error("Status code was not OK")
                completionHandler(req, context)
                return
            }
            let index = uuidString.index(uuidString.startIndex, offsetBy: 36
            )
            completionHandler(req, context.adding(dict: ["X-OurUUID":uuidString.substring(to: index)]))
        }
        dataTask.resume()
        return .willCallCompletionBlock
    }
    
    func postProcess (_ req: HTTPRequest, _ context: RequestContext, _ res: HTTPResponseWriter) -> HTTPPostProcessingStatus {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(identifier: "GMT")!
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss z"
        let cookieDate = Date(timeIntervalSinceNow: 3600)
        
        if let uuidString = context["X-OurUUID"] {
            
            let cookieString = "\(self.cookieName)=\(uuidString); path=/; domain=localhost; expires=\(dateFormatter.string(from: cookieDate));"
            
            return HTTPPostProcessingStatus.replace(res: HTTPResponseWriterAddingCookie(oldResponseWriter: res, cookieValue: cookieString))
        }
        
        Log.verbose("Can't get X-OurUUID from context")
        return HTTPPostProcessingStatus.notApplicable
    }
    
}
