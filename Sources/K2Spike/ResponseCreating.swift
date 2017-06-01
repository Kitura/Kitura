import SwiftServerHttp

// Protocols related to ResponseCreating

public protocol ResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, response: HTTPResponseWriter) -> HTTPBodyProcessing
}

public protocol BodylessParameterResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, parameters: BodylessParameterContaining, response: HTTPResponseWriter) -> HTTPBodyProcessing
}

public protocol ParameterResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, parameters: ParameterContaining, response: HTTPResponseWriter) -> ResponseObject
}
