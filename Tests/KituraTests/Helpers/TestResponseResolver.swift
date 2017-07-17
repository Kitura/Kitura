//
//  TestResponseResolver.swift
//  Kitura
//
//  Created by Carl Brown on 4/24/17.
//
//

import Foundation
import Dispatch
import Kitura
import HTTP

/// Acts as a fake/mock `HTTPServer` so we can write XCTests without having to worry about Sockets and such
class TestResponseResolver: HTTPResponseWriter {
    let request: HTTPRequest
    let requestBody: DispatchData
    
    var response: (status: HTTPResponseStatus, headers: HTTPHeaders)?
    var responseBody: HTTPResponseBody?
    
    
    init(request: HTTPRequest, requestBody: Data) {
        self.request = request
        self.requestBody = requestBody.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> DispatchData in
            DispatchData(bytes: UnsafeRawBufferPointer(start: ptr, count: requestBody.count))
        }
    }
    
    func resolveHandler(_ handler:WebApp) {
        let chunkHandler = handler(request, self)
        var stop=false
        var finished=false
        while !stop && !finished {
            switch chunkHandler {
            case .processBody(let handler):
                handler(.chunk(data: self.requestBody, finishedProcessing: {
                    finished=true
                }), &stop)
                handler(.end, &stop)
            case .discardBody:
                finished=true
            }
        }
    }
    
    func writeHeader(status: HTTPResponseStatus, headers: HTTPHeaders, completion: @escaping (Result) -> Void) {
        self.response = (status: status, headers: headers)
        completion(.ok)
    }
    
    func writeTrailer(_ trailers: HTTPHeaders, completion: @escaping (Result) -> Void) {
        fatalError("Not implemented")
    }
    
    func writeBody(_ data: UnsafeHTTPResponseBody, completion: @escaping (Result) -> Void) {
        if let data = data as? HTTPResponseBody {
            self.responseBody = data
        } else {
            self.responseBody = data.withUnsafeBytes { Data($0) }
        }
        completion(.ok)
    }
    
    func done(completion: @escaping (Result) -> Void) {
        completion(.ok)
    }
    func done() /* convenience */ {
        done() { _ in
        }
    }
    
    func abort() {
        fatalError("abort called, not sure what to do with it")
    }
    
}

