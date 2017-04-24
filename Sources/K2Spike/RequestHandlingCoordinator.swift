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
        
        let routeTupple = router.route(request: req) //FIXME: Handle Error case
        
        if let responseCreator = routeTupple?.1 {
            return responseCreator.serve(req: proccessedReq, context: processedContext, res:runPostProcessors(req: proccessedReq, context: processedContext, res: res))
        }
        
        return WebAppFailureHandler().serve(req: proccessedReq, context: processedContext, res:runPostProcessors(req: proccessedReq, context: processedContext, res: res))
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

public protocol ResponseCreating: class {
    func serve(req: HTTPRequest, context: RequestContext, res: HTTPResponseWriter ) -> HTTPBodyProcessing
}

