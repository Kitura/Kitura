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

#if swift(>=4.0)
import TypeSafeContracts

// Type-safe router
// Note: If an exception is thrown from a handler and is bubbled up to the framework,
// Kitura by default returns a notFound error.
// A few references on errors
// https://stackoverflow.com/questions/9381520/what-is-the-appropriate-http-status-code-response-for-a-general-unsuccessful-req
// https://stackoverflow.com/questions/3290182/rest-http-status-codes-for-failed-validation-or-invalid-duplicate
// https://restfulapi.net/http-status-codes/
// https://docs.oracle.com/en/cloud/iaas/messaging-cloud/csmes/rest-api-http-status-codes-and-error-messages-reference.html#GUID-AAB1EE32-BE4A-4ACC-BEAC-ABA85EB41919
extension Router {
    public typealias ResultClosure = (Swift.Error?) -> Void
    public typealias CodableResultClosure<O: Codable> = (O) -> Void
    public typealias CodableArrayResultClosure<O: Codable> = ([O]) -> Void
    public typealias IdentifierCodableClosure<Id: Identifier, I: Codable, O: Codable> = (Id, I, @escaping CodableResultClosure<O>) throws -> Void
    public typealias CodableClosure<I: Codable, O: Codable> = (I, @escaping CodableResultClosure<O>) throws -> Void    
    public typealias NonCodableClosure = (@escaping ResultClosure) throws -> Void
    public typealias IdentifierNonCodableClosure<Id: Identifier> = (Id, @escaping ResultClosure) throws -> Void    
    public typealias CodableArrayClosure<O: Codable> = (@escaping CodableArrayResultClosure<O>) throws -> Void
    public typealias IdentifierSimpleCodableClosure<Id: Identifier, O: Codable> = (Id, @escaping CodableResultClosure<O>) throws -> Void

    // GET
    public func get<O: Codable>(_ route: String, codableHandler: @escaping CodableArrayClosure<O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request")
            // Define result handler            
            let handler: CodableArrayResultClosure<O> = { result in
                do {
                    let encoded = try JSONEncoder().encode(result)
                    response.status(.OK)
                    response.send(data: encoded)
                } catch {
                    // Http 500 error
                    response.status(.internalServerError)
                }
                next()
            }
            // Invoke application handler
            do { 
                try codableHandler(handler)
            } catch {
                response.status(.internalServerError)
                next()
            }            
        }
    }

    // GET single element
    public func get<Id: Identifier, O: Codable>(_ route: String, codableHandler: @escaping IdentifierSimpleCodableClosure<Id, O>) {
        get("\(route)/:id") { request, response, next in
            Log.verbose("Received GET (singular) type-safe request")
            do {
                // Define result handler
                let handler: CodableResultClosure<O> = { result in
                    do {
                        let encoded = try JSONEncoder().encode(result)
                        response.status(.OK)
                        response.send(data: encoded)
                    } catch {
                         // Http 500 error
                        response.status(.internalServerError)
                    }
                    next()
                }
                // Process incoming data from client
                let id = request.parameters["id"] ?? ""
                let identifier = try Id(value: id)
                do { 
                    try codableHandler(identifier, handler)
                } catch {
                    response.status(.internalServerError)
                    next()
                }
            } catch {
                // Http 422 error
                response.status(.unprocessableEntity)
                next()
            }
        }
    }

    // DELETE
    public func delete(_ route: String, codableHandler: @escaping NonCodableClosure) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural) type-safe request")
            // Define result handler   
            let handler: ResultClosure = { error in
                if let _ = error {
                    response.status(.internalServerError)                    
                } else {
                    response.status(.OK)
                }
                next()
            }
            // Invoke application handler
            do { 
                try codableHandler(handler)
            } catch {
                response.status(.internalServerError)
                next()
            }
        }
    }

    // DELETE single element
    public func delete<Id: Identifier>(_ route: String, codableHandler: @escaping IdentifierNonCodableClosure<Id>) {
        delete("\(route)/:id") { request, response, next in
            Log.verbose("Received DELETE (singular) type-safe request")
            let handler: ResultClosure = { error in
                if let _ = error {
                    response.status(.internalServerError)                    
                } else {
                    response.status(.OK)
                }
                next()
            }
            // Process incoming data from client
            do {
                let id = request.parameters["id"] ?? ""
                let identifier = try Id(value: id)
                // Invoke application handler
                do {
                    try codableHandler(identifier, handler)
                } catch {
                    response.status(.internalServerError)
                    next()
                }
            } catch {
                 // Http 422 error
                response.status(.unprocessableEntity)
                next()
            }            
        }
    }

    // PATCH
    public func patch<Id: Identifier, I: Codable, O: Codable>(_ route: String, codableHandler: @escaping IdentifierCodableClosure<Id, I, O>) {
        patch("\(route)/:id") { request, response, next in
            Log.verbose("Received PATCH type-safe request")
            do {
                // Process incoming data from client
                let id = request.parameters["id"] ?? ""
                var data = Data()
                let _ = try request.read(into: &data)
                let param = try JSONDecoder().decode(I.self, from: data)
                let identifier = try Id(value: id)
                // Define handler to process result from application
                let handler: CodableResultClosure<O> = { result in
                    do {
                        let encoded = try JSONEncoder().encode(result)
                        response.status(.OK)
                        response.send(data: encoded)
                    } catch {
                        // Http 500 error
                        response.status(.internalServerError)
                    }
                    next()
                }
                // Invoke application handler
                do { 
                    try codableHandler(identifier, param, handler)
                } catch {
                    response.status(.internalServerError)
                    next()
                }
            } catch {
                // Http 422 error
                response.status(.unprocessableEntity)
                next()
            }
        }
    }
    
    // POST
	public func post<I: Codable, O: Codable>(_ route: String, codableHandler: @escaping CodableClosure<I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            do {
                // Process incoming data from client
                var data = Data()
                let _ = try request.read(into: &data)
                let param = try JSONDecoder().decode(I.self, from: data)
                let handler: CodableResultClosure<O> = { result in
                    do {
                        let encoded = try JSONEncoder().encode(result)
                        response.status(.created)
                        response.send(data: encoded)
                    } catch {
                        // Http 500 error
                        response.status(.internalServerError)
                    }
                    next()
                }
                // Invoke application handler
                do { 
                    try codableHandler(param, handler)
                } catch {
                    response.status(.internalServerError)
                    next()
                }
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
    public func put<Id: Identifier, I: Codable, O: Codable>(_ route: String, codableHandler: @escaping IdentifierCodableClosure<Id, I, O>) {
        put("\(route)/:id") { request, response, next in
            Log.verbose("Received PUT type-safe request")
            do {
                // Process incoming data from client
                let id = request.parameters["id"] ?? ""
                var data = Data()
                let _ = try request.read(into: &data)
                let param = try JSONDecoder().decode(I.self, from: data)
                let identifier = try Id(value: id)
                let handler: CodableResultClosure<O> = { result in
                    do {
                        let encoded = try JSONEncoder().encode(result)
                        response.status(.OK)
                        response.send(data: encoded)
                    } catch {
                        // Http 500 error
                        response.status(.internalServerError)
                    }
                    next()
                }
                // Invoke application handler
                do {
                    try codableHandler(identifier, param, handler)
                 } catch {
                    response.status(.internalServerError)
                    next()
                }
            } catch {
                response.status(.unprocessableEntity)
                next()
            }
        }
    }
}

#endif
