import HTTPSketch

// Protocols related to ResponseCreating

public protocol ResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, response: HTTPResponseWriter) -> HTTPBodyProcessing
}

public protocol ResponseCreatorChunked {
    func serve(request: HTTPRequest?, context: RequestContext?, parameters: ParameterContaining, response: HTTPResponseWriter?) -> HTTPBodyProcessing
}

//extension ResponseCreatorChunked {
//    @available(*, unavailable, message: "Use serve with parameters instead")
//    func serve(request: HTTPRequest, context: RequestContext, response: HTTPResponseWriter) -> HTTPBodyProcessing {
//        return .discardBody
//    }
//}

public protocol ResponseCreatorStored {
    func serve(request: HTTPRequest, context: RequestContext, parameters: PayloadParameterContaining, response: HTTPResponseWriter) -> ResponseObject
}

//extension ResponseCreatorStored {
//    @available(*, unavailable, message: "Use serve with parameters instead")
//    func serve(request: HTTPRequest, context: RequestContext, response: HTTPResponseWriter) -> HTTPBodyProcessing {
//        return .discardBody
//    }
//}

// 1. want body or not
// 2. chunk or not
// 3. param parse body or not

//protocol RequestStructParser<T> {
//    func createStruct(path:String, queryParams:String?, Body:Data?) -> T?
//}
//struct RequestContext {
//    let storage: [String: Codeable]
//    init(dict:[String:Codeable]) {
//        storage = dict
//    }
//    adding(dict:[String:Codeable]) {
//    return RequestContext(storage.merging(dict))
//    }
//}
//protocol SwaggerQueryable {
//    func failureCodes() -> [HTTPResponseStatus]
//    func responseType() -> Codable? //For Swagger creation - format TBD
//}
//protocol ResponseCreatorChunked : SwaggerQueryable {
//    func serve(req: HTTPRequest, context:RequestContext res: HTTPResponseWriter) -> HTTPBodyProcessing
//}
//protocol ResponseCreatorDataBody : SwaggerQueryable {
//    func serve(req: HTTPRequest, body:Data, context:RequestContext) -> Data
//}
//protocol ResponseCreatorRequestStruct<T,R> : SwaggerQueryable {
//    func serve(req: HTTPRequest, requestStruct:T, context:RequestContext) -> R
//}
//protocol ResponseCreatorBodyless<R> : SwaggerQueryable {
//    func serve(req: HTTPRequest, context:RequestContext) -> R
//}
//class BodylessParamlessRoute : BaseRoute {
//    init (verb:HTTPMethod, path:String, responseCreator:ResponseCreatorBodyless) /**/
//}
//class BodylessRoute : BaseRoute {
//    init (verb:HTTPMethod, path:String, paramStruct:RequestStructParser, responseCreator:ResponseCreatorRequestStruct) /**/
//}
//class RequestStructRoute : BaseRoute {
//    init (verb:HTTPMethod, path:String, paramStruct:RequestStructParser, responseCreator:ResponseCreatorRequestStruct) /**/
//}
//class ChunkedRoute : BaseRoute {
//    init (verb:HTTPMethod, path:String, paramStruct:RequestStructParser, responseCreator:ResponseCreatorChunked) /**/
//}
////TODO: Can we use the same constructor here (e.g. `Route()` instead of `BodylessRoute()`/`ChunkedRoute()`) and still get compiler checking when calling `serve()` later?
//let storeRouter = Router(prefix:"/store")
//storeRouter.authorized = { authInfo in
//    return (authInfo != nil) //For the /store prefix, unless otherwise specified, everyone can, unless anonymous...
//}
////leading prefix "/store" from these routes can be included or omitted
//storeRouter.add(BodylessParamlessRoute(verb:.get, path:"/store/order/latest", responseCreator:GetLatestOrderResponseCreator()))
//storeRouter.add(BodylessRoute(verb:.get, path:"/store/order/{orderId}", paramStruct:OrderIdStructParser(), responseCreator:GetOrderByIdResponseCreator()))
//storeRouter.add(RequestStructRoute(verb:.put, path:"/store/order", paramStruct:OrderCreatorStructParser(), responseCreator:CreateOrderResponseCreator()))
//storeRouter.add(ChunkedRoute(verb:.post, path:"/receipt/upload/{orderId}", paramStruct:OrderIdStructParser(), responseCreator:UploadOrderReceiptByIdResponseCreator()))
//let orderDeleter = BodylessRoute(verb:.delete, path:"/order/{orderId}", paramStruct:OrderIdStructParser(), responseCreator:DeleteOrderByIdResponseCreator())
//orderDeleter.authorized = { authInfo in
//    return Global.isInSomeBigList(authInfo) //Custom auth here
//}
//storeRouter.add(orderDeleter)
//server.add(storeRouter)
