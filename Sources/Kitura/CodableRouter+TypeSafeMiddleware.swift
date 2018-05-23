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
import Dispatch

// Codable router

extension Router {

    // GET returning single Codable
    public func get<T: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping MiddlewareSimpleCodableClosure<T, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Single) typed middleware request")
            self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                guard let typeSafeMiddleware = typeSafeMiddleware else {
                    return next()
                }
                handler(typeSafeMiddleware, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareSimpleCodableClosure<T1, T2, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Single) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareSimpleCodableClosure<T1, T2, T3, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Single) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // GET returning Codable array
    public func get<T: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableArrayClosure<T, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                guard let typeSafeMiddleware = typeSafeMiddleware else {
                    return next()
                }
                handler(typeSafeMiddleware, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableArrayClosure<T1, T2, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableArrayClosure<T1, T2, T3, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // GET with identifier returning single Codable
    public func get<T: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierSimpleCodableClosure<T, Id, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        get(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received GET (singular with identifier and middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                guard let typeSafeMiddleware = typeSafeMiddleware else {
                    return next()
                }
                handler(typeSafeMiddleware, identifier, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierSimpleCodableClosure<T1, T2, Id, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        get(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received GET (singular with identifier and middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, identifier, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierSimpleCodableClosure<T1, T2, T3, Id, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        get(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received GET (singular with identifier and middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, identifier, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // GET with identifier returning Codable array
    public func get<T: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableArrayClosure<T, Id, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) with identifier typed middleware request")
            self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                guard let typeSafeMiddleware = typeSafeMiddleware else {
                    return next()
                }
                handler(typeSafeMiddleware, CodableHelpers.constructTupleArrayOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableArrayClosure<T1, T2, Id, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) with identifier typed middleware request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, CodableHelpers.constructTupleArrayOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableArrayClosure<T1, T2, T3, Id, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) with identifier typed middleware request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, CodableHelpers.constructTupleArrayOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // GET with query parameters returning single Codable
    public func get<T: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T, Q, @escaping CodableResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (singular) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            // Define result handler
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                    guard let typeSafeMiddleware = typeSafeMiddleware else {
                        return next()
                    }
                    handler(typeSafeMiddleware, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping CodableResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (singular) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            // Define result handler
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                    guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                        return next()
                    }
                    handler(typeSafeMiddleware1, typeSafeMiddleware2, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping CodableResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (singular) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            // Define result handler
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                    guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                        return next()
                    }
                    handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // GET with query parameters returning Codable array
    public func get<T: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                    guard let typeSafeMiddleware = typeSafeMiddleware else {
                        return next()
                    }
                    handler(typeSafeMiddleware, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                    guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                        return next()
                    }
                    handler(typeSafeMiddleware1, typeSafeMiddleware2, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                    guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                        return next()
                    }
                    handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }    }
    
    // DELETE
    public func delete<T: TypeSafeMiddleware>(_ route: String, handler: @escaping MiddlewareNonCodableClosure<T>) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural with middleware) type-safe request")
            self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                guard let typeSafeMiddleware = typeSafeMiddleware else {
                    return next()
                }
                handler(typeSafeMiddleware, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware>(_ route: String, handler: @escaping TwoMiddlewareNonCodableClosure<T1, T2>) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural with middleware) type-safe request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware>(_ route: String, handler: @escaping ThreeMiddlewareNonCodableClosure<T1, T2, T3>) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural with middleware) type-safe request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE with identifier
    public func delete<T: TypeSafeMiddleware, Id: Identifier>(_ route: String, handler: @escaping MiddlewareIdentifierNonCodableClosure<T, Id>) {
        if parameterIsPresent(in: route) {
            return
        }
        delete(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received DELETE (singular with middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                guard let typeSafeMiddleware = typeSafeMiddleware else {
                    return next()
                }
                handler(typeSafeMiddleware, identifier, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier>(_ route: String, handler: @escaping TwoMiddlewareIdentifierNonCodableClosure<T1, T2, Id>) {
        if parameterIsPresent(in: route) {
            return
        }
        delete(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received DELETE (singular with middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, identifier, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierNonCodableClosure<T1, T2, T3, Id>) {
        if parameterIsPresent(in: route) {
            return
        }
        delete(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received DELETE (singular with middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, identifier, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE with query parameters
    public func delete<T: TypeSafeMiddleware, Q: QueryParams>(_ route: String, handler: @escaping (T, Q, @escaping ResultClosure) -> Void) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                    guard let typeSafeMiddleware = typeSafeMiddleware else {
                        return next()
                    }
                    handler(typeSafeMiddleware, query, CodableHelpers.constructResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Q: QueryParams>(_ route: String, handler: @escaping (T1, T2, Q, @escaping ResultClosure) -> Void) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                    guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                        return next()
                    }
                    handler(typeSafeMiddleware1, typeSafeMiddleware2, query, CodableHelpers.constructResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Q: QueryParams>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping ResultClosure) -> Void) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                    guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                        return next()
                    }
                    handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, query, CodableHelpers.constructResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // POST
    public func post<T: TypeSafeMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableClosure<T, I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                guard let typeSafeMiddleware = typeSafeMiddleware else {
                    return next()
                }
                handler(typeSafeMiddleware, codableInput, CodableHelpers.constructOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    public func post<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableClosure<T1, T2, I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, codableInput, CodableHelpers.constructOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    public func post<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableClosure<T1, T2, T3, I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, codableInput, CodableHelpers.constructOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // POST with identifier
    public func post<T: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableIdentifierClosure<T, I, Id, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                return next()
            }
            self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                guard let typeSafeMiddleware = typeSafeMiddleware else {
                    return next()
                }
                handler(typeSafeMiddleware, codableInput, CodableHelpers.constructIdentOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    public func post<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableIdentifierClosure<T1, T2, I, Id, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                return next()
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, codableInput, CodableHelpers.constructIdentOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    public func post<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableIdentifierClosure<T1, T2, T3, I, Id, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                return next()
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, codableInput, CodableHelpers.constructIdentOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // PUT with identifier
    public func put<T: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableClosure<T, Id, I, O>) {
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
            self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                guard let typeSafeMiddleware = typeSafeMiddleware else {
                    return next()
                }
                handler(typeSafeMiddleware, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func put<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableClosure<T1, T2, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    public func put<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableClosure<T1, T2, T3, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // PATCH with identifier
    public func patch<T: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableClosure<T, Id, I, O>) {
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
            self.handleMiddleware(T.self, request: request, response: response) { typeSafeMiddleware in
                guard let typeSafeMiddleware = typeSafeMiddleware else {
                    return next()
                }
                handler(typeSafeMiddleware, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                
            }
        }
    }
    
    public func patch<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableClosure<T1, T2, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                
            }
        }
    }
    
    public func patch<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableClosure<T1, T2, T3, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3 in
                guard let typeSafeMiddleware1 = typeSafeMiddleware1, let typeSafeMiddleware2 = typeSafeMiddleware2, let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                    return next()
                }
                handler(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                
            }
        }
    }
    
    // TODO: function copied from CodableRouter. Do we want to make it internal there?
    private func parameterIsPresent(in route: String) -> Bool {
        if route.contains(":") {
            let paramaterString = route.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            let parameter = paramaterString.count > 0 ? paramaterString[1] : ""
            Log.error("Erroneous path '\(route)', parameter ':\(parameter)' is not allowed. Codable routes do not allow parameters.")
            return true
        }
        return false
    }

    private func handleMiddleware<T: TypeSafeMiddleware>(_ middlewareType: T.Type, request: RouterRequest, response: RouterResponse, completion: @escaping (T?) -> Void) {
        T.handle(request: request, response: response) { (typeSafeMiddleware: T?, error: RequestError?) in
            guard let typeSafeMiddleware = typeSafeMiddleware else {
                response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                return completion(nil)
            }
            completion(typeSafeMiddleware)
        }
    }
    
    private func handleMiddleware<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware>(_ middlewareOneType: T1.Type, _ middlewareTwoType: T2.Type, request: RouterRequest, response: RouterResponse, completion: @escaping (T1?, T2?) -> Void) {
        T1.handle(request: request, response: response) { (typeSafeMiddleware1: T1?, error: RequestError?) in
            guard let typeSafeMiddleware1 = typeSafeMiddleware1 else {
                response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                return completion(nil, nil)
            }
            T2.handle(request: request, response: response) { (typeSafeMiddleware2: T2?, error: RequestError?) in
                guard let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                    return completion(typeSafeMiddleware1, nil)
                }
                completion(typeSafeMiddleware1, typeSafeMiddleware2)
            }
        }
    }
    
    private func handleMiddleware<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware>(_ middlewareOneType: T1.Type, _ middlewareTwoType: T2.Type, _ middlewareThreeType: T3.Type, request: RouterRequest, response: RouterResponse, completion: @escaping (T1?, T2?, T3?) -> Void) {
        T1.handle(request: request, response: response) { (typeSafeMiddleware1: T1?, error: RequestError?) in
            guard let typeSafeMiddleware1 = typeSafeMiddleware1 else {
                response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                return completion(nil, nil, nil)
            }
            T2.handle(request: request, response: response) { (typeSafeMiddleware2: T2?, error: RequestError?) in
                guard let typeSafeMiddleware2 = typeSafeMiddleware2 else {
                    response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                    return completion(typeSafeMiddleware1, nil, nil)
                }
                T3.handle(request: request, response: response) { (typeSafeMiddleware3: T3?, error: RequestError?) in
                    guard let typeSafeMiddleware3 = typeSafeMiddleware3 else {
                        response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                        return completion(typeSafeMiddleware1, typeSafeMiddleware2, nil)
                    }
                    completion(typeSafeMiddleware1, typeSafeMiddleware2, typeSafeMiddleware3)
                }
            }
        }
    }
}

