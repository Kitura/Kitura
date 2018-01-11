/*
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import LoggerAPI
import KituraNet
import KituraContracts

// Codable router

extension Router {

    // MARK: Codable Routing

    /**
     Setup a CodableArrayClosure on the provided route which will be invoked when a request comes to the server.

     ### Usage Example: ###
     ````
     //User is a struct object that conforms to Codable
     router.get("/users") { (respondWith: ([User]?, RequestError?) -> Void) in

        ...

        respondWith(users, nil)
     }
     ````
     - Parameter route: A String specifying the pattern that needs to be matched, in order for the handler to be invoked.
     - Parameter handler: A CodableArrayClosure that gets invoked when a request comes to the server.
     */
    public func get<O: Codable>(_ route: String, handler: @escaping CodableArrayClosure<O>) {
        getSafely(route, handler: handler)
    }

    /**
     Setup a SimpleCodableClosure on the provided route which will be invoked when a request comes to the server.

     ### Usage Example: ###
     ````
     //Status is a struct object that conforms to Codable
     router.get("/status") { (respondWith: (Status?, RequestError?) -> Void) in

        ...

        respondWith(status, nil)
     }
     ````
     - Parameter route: A String specifying the pattern that needs to be matched, in order for the handler to be invoked.
     - Parameter handler: A SimpleCodableClosure that gets invoked when a request comes to the server.
     */
    public func get<O: Codable>(_ route: String, handler: @escaping SimpleCodableClosure<O>) {
        getSafely(route, handler: handler)
    }

    /**
     Setup a IdentifierSimpleCodableClosure on the provided route which will be invoked when a request comes to the server.

     ### Usage Example: ###
     ````
     //User is a struct object that conforms to Codable
     router.get("/users") { (id: Int, respondWith: (User?, RequestError?) -> Void) in

        ...

        respondWith(user, nil)
     }
     ````
     - Parameter route: A String specifying the pattern that needs to be matched, in order for the handler to be invoked.
     - Parameter handler: An IdentifierSimpleCodableClosure that gets invoked when a request comes to the server.
     */
    public func get<Id: Identifier, O: Codable>(_ route: String, handler: @escaping IdentifierSimpleCodableClosure<Id, O>) {
        getSafely(route, handler: handler)
    }

    /**
     Setup a (QueryParams, CodableArrayResultClosure) -> Void on the provided route which will be invoked when a request comes to the server.

     ### Usage Example: ###
     ````
     // MyQuery is a codable struct defining the supported query parameters
     // User is a struct object that conforms to Codable
     router.get("/query") { (query: MyQuery, respondWith: ([User]?, RequestError?) -> Void) in

        ...

        respondWith(users, nil)
     }
     ````
     - Parameter route: A String specifying the pattern that needs to be matched, in order for the handler to be invoked.
     - Parameter handler: A (QueryParams, CodableArrayResultClosure) -> Void that gets invoked when a request comes to the server.
     */
    public func get<Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }

    /**
     Setup a NonCodableClosure on the provided route which will be invoked when a request comes to the server.

     ### Usage Example: ###
     ````
     router.delete("/users") { (respondWith: (RequestError?) -> Void) in

        ...

        respondWith(nil)
     }
     ````
     - Parameter route: A String specifying the pattern that needs to be matched, in order for the handler to be invoked.
     - Parameter handler: An NonCodableClosure that gets invoked when a request comes to the server.
     */
    public func delete(_ route: String, handler: @escaping NonCodableClosure) {
        deleteSafely(route, handler: handler)
    }

    /**
     Setup a IdentifierNonCodableClosure on the provided route which will be invoked when a request comes to the server.

     ### Usage Example: ###
     ````
     router.delete("/users") { (id: Int, respondWith: (RequestError?) -> Void) in

        ...

        respondWith(nil)
     }
     ````
     - Parameter route: A String specifying the pattern that needs to be matched, in order for the handler to be invoked.
     - Parameter handler: An IdentifierNonCodableClosure that gets invoked when a request comes to the server.
     */
    public func delete<Id: Identifier>(_ route: String, handler: @escaping IdentifierNonCodableClosure<Id>) {
        deleteSafely(route, handler: handler)
    }

    /**
     Setup a (QueryParams, ResultClosure) -> Void on the provided route which will be invoked when a request comes to the server.

     ### Usage Example: ###
     ````
     // MyQuery is a codable struct defining the supported query parameters
     router.delete("/query") { (query: MyQuery, respondWith: (RequestError?) -> Void) in

     ...

     respondWith(nil)
     }
     ````
     - Parameter route: A String specifying the pattern that needs to be matched, in order for the handler to be invoked.
     - Parameter handler: A (QueryParams, ResultClosure) -> Void that gets invoked when a request comes to the server.
     */
    public func delete<Q: QueryParams>(_ route: String, handler: @escaping (Q, @escaping ResultClosure) -> Void) {
        deleteSafely(route, handler: handler)
    }

    /**
     Setup a CodableClosure on the provided route which will be invoked when a POST request comes to the server.
     In this scenario, the ID (i.e. unique identifier) is a field in the Codable instance.

     ### Usage Example: ###
     ````
     //User is a struct object that conforms to Codable
     router.post("/users") { (user: User, respondWith: (User?, RequestError?) -> Void) in

        ...

        respondWith(user, nil)
     }
     ````
     - Parameter route: A String specifying the pattern that needs to be matched, in order for the handler to be invoked.
     - Parameter handler: A Codable closure that gets invoked when a request comes to the server.
    */
    public func post<I: Codable, O: Codable>(_ route: String, handler: @escaping CodableClosure<I, O>) {
        postSafely(route, handler: handler)
    }

    /**
     Setup a CodableIdentifierClosure on the provided route which will be invoked when a POST request comes to the server.
     In this scenario, the ID (i.e. unique identifier) for the Codable instance is a separate field (which is sent back to the client
     in the location HTTP header).

     ### Usage Example: ###
     ````
     //User is a struct object that conforms to Codable
     router.post("/users") { (user: User, respondWith: (Int?, User?, RequestError?) -> Void) in

        ...

        respondWith(id, user, nil)
     }
     ````
     - Parameter route: A String specifying the pattern that needs to be matched, in order for the handler to be invoked.
     - Parameter handler: A Codable closure that gets invoked when a request comes to the server.
    */
    public func post<I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping CodableIdentifierClosure<I, Id, O>) {
        postSafelyWithId(route, handler: handler)
    }

    /**
     Setup a IdentifierCodableClosure on the provided route which will be invoked when a request comes to the server.

     ### Usage Example: ###
     ````
     //User is a struct object that conforms to Codable
     router.put("/users") { (id: Int, user: User, respondWith: (User?, RequestError?) -> Void) in

        ...

        respondWith(user, nil)
     }
     ````
     - Parameter route: A String specifying the pattern that needs to be matched, in order for the handler to be invoked.
     - Parameter handler: An Identifier Codable closure that gets invoked when a request comes to the server.
     */
    public func put<Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping IdentifierCodableClosure<Id, I, O>) {
        putSafely(route, handler: handler)
    }

    /**
     Setup a IdentifierCodableClosure on the provided route which will be invoked when a request comes to the server.

     ### Usage Example: ###
     ````
     //User is a struct object that conforms to Codable
     //OptionalUser is a struct object that conforms to Codable where all properties are optional
     router.patch("/users") { (id: Int, patchUser: OptionalUser, respondWith: (User?, RequestError?) -> Void) -> Void in

        ...

        respondWith(user, nil)
     }
     ````
     - Parameter route: A String specifying the pattern that needs to be matched, in order for the handler to be invoked.
     - Parameter handler: An Identifier Codable closure that gets invoked when a request comes to the server.
     */
    public func patch<Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping IdentifierCodableClosure<Id, I, O>) {
        patchSafely(route, handler: handler)
    }

    // POST
    fileprivate func postSafely<I: Codable, O: Codable>(_ route: String, handler: @escaping CodableClosure<I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            handler(codableInput, CodableHelpers.constructOutResultHandler(successStatus: .created, response: response, completion: next))
        }
    }

    // POST
    fileprivate func postSafelyWithId<I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping CodableIdentifierClosure<I, Id, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            handler(codableInput, CodableHelpers.constructIdentOutResultHandler(successStatus: .created, response: response, completion: next))
        }
    }

    // PUT with Identifier
    fileprivate func putSafely<Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping IdentifierCodableClosure<Id, I, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        put(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received PUT type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response),
                  let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response)
            else {
                next()
                return
            }
            handler(identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
        }
    }

    // PATCH
    fileprivate func patchSafely<Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping IdentifierCodableClosure<Id, I, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        patch(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received PATCH type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response),
                  let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response)
            else {
                next()
                return
            }
            handler(identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
        }
    }

    // Get single
    fileprivate func getSafely<O: Codable>(_ route: String, handler: @escaping SimpleCodableClosure<O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET (single no-identifier) type-safe request")
            handler(CodableHelpers.constructOutResultHandler(response: response, completion: next))
        }
    }

    // Get array
    fileprivate func getSafely<O: Codable>(_ route: String, handler: @escaping CodableArrayClosure<O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request")
            handler(CodableHelpers.constructOutResultHandler(response: response, completion: next))
        }
    }

    // Get w/Query Parameters
    fileprivate func getSafely<Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request with Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                handler(query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }

    // GET single identified element
    fileprivate func getSafely<Id: Identifier, O: Codable>(_ route: String, handler: @escaping IdentifierSimpleCodableClosure<Id, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        get(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received GET (singular with identifier) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            handler(identifier, CodableHelpers.constructOutResultHandler(response: response, completion: next))
        }
    }

    // DELETE
    fileprivate func deleteSafely(_ route: String, handler: @escaping NonCodableClosure) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural) type-safe request")
            handler(CodableHelpers.constructResultHandler(response: response, completion: next))
        }
    }

    // DELETE single element
    fileprivate func deleteSafely<Id: Identifier>(_ route: String, handler: @escaping IdentifierNonCodableClosure<Id>) {
        if parameterIsPresent(in: route) {
            return
        }
        delete(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received DELETE (singular) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            handler(identifier, CodableHelpers.constructResultHandler(response: response, completion: next))
        }
    }

    // DELETE w/Query Parameters
    fileprivate func deleteSafely<Q: Codable>(_ route: String, handler: @escaping (Q, @escaping ResultClosure) -> Void) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE type-safe request with Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                handler(query, CodableHelpers.constructResultHandler(response: response, completion: next))
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }

    private func parameterIsPresent(in route: String) -> Bool {
        if route.contains(":") {
            let paramaterString = route.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            let parameter = paramaterString.count > 0 ? paramaterString[1] : ""
            Log.error("Erroneous path '\(route)', parameter ':\(parameter)' is not allowed. Codable routes do not allow parameters.")
            return true
        }
        return false
    }

    internal func join(path base: String, with component: String) -> String {
        let strippedBase = base.hasSuffix("/") ? String(base.dropLast()) : base
        let strippedComponent = component.hasPrefix("/") ? String(component.dropFirst()) : component
        return "\(strippedBase)/\(strippedComponent)"
    }
}

//
// Building blocks for Codable routing
//
public struct CodableHelpers {
    public static func isContentTypeJSON(_ request: RouterRequest) -> Bool {
        guard let contentType = request.headers["Content-Type"] else {
            return false
        }
        return contentType.hasPrefix("application/json")
    }

    public static func httpStatusCode(from error: RequestError) -> HTTPStatusCode {
        return HTTPStatusCode(rawValue: error.rawValue) ?? HTTPStatusCode.unknown
    }

    public static func constructResultHandler(response: RouterResponse, completion: @escaping () -> Void) -> ResultClosure {
        return { error in
            if let error = error {
                response.status(httpStatusCode(from: error))
                do {
                    if let bodyData = try error.encodeBody(.json) {
                        response.headers.setType("json")
                        response.send(data: bodyData)
                    }
                } catch {
                    Log.error("Could not encode error: \(error)")
                    response.status(.internalServerError)
                }
            } else {
                response.status(.noContent)
            }
            completion()
        }
    }

    public static func constructOutResultHandler<OutputType: Codable>(successStatus: HTTPStatusCode = .OK, response: RouterResponse, completion: @escaping () -> Void) -> CodableResultClosure<OutputType> {
        return { codableOutput, error in
            if let error = error {
                response.status(httpStatusCode(from: error))
                do {
                    if let bodyData = try error.encodeBody(.json) {
                        response.headers.setType("json")
                        response.send(data: bodyData)
                    }
                } catch {
                    Log.error("Could not encode error: \(error)")
                    response.status(.internalServerError)
                }
            } else {
                do {
                    let json = try JSONEncoder().encode(codableOutput)
                    response.headers.setType("json")
                    response.send(data: json)
                    response.status(successStatus)
                } catch {
                    Log.error("Could not encode result: \(error)")
                    response.status(.internalServerError)
                }
            }
            completion()
        }
    }

    public static func constructIdentOutResultHandler<IdType: Identifier, OutputType: Codable>(successStatus: HTTPStatusCode = .OK, response: RouterResponse, completion: @escaping () -> Void) -> IdentifierCodableResultClosure<IdType, OutputType> {
        return { id, codableOutput, error in
            if let error = error {
                response.status(CodableHelpers.httpStatusCode(from: error))
                do {
                    if let bodyData = try error.encodeBody(.json) {
                        response.headers.setType("json")
                        response.send(data: bodyData)
                    }
                } catch {
                    Log.error("Could not encode error: \(error)")
                    response.status(.internalServerError)
                }
            } else if let id = id {
                response.headers["Location"] = String(id.value)
                do {
                    let json = try JSONEncoder().encode(codableOutput)
                    response.headers.setType("json")
                    response.send(data: json)
                    response.status(successStatus)
                } catch {
                    Log.error("Could not encode result: \(error)")
                    response.status(.internalServerError)
                }
            } else {
                Log.error("No id (unique identifier) value provided.")
                response.status(.internalServerError)
            }
            completion()
        }
    }

    public static func readCodableOrSetResponseStatus<InputType: Codable>(_ inputCodableType: InputType.Type, from request: RouterRequest, response: RouterResponse) -> InputType? {
        guard CodableHelpers.isContentTypeJSON(request) else {
            response.status(.unsupportedMediaType)
            return nil
        }
        guard !request.hasBodyParserBeenUsed else {
            Log.error("No data in request. Codable routes do not allow the use of BodyParser.")
            response.status(.internalServerError)
            return nil
        }
        do {
            return try request.read(as: InputType.self)
        } catch {
            Log.error("Failed to read Codable input from request: \(error)")
            response.status(.unprocessableEntity)
            return nil
        }
    }

    public static func parseIdOrSetResponseStatus<IdType: Identifier>(_ idType: IdType.Type, from request: RouterRequest, response: RouterResponse) -> IdType? {
        guard let idParameter = request.parameters["id"],
              let id = try? IdType(value: idParameter)
        else {
            // TODO: Should this be .notFound?
            response.status(.unprocessableEntity)
            return nil
        }
        return id
    }
}

//extension Router {
//    // CRUD API codable routing
//    // (URL path and HTTP verb are inferred by the framework)
//    public func register<I: Persistable>(api: I.Type) {
//        api.registerHandlers(router: self)
//        Log.verbose("Registered API: \(api)")
//    }
//}

// Persistable extension
//extension Persistable {
//    static func registerHandlers(router: Router) {
//        router.postSafely(route, handler: self.create)
//        Log.verbose("Registered POST for: \(self)")
//
//        // Register update
//        router.putSafely(route, handler: self.update)
//        Log.verbose("Registered PUT for: \(self)")
//
//        // Register read ALL
//        router.getSafely(route, handler: self.read as Router.CodableArrayClosure)
//        Log.verbose("Registered GET for: \(self)")
//
//        // Register read Single
//        router.getSafely(route, handler: self.read as Router.IdentifierSimpleCodableClosure)
//        Log.verbose("Registered single GET for: \(self)")
//
//        // Register delete all
//        router.deleteSafely(route, handler: self.delete as Router.NonCodableClosure)
//        Log.verbose("Registered DELETE for: \(self)")
//
//        // Register delete single
//        router.deleteSafely(route, handler: self.delete as Router.IdentifierNonCodableClosure)
//        Log.verbose("Registered single DELETE for: \(self)")
//    }
//}
