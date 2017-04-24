//
//  ResponseCreator.swift
//  K2Spike
//
//  Created by Carl Brown on 4/24/17.
//
//

import Foundation
import LoggerAPI

public class ResponseCreator: ServerDelegate {
    public func serve(req: HTTPRequest, res: HTTPResponseWriter) -> HTTPBodyProcessing {
        Log.debug("ResponseCreator serving \(req.target)")

        if req.target == "/echo" {
            guard req.httpVersion == (1, 1) else {
                /* HTTP/1.0 doesn't support chunked encoding */
                res.writeResponse(HTTPResponse(httpVersion: req.httpVersion,
                                               status: .httpVersionNotSupported,
                                               transferEncoding: .identity(contentLength: 0), headers: HTTPHeaders()))
                res.done()
                return .discardBody
            }
            res.writeResponse(HTTPResponse(httpVersion: req.httpVersion,
                                           status: .ok,
                                           transferEncoding: .chunked,
                                           headers: HTTPHeaders([("X-foo", "bar")])))
            return .processBody { (chunk, stop) in
                switch chunk {
                case .chunk(let data, let finishedProcessing):
                    res.writeBody(data: data) { _ in
                        finishedProcessing()
                    }
                case .end:
                    res.done()
                default:
                    stop = true /* don't call us anymore */
                    res.abort()
                }
            }
        } else if req.target == "/hello" {
            let response = "Hello world!".data(using: String.Encoding.utf8)!
            res.writeResponse(HTTPResponse(httpVersion: req.httpVersion,
                                           status: .ok,
                                           transferEncoding: .identity(contentLength: UInt(response.count)), headers: HTTPHeaders()))
            return .processBody { (chunk, stop) in
                switch chunk {
                case .chunk(_, let finishedProcessing):
                    res.writeBody(data: response) { _ in
                        finishedProcessing()
                    }
                case .end:
                    res.done()
                default:
                    stop = true /* don't call us anymore */
                    res.abort()
                }
            }
        } else {
            //404
            res.writeResponse(HTTPResponse(httpVersion: req.httpVersion,
                                           status: .notFound,
                                           transferEncoding: .identity(contentLength: 0), headers: HTTPHeaders()))
            res.done()
            return .discardBody
        }
    }

}
