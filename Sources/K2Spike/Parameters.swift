// Protocols related to parameters

import Foundation
import HTTPSketch

// All parameter objects inherit this
public protocol ParameterContaining {
    init?(pathParameters: [String: String]?, queryParameters: [URLQueryItem]?, headers: HTTPHeaders)
}

// All parameter objects that require body parsing/storing inheirt this
public protocol PayloadParameterContaining {
    init?(pathParameters: [String: String]?, queryParameters: [URLQueryItem]?, headers: HTTPHeaders, body: Data)
}

//public protocol PathParameterContaining: ParameterContaining {
//    associatedtype PathParams
//    var pathParameters: PathParams { get }
//}
//
//public protocol QueryParameterContaining: ParameterContaining {
//    associatedtype QueryParams
//    var queryParameters: QueryParams { get }
//}
//
//public protocol HeaderParameterContaining: ParameterContaining {
//    associatedtype HeaderParams
//    var headerParameters: HeaderParams { get }
//}
//
//public enum PayloadType: String {
//    case body
//    case formData
//}
//
//public protocol PayloadParameterContaining: BodyWaiting {
//    associatedtype PayloadParams
//    var payloadParameters: PayloadParams { get }
//
//    static var payloadType: PayloadType { get }
//}

//struct Body {
//
//}
//
//struct Test: PayloadParameterContaining {
//    init?(pathParameters: [String : String]?, queryParameters: [URLQueryItem]?, headers: HTTPHeaders, body: Data?) {
//        return nil
//    }
//
//    static var payloadType: PayloadType = .body
//
//    var payloadParameters: Body
//}
//
//let a = Test.supportsChunking
