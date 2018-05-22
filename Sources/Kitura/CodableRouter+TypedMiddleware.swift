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

    // Used by PUT and PATCH with identifier
    public typealias MiddlewareIdentifierCodableClosure<T: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable> = (T, Id, I, @escaping CodableResultClosure<O>) -> Void
    
    public typealias TwoMiddlewareIdentifierCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable> = (T1, T2, Id, I, @escaping CodableResultClosure<O>) -> Void
    
    public typealias ThreeMiddlewareIdentifierCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable> = (T1, T2, T3, Id, I, @escaping CodableResultClosure<O>) -> Void
    
    // Used by POST
    public typealias MiddlewareCodableClosure<T: TypeSafeMiddleware, I: Codable, O: Codable> = (T, I, @escaping CodableResultClosure<O>) -> Void
    
    public typealias TwoMiddlewareCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, I: Codable, O: Codable> = (T1, T2, I, @escaping CodableResultClosure<O>) -> Void
    
    public typealias ThreeMiddlewareCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, I: Codable, O: Codable> = (T1, T2, T3, I, @escaping CodableResultClosure<O>) -> Void

    // Used by POST with identifier
    public typealias MiddlewareCodableIdentifierClosure<T: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable> = (T, I, @escaping IdentifierCodableResultClosure<Id, O>) -> Void
    
    public typealias TwoMiddlewareCodableIdentifierClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable> = (T1, T2, I, @escaping IdentifierCodableResultClosure<Id, O>) -> Void
    
    public typealias ThreeMiddlewareCodableIdentifierClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable> = (T1, T2, T3, I, @escaping IdentifierCodableResultClosure<Id, O>) -> Void
    
    // Used by DELETE
    public typealias MiddlewareNonCodableClosure<T: TypeSafeMiddleware> = (T, @escaping ResultClosure) -> Void

    public typealias TwoMiddlewareNonCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware> = (T1, T2, @escaping ResultClosure) -> Void

    public typealias ThreeMiddlewareNonCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware> = (T1, T2, T3, @escaping ResultClosure) -> Void

    // Used by DELETE with identifier
    public typealias MiddlewareIdentifierNonCodableClosure<T: TypeSafeMiddleware, Id: Identifier> = (T, Id, @escaping ResultClosure) -> Void

    public typealias TwoMiddlewareIdentifierNonCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier> = (T1, T2, Id, @escaping ResultClosure) -> Void

    public typealias ThreeMiddlewareIdentifierNonCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier> = (T1, T2, T3, Id, @escaping ResultClosure) -> Void

    // Used by GET returning array
    public typealias MiddlewareCodableArrayClosure<T: TypeSafeMiddleware, O: Codable> = (T, @escaping CodableArrayResultClosure<O>) -> Void
    
    public typealias TwoMiddlewareCodableArrayClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, O: Codable> = (T1, T2, @escaping CodableArrayResultClosure<O>) -> Void

    public typealias ThreeMiddlewareCodableArrayClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, O: Codable> = (T1, T2, T3, @escaping CodableArrayResultClosure<O>) -> Void

    // Used by GET with identifier returning array
    public typealias MiddlewareIdentifierCodableArrayClosure<T: TypeSafeMiddleware, Id: Identifier, O: Codable> = (T, @escaping IdentifierCodableArrayResultClosure<Id, O>) -> Void
    
    public typealias TwoMiddlewareIdentifierCodableArrayClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, O: Codable> = (T1, T2, @escaping IdentifierCodableArrayResultClosure<Id, O>) -> Void

    public typealias ThreeMiddlewareIdentifierCodableArrayClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, O: Codable> = (T1, T2, T3, @escaping IdentifierCodableArrayResultClosure<Id, O>) -> Void

    // Used by GET returning single codable
    public typealias MiddlewareSimpleCodableClosure<T: TypeSafeMiddleware, O: Codable> = (T, @escaping CodableResultClosure<O>) -> Void
    
    public typealias TwoMiddlewareSimpleCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, O: Codable> = (T1, T2, @escaping CodableResultClosure<O>) -> Void

    public typealias ThreeMiddlewareSimpleCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, O: Codable> = (T1, T2, T3, @escaping CodableResultClosure<O>) -> Void

    // Used by GET with identifier returning single codable
    public typealias MiddlewareIdentifierSimpleCodableClosure<T: TypeSafeMiddleware, Id: Identifier, O: Codable> = (T, Id, @escaping CodableResultClosure<O>) -> Void
    
    public typealias TwoMiddlewareIdentifierSimpleCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, O: Codable> = (T1, T2, Id, @escaping CodableResultClosure<O>) -> Void

    public typealias ThreeMiddlewareIdentifierSimpleCodableClosure<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, O: Codable> = (T1, T2, T3, Id, @escaping CodableResultClosure<O>) -> Void
    
    // GET returning single Codable
    public func get<T: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping MiddlewareSimpleCodableClosure<T, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareSimpleCodableClosure<T1, T2, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareSimpleCodableClosure<T1, T2, T3, O>) {
        getSafely(route, handler: handler)
    }
    
    // GET returning Codable array
    public func get<T: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableArrayClosure<T, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableArrayClosure<T1, T2, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableArrayClosure<T1, T2, T3, O>) {
        getSafely(route, handler: handler)
    }
    
    // GET with identifier returning single Codable
    public func get<T: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierSimpleCodableClosure<T, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierSimpleCodableClosure<T1, T2, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierSimpleCodableClosure<T1, T2, T3, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    // GET with identifier returning Codable array
    public func get<T: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableArrayClosure<T, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableArrayClosure<T1, T2, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableArrayClosure<T1, T2, T3, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    // GET with query parameters returning single Codable
    public func get<T: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T, Q, @escaping CodableResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping CodableResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping CodableResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    // GET with query parameters returning Codable array
    public func get<T: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    // DELETE
    public func delete<T: TypeSafeMiddleware>(_ route: String, handler: @escaping MiddlewareNonCodableClosure<T>) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware>(_ route: String, handler: @escaping TwoMiddlewareNonCodableClosure<T1, T2>) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware>(_ route: String, handler: @escaping ThreeMiddlewareNonCodableClosure<T1, T2, T3>) {
        deleteSafely(route, handler: handler)
    }
    
    // DELETE with identifier
    public func delete<T: TypeSafeMiddleware, Id: Identifier>(_ route: String, handler: @escaping MiddlewareIdentifierNonCodableClosure<T, Id>) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier>(_ route: String, handler: @escaping TwoMiddlewareIdentifierNonCodableClosure<T1, T2, Id>) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierNonCodableClosure<T1, T2, T3, Id>) {
        deleteSafely(route, handler: handler)
    }
    
    // DELETE with query parameters
    public func delete<T: TypeSafeMiddleware, Q: QueryParams>(_ route: String, handler: @escaping (T, Q, @escaping ResultClosure) -> Void) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Q: QueryParams>(_ route: String, handler: @escaping (T1, T2, Q, @escaping ResultClosure) -> Void) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Q: QueryParams>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping ResultClosure) -> Void) {
        deleteSafely(route, handler: handler)
    }
    
    // POST
    public func post<T: TypeSafeMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableClosure<T, I, O>) {
        postSafely(route, handler: handler)
    }
    
    public func post<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableClosure<T1, T2, I, O>) {
        postSafely(route, handler: handler)
    }
    
    public func post<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableClosure<T1, T2, T3, I, O>) {
        postSafely(route, handler: handler)
    }
    
    // POST with identifier
    public func post<T: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableIdentifierClosure<T, I, Id, O>) {
        postSafelyWithId(route, handler: handler)
    }
    
    public func post<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableIdentifierClosure<T1, T2, I, Id, O>) {
        postSafelyWithId(route, handler: handler)
    }
    
    public func post<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableIdentifierClosure<T1, T2, T3, I, Id, O>) {
        postSafelyWithId(route, handler: handler)
    }
    
    // PUT with identifier
    public func put<T: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableClosure<T, Id, I, O>) {
        putSafely(route, handler: handler)
    }
    
    public func put<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableClosure<T1, T2, Id, I, O>) {
        putSafely(route, handler: handler)
    }
    
    public func put<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableClosure<T1, T2, T3, Id, I, O>) {
        putSafely(route, handler: handler)
    }
    
    // PATCH with identifier
    public func patch<T: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableClosure<T, Id, I, O>) {
        patchSafely(route, handler: handler)
    }
    
    public func patch<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableClosure<T1, T2, Id, I, O>) {
        patchSafely(route, handler: handler)
    }
    
    public func patch<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableClosure<T1, T2, T3, Id, I, O>) {
        patchSafely(route, handler: handler)
    }
    
    // POST using one middleware
    fileprivate func postSafely<T: TypeSafeMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableClosure<T, I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                    return next()
                }
                handler(TypeSafeMiddleware, codableInput, CodableHelpers.constructOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // POST using two middleware
    fileprivate func postSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableClosure<T1, T2, I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, codableInput, CodableHelpers.constructOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // POST using three middleware
    fileprivate func postSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableClosure<T1, T2, T3, I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, codableInput, CodableHelpers.constructOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // POST With ID using one middleware
    fileprivate func postSafelyWithId<T: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableIdentifierClosure<T, I, Id, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                return next()
            }
            self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                    return next()
                }
                handler(TypeSafeMiddleware, codableInput, CodableHelpers.constructIdentOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // POST With ID using two middleware
    fileprivate func postSafelyWithId<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableIdentifierClosure<T1, T2, I, Id, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                return next()
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, codableInput, CodableHelpers.constructIdentOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // POST With ID using three middleware
    fileprivate func postSafelyWithId<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableIdentifierClosure<T1, T2, T3, I, Id, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                return next()
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, codableInput, CodableHelpers.constructIdentOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // PUT with Identifier using one middleware
    fileprivate func putSafely<T: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableClosure<T, Id, I, O>) {
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
            self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                    return next()
                }
                handler(TypeSafeMiddleware, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // PUT with Identifier using two middleware
    fileprivate func putSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableClosure<T1, T2, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // PUT with Identifier using three middleware
    fileprivate func putSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableClosure<T1, T2, T3, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // PATCH using one middleware
    fileprivate func patchSafely<T: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableClosure<T, Id, I, O>) {
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
            self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                    return next()
                }
                handler(TypeSafeMiddleware, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))

            }
        }
    }
    
    // PATCH using two middleware
    fileprivate func patchSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableClosure<T1, T2, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                
            }
        }
    }
    
    // PATCH using three middleware
    fileprivate func patchSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableClosure<T1, T2, T3, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                
            }
        }
    }
    
    // Typed GET single Codable using one middleware
    fileprivate func getSafely<T: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping (MiddlewareSimpleCodableClosure<T, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                    return next()
                }
                handler(TypeSafeMiddleware, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Typed GET single Codable using two middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping (TwoMiddlewareSimpleCodableClosure<T1, T2, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Typed GET single Codable using three middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping (ThreeMiddlewareSimpleCodableClosure<T1, T2, T3, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Typed GET array using one middleware
    fileprivate func getSafely<T: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping (MiddlewareCodableArrayClosure<T, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                    return next()
                }
                handler(TypeSafeMiddleware, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Typed GET array using two middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping (TwoMiddlewareCodableArrayClosure<T1, T2, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Typed GET array using three middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, O: Codable>(_ route: String, handler: @escaping (ThreeMiddlewareCodableArrayClosure<T1, T2, T3, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // GET array of (Id, Codable) tuples using one middleware
    fileprivate func getSafely<T: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableArrayClosure<T, Id, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                    return next()
                }
                handler(TypeSafeMiddleware, CodableHelpers.constructTupleArrayOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // GET array of (Id, Codable) tuples using two middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableArrayClosure<T1, T2, Id, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, CodableHelpers.constructTupleArrayOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // GET array of (Id, Codable) tuples using three middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableArrayClosure<T1, T2, T3, Id, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, CodableHelpers.constructTupleArrayOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // GET w/Query Parameters using one middleware
    fileprivate func getSafely<T: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                    guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                        return next()
                    }
                    handler(TypeSafeMiddleware, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // GET w/Query Parameters using two middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                    guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                        return next()
                    }
                    handler(TypeSafeMiddleware1, TypeSafeMiddleware2, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // GET w/Query Parameters using three middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                    guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                        return next()
                    }
                    handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // GET w/Query Parameters with CodableResultClosure using one middleware
    fileprivate func getSafely<T: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T, Q, @escaping CodableResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (singular) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            // Define result handler
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                    guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                        return next()
                    }
                    handler(TypeSafeMiddleware, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // GET w/Query Parameters with CodableResultClosure using two middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping CodableResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (singular) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            // Define result handler
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                    guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                        return next()
                    }
                    handler(TypeSafeMiddleware1, TypeSafeMiddleware2, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // GET w/Query Parameters with CodableResultClosure using three middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping CodableResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (singular) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            // Define result handler
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                    guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                        return next()
                    }
                    handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // GET single identified element using one middleware
    fileprivate func getSafely<T: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierSimpleCodableClosure<T, Id, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        get(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received GET (singular with identifier and middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                    return next()
                }
                handler(TypeSafeMiddleware, identifier, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // GET single identified element using two middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierSimpleCodableClosure<T1, T2, Id, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        get(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received GET (singular with identifier and middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, identifier, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // GET single identified element using three middleware
    fileprivate func getSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierSimpleCodableClosure<T1, T2, T3, Id, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        get(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received GET (singular with identifier and middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, identifier, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE using one middleware
    fileprivate func deleteSafely<T: TypeSafeMiddleware>(_ route: String, handler: @escaping MiddlewareNonCodableClosure<T>) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural with middleware) type-safe request")
            self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                    return next()
                }
                handler(TypeSafeMiddleware, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE using two middleware
    fileprivate func deleteSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware>(_ route: String, handler: @escaping TwoMiddlewareNonCodableClosure<T1, T2>) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural with middleware) type-safe request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE using three middleware
    fileprivate func deleteSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware>(_ route: String, handler: @escaping ThreeMiddlewareNonCodableClosure<T1, T2, T3>) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural with middleware) type-safe request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE single element using one middleware
    fileprivate func deleteSafely<T: TypeSafeMiddleware, Id: Identifier>(_ route: String, handler: @escaping MiddlewareIdentifierNonCodableClosure<T, Id>) {
        if parameterIsPresent(in: route) {
            return
        }
        delete(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received DELETE (singular with middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                    return next()
                }
                handler(TypeSafeMiddleware, identifier, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE single element using two middleware
    fileprivate func deleteSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Id: Identifier>(_ route: String, handler: @escaping TwoMiddlewareIdentifierNonCodableClosure<T1, T2, Id>) {
        if parameterIsPresent(in: route) {
            return
        }
        delete(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received DELETE (singular with middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, identifier, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE single element using three middleware
    fileprivate func deleteSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Id: Identifier>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierNonCodableClosure<T1, T2, T3, Id>) {
        if parameterIsPresent(in: route) {
            return
        }
        delete(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received DELETE (singular with middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                    return next()
                }
                handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, identifier, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE w/Query Parameters using one middleware
    fileprivate func deleteSafely<T: TypeSafeMiddleware, Q: Codable>(_ route: String, handler: @escaping (T, Q, @escaping ResultClosure) -> Void) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T.self, request: request, response: response) { TypeSafeMiddleware in
                    guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                        return next()
                    }
                    handler(TypeSafeMiddleware, query, CodableHelpers.constructResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // DELETE w/Query Parameters using two middleware
    fileprivate func deleteSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, Q: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping ResultClosure) -> Void) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2 in
                    guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                        return next()
                    }
                    handler(TypeSafeMiddleware1, TypeSafeMiddleware2, query, CodableHelpers.constructResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // DELETE w/Query Parameters using three middleware
    fileprivate func deleteSafely<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware, Q: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping ResultClosure) -> Void) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3 in
                    guard let TypeSafeMiddleware1 = TypeSafeMiddleware1, let TypeSafeMiddleware2 = TypeSafeMiddleware2, let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                        return next()
                    }
                    handler(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3, query, CodableHelpers.constructResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
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
        T.handle(request: request, response: response) { (TypeSafeMiddleware: T?, error: RequestError?) in
            guard let TypeSafeMiddleware = TypeSafeMiddleware else {
                response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                return completion(nil)
            }
            completion(TypeSafeMiddleware)
        }
    }
    
    private func handleMiddleware<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware>(_ middlewareOneType: T1.Type, _ middlewareTwoType: T2.Type, request: RouterRequest, response: RouterResponse, completion: @escaping (T1?, T2?) -> Void) {
        T1.handle(request: request, response: response) { (TypeSafeMiddleware1: T1?, error: RequestError?) in
            guard let TypeSafeMiddleware1 = TypeSafeMiddleware1 else {
                response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                return completion(nil, nil)
            }
            T2.handle(request: request, response: response) { (TypeSafeMiddleware2: T2?, error: RequestError?) in
                guard let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                    return completion(TypeSafeMiddleware1, nil)
                }
                completion(TypeSafeMiddleware1, TypeSafeMiddleware2)
            }
        }
    }
    
    private func handleMiddleware<T1: TypeSafeMiddleware, T2: TypeSafeMiddleware, T3: TypeSafeMiddleware>(_ middlewareOneType: T1.Type, _ middlewareTwoType: T2.Type, _ middlewareThreeType: T3.Type, request: RouterRequest, response: RouterResponse, completion: @escaping (T1?, T2?, T3?) -> Void) {
        T1.handle(request: request, response: response) { (TypeSafeMiddleware1: T1?, error: RequestError?) in
            guard let TypeSafeMiddleware1 = TypeSafeMiddleware1 else {
                response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                return completion(nil, nil, nil)
            }
            T2.handle(request: request, response: response) { (TypeSafeMiddleware2: T2?, error: RequestError?) in
                guard let TypeSafeMiddleware2 = TypeSafeMiddleware2 else {
                    response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                    return completion(TypeSafeMiddleware1, nil, nil)
                }
                T3.handle(request: request, response: response) { (TypeSafeMiddleware3: T3?, error: RequestError?) in
                    guard let TypeSafeMiddleware3 = TypeSafeMiddleware3 else {
                        response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                        return completion(TypeSafeMiddleware1, TypeSafeMiddleware2, nil)
                    }
                    completion(TypeSafeMiddleware1, TypeSafeMiddleware2, TypeSafeMiddleware3)
                }
            }
        }
    }
}

