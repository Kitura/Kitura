import XCTest
@testable import SwiftServerHttp
@testable import K2Spike

class ParameterParsingTests: XCTestCase {
    static var allTests = [
        ("testBodylessParameterParsing", testBodylessParameterParsing),
        ]

    func testBodylessParameterParsing() {
        let request = HTTPRequest(method: .GET, target: "/world?hello=world", httpVersion: (1, 1), headers: HTTPHeaders([("hello", "world")]))
        let resolver = TestResponseResolver(request: request, requestBody: Data())
        var router = Router()
        router.add(verb: .GET, path: "/{hello}", parameterType: NoBodyParameters.self, responseCreator: NoBodyResponse())
        let coordinator = RequestHandlingCoordinator(router: router)

        _ = coordinator.handle(req: request, res: resolver)
    }
}

struct NoBodyParameters: BodylessParameterContaining {
    let headerParam: [String]
    let pathParam: String
    let queryParam: [URLQueryItem]

    init?(pathParameters: [String : String]?, queryParameters: [URLQueryItem]?, headers: HTTPHeaders) {
        guard let pathParam = pathParameters?["hello"],
            let queryParam = queryParameters?.filter({ $0.name == "hello" }) else {
            return nil
        }

        self.pathParam = pathParam
        self.headerParam = headers["hello"]
        self.queryParam = queryParam
    }
}

struct NoBodyResponse: BodylessParameterResponseCreating {
    func serve(request: HTTPRequest, context: RequestContext, parameters: BodylessParameterContaining, response: HTTPResponseWriter) -> HTTPBodyProcessing {
        guard let parameters = parameters as? NoBodyParameters else {
            XCTFail("Wrong parameter type")
            return .discardBody
        }

        XCTAssert(parameters.headerParam.count == 1)
        XCTAssert(parameters.headerParam[0] == "world")
        XCTAssert(parameters.pathParam == "world")
        XCTAssert(parameters.queryParam.count == 1)
        XCTAssert(parameters.queryParam[0].value == "world")

        return .discardBody
    }
}
