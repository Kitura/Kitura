//
//  HelloWorldWebApp.swift
//  Kitura
//
//  Created by Carl Brown on 4/27/17.
//
//

import Foundation
import Kitura
import HTTP

class HelloWorldWebApp: ResponseCreating {
    func serve(request req: HTTPRequest, context: RequestContext, response res: HTTPResponseWriter ) -> HTTPBodyProcessing {
        //Assume the router gave us the right request - at least for now
        res.writeHeader(status: .ok, headers: [.transferEncoding: "chunked"])
        return .processBody { (chunk, stop) in
            switch chunk {
            case .chunk(_, let finishedProcessing):
                finishedProcessing()
            case .end:
                res.writeBody("Hello, World!".data(using: .utf8)!) { _ in }
                res.done()
            default:
                stop = true /* don't call us anymore */
                res.abort()
            }
        }
    }
}
