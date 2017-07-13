// Protocols related to parameters

import Foundation
import Dispatch
import HTTP

// All parameter objects that do not require body inspection inherit this
public protocol BodylessParameterContaining {
    init?(pathParameters: [String: String]?, queryParameters: [URLQueryItem]?, headers: HTTPHeaders)
}

// All parameter objects that require body inspection inheirt this
public protocol ParameterContaining {
    init?(pathParameters: [String: String]?, queryParameters: [URLQueryItem]?, headers: HTTPHeaders, body: DispatchData)
}
