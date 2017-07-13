import HTTP

// Protocols related to ResponseCreating

public protocol ResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, response: HTTPResponseWriter) -> HTTPBodyProcessing
}

public protocol BodylessParameterResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, parameters: BodylessParameterContaining, response: HTTPResponseWriter) -> HTTPBodyProcessing
}

public protocol ParameterResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, parameters: ParameterContaining, response: HTTPResponseWriter) -> (response: HTTPResponse, responseBody: ResponseObject)
}

public protocol FileResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, filePath: String, response: HTTPResponseWriter) -> HTTPBodyProcessing
}
