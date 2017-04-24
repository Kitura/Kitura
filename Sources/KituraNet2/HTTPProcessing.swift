/* a web app is a function that gets a HTTPRequest and a HTTPResponseWriter and returns a function which processes the HTTP request body in chunks as they arrive */

import Foundation
import Dispatch

public typealias WebApp = (HTTPRequest, HTTPResponseWriter) -> HTTPBodyProcessing

public struct HTTPRequest {
    public var method : HTTPMethod
    public var target : String /* e.g. "/foo/bar?buz=qux" */
    public var httpVersion : HTTPVersion
    public var headers : HTTPHeaders
}

public struct HTTPResponse {
    public var httpVersion : HTTPVersion
    public var status: HTTPResponseStatus
    public var transferEncoding: HTTPTransferEncoding
    public var headers: HTTPHeaders
}

public enum Result<POSIXError, Void> {
    case success(())
    case failure(POSIXError)

    // MARK: Constructors
    /// Constructs a success wrapping a `closure`.
    public init(completion: ()) {
        self = .success(completion)
    }

    /// Constructs a failure wrapping an `POSIXError`.
    public init(error: POSIXError) {
        self = .failure(error)
    }
}

public protocol HTTPResponseWriter : class {
    func writeContinue(headers: HTTPHeaders?) /* to send an HTTP `100 Continue` */

    func writeResponse(_ response: HTTPResponse)

    func writeTrailer(key: String, value: String)

    func writeBody(data: DispatchData) /* convenience */
    func writeBody(data: Data) /* convenience */
    func writeBody(data: DispatchData, completion: @escaping (Result<POSIXError, ()>) -> Void)
    func writeBody(data: Data, completion: @escaping (Result<POSIXError, ()>) -> Void)

    func done() /* convenience */
    func done(completion: @escaping (Result<POSIXError, ()>) -> Void)
    func abort()
}

public typealias HTTPBodyHandler = (HTTPBodyChunk, inout Bool) -> Void /* the Bool can be set to true when we don't want to process anything further */

public enum HTTPBodyProcessing {
    case discardBody /* if you're not interested in the body */
    case processBody(handler: HTTPBodyHandler)
}

public enum HTTPBodyChunk {
    case chunk(data: DispatchData, finishedProcessing: () -> Void) /* a new bit of the HTTP request body has arrived, finishedProcessing() must be called when done with that chunk */
    case failed(error: /*HTTPParser*/ Error) /* error while streaming the HTTP request body, eg. connection closed */
    case trailer(key: String, value: String) /* trailer has arrived (this we actually haven't implemented yet) */
    case end /* body and trailers finished */
}

public struct HTTPHeaders {
    var storage: [String:[String]]     /* lower cased keys */
    let original: [(String, String)]   /* original casing */
    let description: String

    subscript(key: String) -> [String] {
        get {
            return storage[key] ?? []
        }
        set (value) {
            storage[key] = value
        }
    }

    func makeIterator() -> IndexingIterator<Array<(String, String)>> {
        return original.makeIterator()
    }

    init(_ headers: [(String, String)] = []) {
        original = headers
        description=""
        storage = [String:[String]]()
    }
}

public typealias HTTPVersion = (Int, Int)

public enum HTTPTransferEncoding {
    case identity(contentLength: UInt)
    case chunked
}

public enum HTTPResponseStatus {
    /* use custom if you want to use a non-standard response code or
     have it available in a (UInt, String) pair from a higher-level web framework. */
    case custom(code: UInt, reasonPhrase: String)

    /* all the codes from http://www.iana.org/assignments/http-status-codes */
    case `continue`
    case switchingProtocols
    case processing
    case ok
    case created
    case accepted
    case nonAuthoritativeInformation
    case noContent
    case resetContent
    case partialContent
    case multiStatus
    case alreadyReported
    case imUsed
    case multipleChoices
    case movedPermanently
    case found
    case seeOther
    case notModified
    case useProxy
    case temporaryRedirect
    case permanentRedirect
    case badRequest
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case proxyAuthenticationRequired
    case requestTimeout
    case conflict
    case gone
    case lengthRequired
    case preconditionFailed
    case payloadTooLarge
    case uriTooLong
    case unsupportedMediaType
    case rangeNotSatisfiable
    case expectationFailed
    case misdirectedRequest
    case unprocessableEntity
    case locked
    case failedDependency
    case upgradeRequired
    case preconditionRequired
    case tooManyRequests
    case requestHeaderFieldsTooLarge
    case unavailableForLegalReasons
    case internalServerError
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported
    case variantAlsoNegotiates
    case insufficientStorage
    case loopDetected
    case notExtended
    case networkAuthenticationRequired
}

extension HTTPResponseStatus {
    public var reasonPhrase: String {
        switch(self) {
        case .custom(_, let reasonPhrase):
            return reasonPhrase
        case .`continue`:
            return "CONTINUE"
        default:
            return String(describing: self)
        }
    }

    public var code: UInt {
        switch(self) {
        case .custom(let code, _):
            return code
        case .`continue`:
            return 100
        case .switchingProtocols:
            return 101
        case .processing:
            return 102
        case .ok:
            return 200
        case .created:
            return 201
        case .accepted:
            return 202
        case .nonAuthoritativeInformation:
            return 203
        case .noContent:
            return 204
        case .resetContent:
            return 205
        case .partialContent:
            return 206
        case .multiStatus:
            return 207
        case .alreadyReported:
            return 208
        case .imUsed:
            return 226
        case .multipleChoices:
            return 300
        case .movedPermanently:
            return 301
        case .found:
            return 302
        case .seeOther:
            return 303
        case .notModified:
            return 304
        case .useProxy:
            return 305
        case .temporaryRedirect:
            return 307
        case .permanentRedirect:
            return 308
        case .badRequest:
            return 400
        case .unauthorized:
            return 401
        case .paymentRequired:
            return 402
        case .forbidden:
            return 403
        case .notFound:
            return 404
        case .methodNotAllowed:
            return 405
        case .notAcceptable:
            return 406
        case .proxyAuthenticationRequired:
            return 407
        case .requestTimeout:
            return 408
        case .conflict:
            return 409
        case .gone:
            return 410
        case .lengthRequired:
            return 411
        case .preconditionFailed:
            return 412
        case .payloadTooLarge:
            return 413
        case .uriTooLong:
            return 414
        case .unsupportedMediaType:
            return 415
        case .rangeNotSatisfiable:
            return 416
        case .expectationFailed:
            return 417
        case .misdirectedRequest:
            return 421
        case .unprocessableEntity:
            return 422
        case .locked:
            return 423
        case .failedDependency:
            return 424
        case .upgradeRequired:
            return 426
        case .preconditionRequired:
            return 428
        case .tooManyRequests:
            return 429
        case .requestHeaderFieldsTooLarge:
            return 431
        case .unavailableForLegalReasons:
            return 451
        case .internalServerError:
            return 500
        case .notImplemented:
            return 501
        case .badGateway:
            return 502
        case .serviceUnavailable:
            return 503
        case .gatewayTimeout:
            return 504
        case .httpVersionNotSupported:
            return 505
        case .variantAlsoNegotiates:
            return 506
        case .insufficientStorage:
            return 507
        case .loopDetected:
            return 508
        case .notExtended:
            return 510
        case .networkAuthenticationRequired:
            return 511
        }
    }
}

public enum HTTPMethod: String {
    // case custom(method: String)
    case UNKNOWN

    /* everything that http_parser.[ch] supports */
    case DELETE
    case GET
    case HEAD
    case POST
    case PUT
    case CONNECT
    case OPTIONS
    case TRACE
    case COPY
    case LOCK
    case MKCOL
    case MOVE
    case PROPFIND
    case PROPPATCH
    case SEARCH
    case UNLOCK
    case BIND
    case REBIND
    case UNBIND
    case ACL
    case REPORT
    case MKACTIVITY
    case CHECKOUT
    case MERGE
    case MSEARCH
    case NOTIFY
    case SUBSCRIBE
    case UNSUBSCRIBE
    case PATCH
    case PURGE
    case MKCALENDAR
    case LINK
    case UNLINK
}
