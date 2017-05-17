import XCTest
import HeliumLogger

@testable import HTTPSketch

@testable import K2Spike

class K2SpikeTests: XCTestCase {
    func testResponseOK() {
        let request = HTTPRequest(method: .GET, target:"/echo", httpVersion: (1, 1), headers: HTTPHeaders([("X-foo", "bar")]))
        let resolver = TestResponseResolver(request: request, requestBody: Data())
        var router = Router()
        router.add(verb: .GET, path: "/echo", responseCreator: EchoWebApp())
        let coordinator = RequestHandlingCoordinator(router: router)
        resolver.resolveHandler(coordinator.handle)

        XCTAssertNotNil(resolver.response)
        XCTAssertNotNil(resolver.responseBody)
        XCTAssertEqual(HTTPResponseStatus.ok.code, resolver.response?.status.code ?? 0)
    }

    func testEcho() {
        let testString="This is a test"
        let request = HTTPRequest(method: .POST, target:"/echo", httpVersion: (1, 1), headers: HTTPHeaders([("X-foo", "bar")]))
        let resolver = TestResponseResolver(request: request, requestBody: testString.data(using: .utf8)!)
        var router = Router()
        router.add(verb: .POST, path: "/echo", responseCreator: EchoWebApp())
        let coordinator = RequestHandlingCoordinator(router: router)
        resolver.resolveHandler(coordinator.handle)

        XCTAssertNotNil(resolver.response)
        XCTAssertNotNil(resolver.responseBody)
        XCTAssertEqual(HTTPResponseStatus.ok.code, resolver.response?.status.code ?? 0)
        XCTAssertEqual(testString, String(data: resolver.responseBody ?? Data(), encoding: .utf8) ?? "Nil")
    }
    
    func testHello() {
        let request = HTTPRequest(method: .GET, target:"/helloworld", httpVersion: (1, 1), headers: HTTPHeaders([("X-foo", "bar")]))
        let resolver = TestResponseResolver(request: request, requestBody: Data())
        var router = Router()
        router.add(verb: .GET, path: "/helloworld", responseCreator: HelloWorldWebApp())
        let coordinator = RequestHandlingCoordinator(router: router)
        resolver.resolveHandler(coordinator.handle)

        XCTAssertNotNil(resolver.response)
        XCTAssertNotNil(resolver.responseBody)
        XCTAssertEqual(HTTPResponseStatus.ok.code, resolver.response?.status.code ?? 0)
        XCTAssertEqual("Hello, World!", String(data: resolver.responseBody ?? Data(), encoding: .utf8) ?? "Nil")
    }
    
    func testHelloEndToEnd() {
        HeliumLogger.use(.info)
        let receivedExpectation = self.expectation(description: "Received web response \(#function)")
        var router = Router()
        router.add(verb: .GET, path: "/helloworld", responseCreator: HelloWorldWebApp())
        let coordinator = RequestHandlingCoordinator.init(router: router)
        let server = BlueSocketSimpleServer()

        do {
            try server.start(port: 0, webapp: coordinator.handle)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let url = URL(string: "http://localhost:\(server.port)/helloworld")!
            print("Test \(#function) on port \(server.port)")
            let dataTask = session.dataTask(with: url) { (responseBody, rawResponse, error) in
                let response = rawResponse as? HTTPURLResponse
                XCTAssertNil(error, "\(error!.localizedDescription)")
                XCTAssertNotNil(response)
                XCTAssertNotNil(responseBody)
                XCTAssertEqual(Int(HTTPResponseStatus.ok.code), response?.statusCode ?? 0)
                XCTAssertEqual("Hello, World!", String(data: responseBody ?? Data(), encoding: .utf8) ?? "Nil")
                receivedExpectation.fulfill()
            }
            dataTask.resume()
            self.waitForExpectations(timeout: 10) { (error) in
                if let error = error {
                    XCTFail("\(error)")
                }
            }
            server.stop()
        } catch {
            XCTFail("Error listening on port \(0): \(error). Use server.failed(callback:) to handle")
        }
    }
    
    func testRequestEchoEndToEnd() {
        HeliumLogger.use(.info)
        let receivedExpectation = self.expectation(description: "Received web response \(#function)")
        let testString="This is a test"
        var router = Router()
        router.add(verb: .POST, path: "/echo", responseCreator: EchoWebApp())
        let coordinator = RequestHandlingCoordinator(router: router)
        let server = BlueSocketSimpleServer()

        do {
            try server.start(port: 0, webapp: coordinator.handle)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let url = URL(string: "http://localhost:\(server.port)/echo")!
            print("Test \(#function) on port \(server.port)")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = testString.data(using: .utf8)
            request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
            
            let dataTask = session.dataTask(with: request) { (responseBody, rawResponse, error) in
                let response = rawResponse as? HTTPURLResponse
                XCTAssertNil(error, "\(error!.localizedDescription)")
                XCTAssertNotNil(response)
                XCTAssertNotNil(responseBody)
                XCTAssertEqual(Int(HTTPResponseStatus.ok.code), response?.statusCode ?? 0)
                XCTAssertEqual(testString, String(data: responseBody ?? Data(), encoding: .utf8) ?? "Nil")
                receivedExpectation.fulfill()
            }
            dataTask.resume()
            self.waitForExpectations(timeout: 10) { (error) in
                if let error = error {
                    XCTFail("\(error)")
                }
            }
            server.stop()
        } catch {
            XCTFail("Error listening on port \(0): \(error). Use server.failed(callback:) to handle")
        }
    }
    
    func testRequestKeepAliveEchoEndToEnd() {
        HeliumLogger.use(.info)
        let receivedExpectation1 = self.expectation(description: "Received web response 1: \(#function)")
        let receivedExpectation2 = self.expectation(description: "Received web response 2: \(#function)")
        let receivedExpectation3 = self.expectation(description: "Received web response 3: \(#function)")
        let testString1="This is a test"
        let testString2="This is a test, too"
        let testString3="This is also a test"
        var router = Router()
        router.add(verb: .POST, path: "/echo", responseCreator: EchoWebApp())
        let coordinator = RequestHandlingCoordinator(router: router)
        let server = BlueSocketSimpleServer()

        do {
            try server.start(port: 0, webapp: coordinator.handle)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let url = URL(string: "http://localhost:\(server.port)/echo")!
            print("Test \(#function) on port \(server.port)")
            var request1 = URLRequest(url: url)
            request1.httpMethod = "POST"
            request1.httpBody = testString1.data(using: .utf8)
            request1.setValue("text/plain", forHTTPHeaderField: "Content-Type")
            
            let dataTask1 = session.dataTask(with: request1) { (responseBody, rawResponse, error) in
                let response = rawResponse as? HTTPURLResponse
                XCTAssertNil(error, "\(error!.localizedDescription)")
                XCTAssertNotNil(response)
                let headers = response?.allHeaderFields ?? ["":""]
                let connectionHeader: String = headers["Connection"] as? String ?? ""
                let keepAliveHeader = headers["Keep-Alive"]
                XCTAssertEqual(connectionHeader,"Keep-Alive","No Keep-Alive Connection")
                XCTAssertNotNil(keepAliveHeader)
                XCTAssertNotNil(responseBody,"No Keep-Alive Header")
                XCTAssertEqual(server.connectionCount, 1)
                XCTAssertEqual(Int(HTTPResponseStatus.ok.code), response?.statusCode ?? 0)
                XCTAssertEqual(testString1, String(data: responseBody ?? Data(), encoding: .utf8) ?? "Nil")
                var request2 = URLRequest(url: url)
                request2.httpMethod = "POST"
                request2.httpBody = testString2.data(using: .utf8)
                request2.setValue("text/plain", forHTTPHeaderField: "Content-Type")
                let dataTask2 = session.dataTask(with: request2) { (responseBody2, rawResponse2, error2) in
                    let response2 = rawResponse2 as? HTTPURLResponse
                    XCTAssertNil(error2, "\(error2!.localizedDescription)")
                    XCTAssertNotNil(response2)
                    let headers = response2?.allHeaderFields ?? ["":""]
                    let connectionHeader: String = headers["Connection"] as? String ?? ""
                    let keepAliveHeader = headers["Keep-Alive"]
                    XCTAssertEqual(connectionHeader,"Keep-Alive","No Keep-Alive Connection")
                    XCTAssertNotNil(keepAliveHeader,"No Keep-Alive Header")
                    XCTAssertEqual(server.connectionCount, 1)
                    XCTAssertNotNil(responseBody2)
                    XCTAssertEqual(Int(HTTPResponseStatus.ok.code), response2?.statusCode ?? 0)
                    XCTAssertEqual(testString2, String(data: responseBody2 ?? Data(), encoding: .utf8) ?? "Nil")
                    var request3 = URLRequest(url: url)
                    request3.httpMethod = "POST"
                    request3.httpBody = testString3.data(using: .utf8)
                    request3.setValue("text/plain", forHTTPHeaderField: "Content-Type")
                    let dataTask3 = session.dataTask(with: request3) { (responseBody, rawResponse, error) in
                        let response = rawResponse as? HTTPURLResponse
                        XCTAssertNil(error, "\(error!.localizedDescription)")
                        XCTAssertNotNil(response)
                        let headers = response?.allHeaderFields ?? ["":""]
                        let connectionHeader: String = headers["Connection"] as? String ?? ""
                        let keepAliveHeader = headers["Keep-Alive"]
                        XCTAssertEqual(connectionHeader,"Keep-Alive","No Keep-Alive Connection")
                        XCTAssertNotNil(keepAliveHeader,"No Keep-Alive Header")
                        XCTAssertEqual(server.connectionCount, 1)
                        XCTAssertNotNil(responseBody)
                        XCTAssertEqual(Int(HTTPResponseStatus.ok.code), response?.statusCode ?? 0)
                        XCTAssertEqual(testString3, String(data: responseBody ?? Data(), encoding: .utf8) ?? "Nil")
                        receivedExpectation3.fulfill()
                    }
                    dataTask3.resume()
                    receivedExpectation2.fulfill()
                }
                dataTask2.resume()
                receivedExpectation1.fulfill()
            }
            dataTask1.resume()

            self.waitForExpectations(timeout: 10) { (error) in
                if let error = error {
                    XCTFail("\(error)")
                }
            }
            //server.stop()
        } catch {
            XCTFail("Error listening on port \(0): \(error). Use server.failed(callback:) to handle")
        }
    }


    func testRequestLargeEchoEndToEnd() {
        HeliumLogger.use(.info)
        let receivedExpectation = self.expectation(description: "Received web response \(#function)")
        //Get a file we know exists
        //let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let executableUrl = URL(fileURLWithPath: CommandLine.arguments[0])
        
        let testExecutableData = try! Data(contentsOf: executableUrl)
        
        var testDataLong = testExecutableData + testExecutableData + testExecutableData + testExecutableData
        let length = testDataLong.count
        let keep = 16385
        let remove = length - keep
        if (remove > 0) {
            testDataLong.removeLast(remove)
        }
        
        let testData = Data(testDataLong)
        var router = Router()
        router.add(verb: .POST, path: "/echo", responseCreator: EchoWebApp())
        let coordinator = RequestHandlingCoordinator(router: router)
        let server = BlueSocketSimpleServer()

        do {
            try server.start(port: 0, webapp: coordinator.handle)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let url = URL(string: "http://localhost:\(server.port)/echo")!
            print("Test \(#function) on port \(server.port)")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = testData
            let dataTask = session.dataTask(with: request) { (responseBody, rawResponse, error) in
                let response = rawResponse as? HTTPURLResponse
                XCTAssertNil(error, "\(error!.localizedDescription)")
                XCTAssertNotNil(response)
                XCTAssertNotNil(responseBody)
                XCTAssertEqual(Int(HTTPResponseStatus.ok.code), response?.statusCode ?? 0)
                XCTAssertEqual(testData, responseBody ?? Data())
                receivedExpectation.fulfill()
            }
            dataTask.resume()
            self.waitForExpectations(timeout: 10) { (error) in
                if let error = error {
                    XCTFail("\(error)")
                }
            }
            server.stop()
        } catch {
            XCTFail("Error listening on port \(0): \(error). Use server.failed(callback:) to handle")
        }
    }

    func testWithCookieHelloEndToEnd() {
        HeliumLogger.use(.info)
        let receivedExpectation = self.expectation(description: "Received web response \(#function)")
        var router = Router()
        router.add(verb: .GET, path: "/helloworld", responseCreator: HelloWorldWebApp())
        let helloWorldCoordinator = RequestHandlingCoordinator(router: router)
        router = Router()
        router.add(verb: .GET, path: "/uuid", responseCreator: UUIDGeneratorWebApp())
        let uuidCoordinator = RequestHandlingCoordinator(router: router)
        
        let helloWorldServer = BlueSocketSimpleServer()
        let uuidServer = BlueSocketSimpleServer()
        do {
            try uuidServer.start(port: 0, webapp: uuidCoordinator.handle)
            let urlForUUID = URL(string: "http://localhost:\(uuidServer.port)/uuid")!
            //let urlForUUID = URL(string: "https://www.uuidgenerator.net/api/version4")! //To test via remote server
            let badCookieHandler = BadCookieWritingMiddleware(cookieName: "OurCookie",urlForUUIDFetch:urlForUUID)
            
            helloWorldCoordinator.addPreProcessor(badCookieHandler.preProcess)
            helloWorldCoordinator.addPostProcessor(badCookieHandler.postProcess)

            try helloWorldServer.start(port: 0, webapp: helloWorldCoordinator.handle)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let urlForHelloWorld = URL(string: "http://localhost:\(helloWorldServer.port)/helloworld")!

            print("Test \(#function) on port \(helloWorldServer.port) with uuid server on port \(uuidServer.port)")
            //print("Test \(#function) on port \(helloWorldServer.port)")
            
            let dataTask = session.dataTask(with: urlForHelloWorld) { (responseBody, rawResponse, error) in
                let response = rawResponse as? HTTPURLResponse
                XCTAssertNil(error, "\(error!.localizedDescription)")
                XCTAssertNotNil(response)
                XCTAssertNotNil(responseBody)
                XCTAssertEqual(Int(HTTPResponseStatus.ok.code), response?.statusCode ?? 0)
                XCTAssertEqual("Hello, World!", String(data: responseBody ?? Data(), encoding: .utf8) ?? "Nil")
                #if os(Linux)
                    //print("\(response!.allHeaderFields.debugDescription)")
                    XCTAssertNotNil(response?.allHeaderFields["Set-Cookie"])
                    let ourCookie = response?.allHeaderFields["Set-Cookie"] as? String
                    let ourCookieString = ourCookie ?? ""
                    let index = ourCookieString.index(ourCookieString.startIndex, offsetBy: 10)
                    XCTAssertTrue(ourCookieString.substring(to: index) == "OurCookie=")
                #else
                    let fields = response?.allHeaderFields as? [String : String] ?? [:]
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: urlForHelloWorld)
                    XCTAssertNotNil(cookies)
                    print("\(cookies.debugDescription)")
                    var ourCookie: HTTPCookie? = nil
                    var missingCookie: HTTPCookie? = nil //We should not find this
                    for cookie in cookies {
                        if cookie.name == "OurCookie" {
                            ourCookie = cookie
                        }
                        if cookie.name == "MissingCookie" {
                            missingCookie = cookie
                        }
                    }
                    
                    XCTAssertNotNil(ourCookie)
                    XCTAssertNil(missingCookie)
                #endif
                receivedExpectation.fulfill()
            }
            dataTask.resume()
            self.waitForExpectations(timeout: 30) { (error) in
                if let error = error {
                    XCTFail("\(error)")
                }
            }
            helloWorldServer.stop()
            uuidServer.stop()
        } catch {
            XCTFail("Error listening on port \(0): \(error). Use server.failed(callback:) to handle")
        }
    }
    
    static var allTests = [
        ("testEcho", testEcho),
        ("testHello", testHello),
        ("testResponseOK", testResponseOK),
        ("testHelloEndToEnd", testHelloEndToEnd),
        ("testRequestEchoEndToEnd", testRequestEchoEndToEnd),
        ("testRequestKeepAliveEchoEndToEnd", testRequestKeepAliveEchoEndToEnd),
        ("testRequestLargeEchoEndToEnd", testRequestLargeEchoEndToEnd),
        ("testWithCookieHelloEndToEnd", testWithCookieHelloEndToEnd),
        ]
}
