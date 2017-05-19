//
//  RequestHandlingCoordinator.swift
//  K2Spike
//
//  Created by Carl Brown on 4/28/17.
//
//

import Foundation
import Dispatch
import HTTPSketch

public class RequestHandlingCoordinator {
    
    let router: Router
    
    private var preProcessors : [HTTPPreProcessing] = []
    private var postProcessors : [HTTPPostProcessing] = []
    
    public init(router: Router) {
        self.router = router
    }
        
    public func handle(req: HTTPRequest, res: HTTPResponseWriter ) -> HTTPBodyProcessing {
        
        let initialContext = RequestContext(dict:[:])
        
        let (proccessedReq, processedContext) = self.runPreProcessors(req: req, context: initialContext)

        let routeTuple = router.route(request: req)

        guard let handler = routeTuple?.handler else {
            // No response creator found
            // Handle failure
            return serveWithFailureHandler(request: proccessedReq, context: processedContext, response: res)
        }

        switch handler {
        case .skipParameters(let responseCreator):
            return responseCreator.serve(request: proccessedReq, context: processedContext, response:runPostProcessors(req: proccessedReq, context: processedContext, res: res))
        case .skipBody(let parameterType, let responseCreator):
            // Step 1:
            // Generate parameter object
            guard let parameters = parameterType.init(pathParameters: routeTuple?.components?.parameters, queryParameters: routeTuple?.components?.queries, headers: proccessedReq.headers) else {
                return serveWithFailureHandler(request: proccessedReq, context: processedContext, response: res)
            }

            // Step 2:
            // Serve content using parameters
            return responseCreator.serve(request: proccessedReq, context: processedContext, parameters: parameters, response: runPostProcessors(req: proccessedReq, context: processedContext, res: res))
        case .parseBody(let parameterType, let responseCreator):
            var body = DispatchData.empty

            // Have to parse body parameters
            return .processBody { (chunk, stop) in
                switch chunk {
                case .chunk(let data, let finishedProcessing):
                    // Step 1:
                    // Buffer the body chunks
                    if (data.count > 0) {
                        body.append(data)
                    }
                    finishedProcessing()
                case .end:
                    // Step 2:
                    // Generate parameter object
                    if let parameters = parameterType.init(pathParameters: routeTuple?.components?.parameters, queryParameters: routeTuple?.components?.queries, headers: proccessedReq.headers, body: body) {
                        // Step 3:
                        // Get response object from serving content using parameters
                        let responseObject = responseCreator.serve(request: proccessedReq, context: processedContext, parameters: parameters, response: res)

                        // Step 4:
                        // Write response
                        if let data = responseObject.toData() {
                            res.writeBody(data: data)
                        }

                        // TODO
                        // Write HTTPResponse
                    }
                    else {
                        res.writeResponse(HTTPResponse(httpVersion: req.httpVersion,
                                                       status: .notFound,
                                                       transferEncoding: .chunked,
                                                       headers: HTTPHeaders()))
                    }

                    res.done()
                default:
                    stop = true
                    res.abort()
                }
            }
        }
    }
    
    public func addPreProcessor(_ preprocessor: @escaping HTTPPreProcessing) {
        self.preProcessors.append(preprocessor)
    }
    
    public func addPostProcessor(_ postprocessor: @escaping HTTPPostProcessing) {
        self.postProcessors.append(postprocessor)
    }
    
    private func runPreProcessors(req: HTTPRequest, context cntx: RequestContext) -> (HTTPRequest, RequestContext) {
        var request = req
        var context = cntx
        let processorBlockComplete = DispatchSemaphore(value: 0)
        
        for preProcessor in self.preProcessors {
            let tmp = preProcessor(request, context) { (newReq, newCntx) in
                request = newReq
                context = newCntx
                processorBlockComplete.signal()
            }
            switch tmp {
            case .notApplicable:
                break
            case .replace(let newReq, let newCntx):
                request = newReq
                context = newCntx
            case .willCallCompletionBlock:
                processorBlockComplete.wait()
            }
        }
        
        return (request, context)
    }
    
    private func runPostProcessors (req: HTTPRequest, context: RequestContext, res: HTTPResponseWriter) -> HTTPResponseWriter {
        var responseWriter = res
        
        for postProcessor in postProcessors {
            let result = postProcessor(req, context, responseWriter)
            switch result {
            case .replace(let res):
                responseWriter = res
            case .notApplicable:
                break
            }
        }
        
        return responseWriter
    }

    private func serveWithFailureHandler(request: HTTPRequest, context: RequestContext, response: HTTPResponseWriter) -> HTTPBodyProcessing {
        return WebAppFailureHandler().serve(request: request, context: context, response: runPostProcessors(req: request, context: context, res: response))
    }
}

public typealias HTTPPostProcessing = (_ req: HTTPRequest, _ context: RequestContext, _ res: HTTPResponseWriter) -> HTTPPostProcessingStatus

public typealias HTTPPreProcessing =  (_ req: HTTPRequest, _ context: RequestContext, _ completionHandler: @escaping (_ req: HTTPRequest, _ context: RequestContext) -> ()) -> HTTPPreProcessingStatus

public enum HTTPPreProcessingStatus {
    case notApplicable
    case replace(req: HTTPRequest, context: RequestContext)
    case willCallCompletionBlock
}

public enum HTTPPostProcessingStatus {
    case notApplicable
    case replace(res: HTTPResponseWriter)
}

//public protocol ResponseCreating: class {
//    func serve(request: HTTPRequest, context: RequestContext, response: HTTPResponseWriter) -> HTTPBodyProcessing
//}

