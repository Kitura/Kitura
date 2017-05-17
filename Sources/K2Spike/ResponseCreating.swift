import HTTPSketch

// Protocols related to ResponseCreating

public protocol ResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, response: HTTPResponseWriter) -> HTTPBodyProcessing
}

public protocol ResponseCreatorChunked {
    func serve(request: HTTPRequest?, context: RequestContext?, parameters: ParameterContaining, response: HTTPResponseWriter?) -> HTTPBodyProcessing
}

public protocol ResponseCreatorStored {
    func serve(request: HTTPRequest, context: RequestContext, parameters: PayloadParameterContaining, response: HTTPResponseWriter) -> ResponseObject
}
