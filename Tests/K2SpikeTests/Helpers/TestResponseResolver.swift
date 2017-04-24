//
//  TestResponseResolver.swift
//  K2Spike
//
//  Created by Carl Brown on 4/24/17.
//
//

import Foundation
import Dispatch
import K2Spike
import HTTPSketch

class TestResponseResolver: HTTPResponseWriter {
    let request: HTTPRequest
    let requestBody: DispatchData
    
    var response: HTTPResponse?
    var responseBody: Data?
    
    
    init(request: HTTPRequest, requestBody: Data) {
        self.request = request
        self.requestBody = requestBody.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> DispatchData in
            DispatchData(bytes: UnsafeBufferPointer<UInt8>(start: ptr, count: requestBody.count))
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
    
    func writeContinue(headers: HTTPHeaders?) /* to send an HTTP `100 Continue` */ {
        fatalError("Not implemented")
    }
    
    func writeResponse(_ response: HTTPResponse) {
        self.response=response
    }
    
    func writeTrailer(key: String, value: String) {
        fatalError("Not implemented")
    }
    
    func writeBody(data: DispatchData, completion: @escaping (Result<POSIXError, ()>) -> Void) {
        self.responseBody = Data(data)
        completion(Result(completion: ()))
    }
    func writeBody(data: DispatchData) /* convenience */ {
        writeBody(data: data) { _ in
            
        }
    }
    
    func writeBody(data: Data, completion: @escaping (Result<POSIXError, ()>) -> Void) {
        self.responseBody = data
        completion(Result(completion: ()))
    }
    
    func writeBody(data: Data) /* convenience */ {
        writeBody(data: data) { _ in
            
        }
    }
    
    func done(completion: @escaping (Result<POSIXError, ()>) -> Void) {
        completion(Result(completion: ()))
    }
    func done() /* convenience */ {
        done() { _ in
        }
    }
    
    func abort() {
        fatalError("abort called, not sure what to do with it")
    }
    
}
