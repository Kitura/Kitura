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

#if swift(>=4.0)
import SafetyContracts

// Type-safe router
// Note: If an exception is thrown from a handler and is bubbled up to the framework,
// Kitura by default returns a notFound error.
// A few references on errors
// https://stackoverflow.com/questions/9381520/what-is-the-appropriate-http-status-code-response-for-a-general-unsuccessful-req
// https://stackoverflow.com/questions/3290182/rest-http-status-codes-for-failed-validation-or-invalid-duplicate
// https://restfulapi.net/http-status-codes/
// https://docs.oracle.com/en/cloud/iaas/messaging-cloud/csmes/rest-api-http-status-codes-and-error-messages-reference.html#GUID-AAB1EE32-BE4A-4ACC-BEAC-ABA85EB41919
extension Router {
    public typealias ResultClosure = (ProcessHandlerError?) -> Void
    public typealias CodableResultClosure<O: Codable> = (O?, ProcessHandlerError?) -> Void
    public typealias CodableArrayResultClosure<O: Codable> = ([O]?, ProcessHandlerError?) -> Void
    public typealias IdentifierCodableClosure<Id: Identifier, I: Codable, O: Codable> = (Id, I, @escaping CodableResultClosure<O>) -> Void
    public typealias CodableClosure<I: Codable, O: Codable> = (I, @escaping CodableResultClosure<O>) -> Void
    public typealias NonCodableClosure = (@escaping ResultClosure) -> Void
    public typealias IdentifierNonCodableClosure<Id: Identifier> = (Id, @escaping ResultClosure) -> Void
    public typealias CodableArrayClosure<O: Codable> = (@escaping CodableArrayResultClosure<O>) -> Void
    public typealias IdentifierSimpleCodableClosure<Id: Identifier, O: Codable> = (Id, @escaping CodableResultClosure<O>) -> Void
    
    // GET
    public func get<O: Codable>(_ route: String, handler: @escaping CodableArrayClosure<O>) {
        getSafely(route, handler: handler)
    }

    // GET single element
    public func get<Id: Identifier, O: Codable>(_ route: String, handler: @escaping IdentifierSimpleCodableClosure<Id, O>) {
        getSafely(route, handler: handler)
    }

    // DELETE
    public func delete(_ route: String, handler: @escaping NonCodableClosure) {
        deleteSafely(route, handler: handler)
    }

    // DELETE single element
    public func delete<Id: Identifier>(_ route: String, handler: @escaping IdentifierNonCodableClosure<Id>) {
        deleteSafely(route, handler: handler)
    }

    // POST
    public func post<I: Codable, O: Codable>(_ route: String, handler: @escaping CodableClosure<I, O>) {
        postSafely(route, handler: handler)
    }

    // PUT with Identifier
    public func put<Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping IdentifierCodableClosure<Id, I, O>) {
        putSafely(route, handler: handler)
    }

    // PATCH
    public func patch<Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping IdentifierCodableClosure<Id, I, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        patch("\(route)/:id") { request, response, next in
            Log.verbose("Received PATCH type-safe request")
            guard self.isContentTypeJson(request) else {
                response.status(.unsupportedMediaType)
                next()
                return
            }
            
            do {
                // Process incoming data from client
                let id = request.parameters["id"] ?? ""
                var data = Data()
                let _ = try request.read(into: &data)
                let param = try JSONDecoder().decode(I.self, from: data)
                let identifier = try Id(value: id)
                // Define handler to process result from application
                let resultHandler: CodableResultClosure<O> = { result, error in
                    do {
                        if let err = error {
                            let status = self.httpStatusCode(from: err)
                            response.status(status)
                        } else {
                            let encoded = try JSONEncoder().encode(result)
                            response.status(.OK)
                            response.send(data: encoded)
                        }
                    } catch {
                        // Http 500 error
                        response.status(.internalServerError)
                    }
                    next()
                }
                // Invoke application handler
                handler(identifier, param, resultHandler)
            } catch {
                // Http 422 error
                response.status(.unprocessableEntity)
                next()
            }
        }
    }

     // POST
    fileprivate func postSafely<I: Codable, O: Codable>(_ route: String, handler: @escaping CodableClosure<I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard self.isContentTypeJson(request) else {
                response.status(.unsupportedMediaType)
                next()
                return
            }
            do {
                // Process incoming data from client
                var data = Data()
                let _ = try request.read(into: &data)
                let param = try JSONDecoder().decode(I.self, from: data)
                let resultHandler: CodableResultClosure<O> = { result, error in
                    do {
                        if let err = error {
                            let status = self.httpStatusCode(from: err)
                            response.status(status)
                        } else {
                            let encoded = try JSONEncoder().encode(result)
                            response.status(.created)
                            response.send(data: encoded)
                        }
                    } catch {
                        // Http 500 error
                        response.status(.internalServerError)
                    }
                    next()
                }
                // Invoke application handler
                handler(param, resultHandler)
            } catch {
                // Http 400 error
                //response.status(.badRequest)
                // Http 422 error
                response.status(.unprocessableEntity)
                next()
            }
        }
    }

     // PUT with Identifier
    fileprivate func putSafely<Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping IdentifierCodableClosure<Id, I, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        put("\(route)/:id") { request, response, next in
            Log.verbose("Received PUT type-safe request")
             guard self.isContentTypeJson(request) else {
                response.status(.unsupportedMediaType)
                next()
                return
            }
            do {
                // Process incoming data from client
                let id = request.parameters["id"] ?? ""
                var data = Data()
                let _ = try request.read(into: &data)
                let param = try JSONDecoder().decode(I.self, from: data)
                let identifier = try Id(value: id)
                let resultHandler: CodableResultClosure<O> = { result, error in
                    do {
                        if let err = error {
                            let status = self.httpStatusCode(from: err)
                            response.status(status)
                        } else {
                            let encoded = try JSONEncoder().encode(result)
                            response.status(.OK)
                            response.send(data: encoded)
                        }
                    } catch {
                        // Http 500 error
                        response.status(.internalServerError)
                    }
                    next()
                }
                // Invoke application handler
                handler(identifier, param, resultHandler)
            } catch {
                response.status(.unprocessableEntity)
                next()
            }
        }
    }

    // Get
    fileprivate func getSafely<O: Codable>(_ route: String, handler: @escaping CodableArrayClosure<O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request")
            // Define result handler
            let resultHandler: CodableArrayResultClosure<O> = { result, error in
                do {
                    if let err = error {
                        let status = self.httpStatusCode(from: err)
                        response.status(status)
                    } else {
                        let encoded = try JSONEncoder().encode(result)
                        response.status(.OK)
                        response.send(data: encoded)
                    }
                } catch {
                    // Http 500 error
                    response.status(.internalServerError)
                }
                next()
            }
            handler(resultHandler)
        }
    }

     // GET single element
    fileprivate func getSafely<Id: Identifier, O: Codable>(_ route: String, handler: @escaping IdentifierSimpleCodableClosure<Id, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        get("\(route)/:id") { request, response, next in
            Log.verbose("Received GET (singular) type-safe request")
            do {
                // Define result handler
                let resultHandler: CodableResultClosure<O> = { result, error in
                    do {
                        if let err = error {
                            let status = self.httpStatusCode(from: err)
                            response.status(status)
                        } else {
                            let encoded = try JSONEncoder().encode(result)
                            response.status(.OK)
                            response.send(data: encoded)
                        }
                    } catch {
                         // Http 500 error
                        response.status(.internalServerError)
                    }
                    next()
                }
                // Process incoming data from client
                let id = request.parameters["id"] ?? ""
                let identifier = try Id(value: id)
                handler(identifier, resultHandler)
            } catch {
                // Http 422 error
                response.status(.unprocessableEntity)
                next()
            }
        }
    }

     // DELETE
    fileprivate func deleteSafely(_ route: String, handler: @escaping NonCodableClosure) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural) type-safe request")
            // Define result handler   
            let resultHandler: ResultClosure = { error in
                if let err = error {
                    let status = self.httpStatusCode(from: err)
                    response.status(status)
                } else {
                    response.status(.OK)
                }
                next()
            }
            handler(resultHandler)
        }
    }

     // DELETE single element
    fileprivate func deleteSafely<Id: Identifier>(_ route: String, handler: @escaping IdentifierNonCodableClosure<Id>) {
        if parameterIsPresent(in: route) {
            return
        }
        delete("\(route)/:id") { request, response, next in
            Log.verbose("Received DELETE (singular) type-safe request")
            let resultHandler: ResultClosure = { error in
                if let err = error {
                    let status = self.httpStatusCode(from: err)
                    response.status(status)
                } else {
                    response.status(.OK)
                }
                next()
            }
            // Process incoming data from client
            do {
                let id = request.parameters["id"] ?? ""
                let identifier = try Id(value: id)
                handler(identifier, resultHandler)
            } catch {
                 // Http 422 error
                response.status(.unprocessableEntity)
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
    
    private func isContentTypeJson(_ request: RouterRequest) -> Bool {
        guard let contentType = request.headers["Content-Type"] else {
            return false
        }
        return (contentType == "application/json")
    }

    private func httpStatusCode(from error: ProcessHandlerError) -> HTTPStatusCode {
        let status: HTTPStatusCode = HTTPStatusCode(rawValue: error.rawValue) ?? .unknown
        return status
    }
}

// For consistency, we have the register method as an
// extension to the Router class.
extension Router {
    // CRUD API type safe routing
    // (URL path and HTTP verb are inferred by the framework)
    public func register<I: Persistable>(api: I.Type) {
        api.registerHandlers(router: self)
        Log.verbose("Registered API: \(api)")
    }
}

// Persistable extension
extension Persistable {
    static func registerHandlers(router: Router) {
        router.postSafely(route, handler: self.create)
        Log.verbose("Registered POST for: \(self)")

        // Register update
        router.putSafely(route, handler: self.update)
        Log.verbose("Registered PUT for: \(self)")

        // Register read ALL
        router.getSafely(route, handler: self.read as Router.CodableArrayClosure)
        Log.verbose("Registered GET for: \(self)")

        // Register read Single
        router.getSafely(route, handler: self.read as Router.IdentifierSimpleCodableClosure)
        Log.verbose("Registered single GET for: \(self)")

        // Register delete all
        router.deleteSafely(route, handler: self.delete as Router.NonCodableClosure)
        Log.verbose("Registered DELETE for: \(self)")

        // Register delete single
        router.deleteSafely(route, handler: self.delete as Router.IdentifierNonCodableClosure)
        Log.verbose("Registered single DELETE for: \(self)")
    }
}

#endif
