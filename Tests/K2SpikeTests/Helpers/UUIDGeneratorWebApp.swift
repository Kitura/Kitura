//
//  UUIDGeneratorWebApp.swift
//  K2Spike
//
//  Created by Carl Brown on 5/4/17.
//
//

import Foundation
import K2Spike
import SwiftServerHttp

class UUIDGeneratorWebApp: ResponseCreating {
    func serve(request req: HTTPRequest, context: RequestContext, response res: HTTPResponseWriter ) -> HTTPBodyProcessing {
        //Assume the router gave us the right request - at least for now
        res.writeResponse(HTTPResponse(httpVersion: req.httpVersion,
                                       status: .ok,
                                       transferEncoding: .chunked,
                                       headers: HTTPHeaders([("X-foo", "bar")])))
        return .processBody { (chunk, stop) in
            switch chunk {
            case .chunk(_, let finishedProcessing):
                finishedProcessing()
            case .end:
                res.writeBody(data:UUID().uuidString.data(using: .utf8)!) { _ in }
                res.done()
            default:
                stop = true /* don't call us anymore */
                res.abort()
            }
        }
    }
}
