//
//  UUIDGeneratorWebApp.swift
//  Kitura
//
//  Created by Carl Brown on 5/4/17.
//
//

import Foundation
import Kitura
import HTTP

class UUIDGeneratorWebApp: ResponseCreating {
    func serve(request req: HTTPRequest, context: RequestContext, response res: HTTPResponseWriter ) -> HTTPBodyProcessing {
        //Assume the router gave us the right request - at least for now
        res.writeHeader(status: .ok, headers: [.transferEncoding: "chunked"])
        return .processBody { (chunk, stop) in
            switch chunk {
            case .chunk(_, let finishedProcessing):
                finishedProcessing()
            case .end:
                res.writeBody(UUID().uuidString.data(using: .utf8)!) { _ in }
                res.done()
            default:
                stop = true /* don't call us anymore */
                res.abort()
            }
        }
    }
}
