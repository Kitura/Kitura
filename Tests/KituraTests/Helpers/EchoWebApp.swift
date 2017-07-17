import Foundation
import Kitura
import HTTP

class EchoWebApp: ResponseCreating {
    func serve(request req: HTTPRequest, context: RequestContext, response res: HTTPResponseWriter ) -> HTTPBodyProcessing {
        //Assume the router gave us the right request - at least for now
        res.writeHeader(status: .ok, headers: [.transferEncoding: "chunked"])
        return .processBody { (chunk, stop) in
            switch chunk {
            case .chunk(let data, let finishedProcessing):
                res.writeBody(data) { _ in
                    finishedProcessing()
                }
            case .end:
                res.done()
            default:
                stop = true /* don't call us anymore */
                res.abort()
            }
        }
    }
}
