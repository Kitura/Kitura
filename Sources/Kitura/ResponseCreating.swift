import HTTP

// Protocols related to ResponseCreating

public protocol ResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, response: HTTPResponseWriter) -> HTTPBodyProcessing
}

public protocol BodylessParameterResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, parameters: BodylessParameterContaining, response: HTTPResponseWriter) -> HTTPBodyProcessing
}

public protocol ParameterResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, parameters: ParameterContaining, response: HTTPResponseWriter) -> (status: HTTPResponseStatus, headers:HTTPHeaders, responseBody: ResponseObject)
}

public protocol FileResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, filePath: String, response: HTTPResponseWriter) -> HTTPBodyProcessing
}
