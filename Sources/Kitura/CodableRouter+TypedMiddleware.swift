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

    public typealias MiddlewareIdentifierCodableClosure<T: TypedMiddleware, Id: Identifier, I: Codable, O: Codable> = (T, Id, I, @escaping CodableResultClosure<O>) -> Void
    
    public typealias TwoMiddlewareIdentifierCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier, I: Codable, O: Codable> = (T1, T2, Id, I, @escaping CodableResultClosure<O>) -> Void
    
    public typealias ThreeMiddlewareIdentifierCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier, I: Codable, O: Codable> = (T1, T2, T3, Id, I, @escaping CodableResultClosure<O>) -> Void
    
    /// TODO - document
    public typealias MiddlewareCodableClosure<T: TypedMiddleware, I: Codable, O: Codable> = (T, I, @escaping CodableResultClosure<O>) -> Void
    
    public typealias TwoMiddlewareCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware, I: Codable, O: Codable> = (T1, T2, I, @escaping CodableResultClosure<O>) -> Void
    
    public typealias ThreeMiddlewareCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, I: Codable, O: Codable> = (T1, T2, T3, I, @escaping CodableResultClosure<O>) -> Void

    public typealias MiddlewareCodableIdentifierClosure<T: TypedMiddleware, I: Codable, Id: Identifier, O: Codable> = (T, I, @escaping IdentifierCodableResultClosure<Id, O>) -> Void
    
    public typealias TwoMiddlewareCodableIdentifierClosure<T1: TypedMiddleware, T2: TypedMiddleware, I: Codable, Id: Identifier, O: Codable> = (T1, T2, I, @escaping IdentifierCodableResultClosure<Id, O>) -> Void
    
    public typealias ThreeMiddlewareCodableIdentifierClosure<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, I: Codable, Id: Identifier, O: Codable> = (T1, T2, T3, I, @escaping IdentifierCodableResultClosure<Id, O>) -> Void
    
    public typealias MiddlewareNonCodableClosure<T: TypedMiddleware> = (T, @escaping ResultClosure) -> Void

    public typealias TwoMiddlewareNonCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware> = (T1, T2, @escaping ResultClosure) -> Void

    public typealias ThreeMiddlewareNonCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware> = (T1, T2, T3, @escaping ResultClosure) -> Void

    public typealias MiddlewareIdentifierNonCodableClosure<T: TypedMiddleware, Id: Identifier> = (T, Id, @escaping ResultClosure) -> Void

    public typealias TwoMiddlewareIdentifierNonCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier> = (T1, T2, Id, @escaping ResultClosure) -> Void

    public typealias ThreeMiddlewareIdentifierNonCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier> = (T1, T2, T3, Id, @escaping ResultClosure) -> Void

    /// TODO - document
    public typealias MiddlewareCodableArrayClosure<T: TypedMiddleware, O: Codable> = (T, @escaping CodableArrayResultClosure<O>) -> Void
    
    public typealias TwoMiddlewareCodableArrayClosure<T1: TypedMiddleware, T2: TypedMiddleware, O: Codable> = (T1, T2, @escaping CodableArrayResultClosure<O>) -> Void

    public typealias ThreeMiddlewareCodableArrayClosure<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, O: Codable> = (T1, T2, T3, @escaping CodableArrayResultClosure<O>) -> Void

    public typealias MiddlewareIdentifierCodableArrayClosure<T: TypedMiddleware, Id: Identifier, O: Codable> = (T, @escaping IdentifierCodableArrayResultClosure<Id, O>) -> Void
    
    public typealias TwoMiddlewareIdentifierCodableArrayClosure<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier, O: Codable> = (T1, T2, @escaping IdentifierCodableArrayResultClosure<Id, O>) -> Void

    public typealias ThreeMiddlewareIdentifierCodableArrayClosure<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier, O: Codable> = (T1, T2, T3, @escaping IdentifierCodableArrayResultClosure<Id, O>) -> Void

    public typealias MiddlewareSimpleCodableClosure<T: TypedMiddleware, O: Codable> = (T, @escaping CodableResultClosure<O>) -> Void
    
    public typealias TwoMiddlewareSimpleCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware, O: Codable> = (T1, T2, @escaping CodableResultClosure<O>) -> Void

    public typealias ThreeMiddlewareSimpleCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, O: Codable> = (T1, T2, T3, @escaping CodableResultClosure<O>) -> Void

    public typealias MiddlewareIdentifierSimpleCodableClosure<T: TypedMiddleware, Id: Identifier, O: Codable> = (T, Id, @escaping CodableResultClosure<O>) -> Void
    
    public typealias TwoMiddlewareIdentifierSimpleCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier, O: Codable> = (T1, T2, Id, @escaping CodableResultClosure<O>) -> Void

    public typealias ThreeMiddlewareIdentifierSimpleCodableClosure<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier, O: Codable> = (T1, T2, T3, Id, @escaping CodableResultClosure<O>) -> Void

    public func get<T: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping MiddlewareSimpleCodableClosure<T, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareSimpleCodableClosure<T1, T2, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareSimpleCodableClosure<T1, T2, T3, O>) {
        getSafely(route, handler: handler)
    }
    
    /// TODO - document
    public func get<T: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableArrayClosure<T, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableArrayClosure<T1, T2, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableArrayClosure<T1, T2, T3, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierSimpleCodableClosure<T, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierSimpleCodableClosure<T1, T2, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierSimpleCodableClosure<T1, T2, T3, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableArrayClosure<T, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableArrayClosure<T1, T2, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableArrayClosure<T1, T2, T3, Id, O>) {
        getSafely(route, handler: handler)
    }
    
    public func get<T: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T, Q, @escaping CodableResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping CodableResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping CodableResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    public func get<T: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    public func get<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        getSafely(route, handler: handler)
    }
    
    public func delete<T: TypedMiddleware>(_ route: String, handler: @escaping MiddlewareNonCodableClosure<T>) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypedMiddleware, T2: TypedMiddleware>(_ route: String, handler: @escaping TwoMiddlewareNonCodableClosure<T1, T2>) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware>(_ route: String, handler: @escaping ThreeMiddlewareNonCodableClosure<T1, T2, T3>) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T: TypedMiddleware, Id: Identifier>(_ route: String, handler: @escaping MiddlewareIdentifierNonCodableClosure<T, Id>) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier>(_ route: String, handler: @escaping TwoMiddlewareIdentifierNonCodableClosure<T1, T2, Id>) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierNonCodableClosure<T1, T2, T3, Id>) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T: TypedMiddleware, Q: QueryParams>(_ route: String, handler: @escaping (T, Q, @escaping ResultClosure) -> Void) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypedMiddleware, T2: TypedMiddleware, Q: QueryParams>(_ route: String, handler: @escaping (T1, T2, Q, @escaping ResultClosure) -> Void) {
        deleteSafely(route, handler: handler)
    }
    
    public func delete<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Q: QueryParams>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping ResultClosure) -> Void) {
        deleteSafely(route, handler: handler)
    }
    
    /// TODO - document
    public func post<T: TypedMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableClosure<T, I, O>) {
        postSafely(route, handler: handler)
    }
    
    public func post<T1: TypedMiddleware, T2: TypedMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableClosure<T1, T2, I, O>) {
        postSafely(route, handler: handler)
    }
    
    public func post<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableClosure<T1, T2, T3, I, O>) {
        postSafely(route, handler: handler)
    }
    
    public func post<T: TypedMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableIdentifierClosure<T, I, Id, O>) {
        postSafelyWithId(route, handler: handler)
    }
    
    public func post<T1: TypedMiddleware, T2: TypedMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableIdentifierClosure<T1, T2, I, Id, O>) {
        postSafelyWithId(route, handler: handler)
    }
    
    public func post<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableIdentifierClosure<T1, T2, T3, I, Id, O>) {
        postSafelyWithId(route, handler: handler)
    }
    
    public func put<T: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableClosure<T, Id, I, O>) {
        putSafely(route, handler: handler)
    }
    
    public func put<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableClosure<T1, T2, Id, I, O>) {
        putSafely(route, handler: handler)
    }
    
    public func put<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableClosure<T1, T2, T3, Id, I, O>) {
        putSafely(route, handler: handler)
    }
    
    public func patch<T: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableClosure<T, Id, I, O>) {
        patchSafely(route, handler: handler)
    }
    
    public func patch<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableClosure<T1, T2, Id, I, O>) {
        patchSafely(route, handler: handler)
    }
    
    public func patch<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableClosure<T1, T2, T3, Id, I, O>) {
        patchSafely(route, handler: handler)
    }
    
    // POST Single return
    fileprivate func postSafely<T: TypedMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableClosure<T, I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                guard let typedMiddleware = typedMiddleware else {
                    return next()
                }
                handler(typedMiddleware, codableInput, CodableHelpers.constructOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // POST 2 middleware Single return
    fileprivate func postSafely<T1: TypedMiddleware, T2: TypedMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableClosure<T1, T2, I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, codableInput, CodableHelpers.constructOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // POST 3 middleware Single return
    fileprivate func postSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableClosure<T1, T2, T3, I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, codableInput, CodableHelpers.constructOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // POST With ID
    fileprivate func postSafelyWithId<T: TypedMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareCodableIdentifierClosure<T, I, Id, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                return next()
            }
            self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                guard let typedMiddleware = typedMiddleware else {
                    return next()
                }
                handler(typedMiddleware, codableInput, CodableHelpers.constructIdentOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // POST With ID
    fileprivate func postSafelyWithId<T1: TypedMiddleware, T2: TypedMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareCodableIdentifierClosure<T1, T2, I, Id, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                return next()
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, codableInput, CodableHelpers.constructIdentOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // POST With ID
    fileprivate func postSafelyWithId<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, I: Codable, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareCodableIdentifierClosure<T1, T2, T3, I, Id, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                return next()
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, codableInput, CodableHelpers.constructIdentOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }
    
    // PUT with Identifier
    fileprivate func putSafely<T: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableClosure<T, Id, I, O>) {
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
            self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                guard let typedMiddleware = typedMiddleware else {
                    return next()
                }
                handler(typedMiddleware, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // PUT with Identifier
    fileprivate func putSafely<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableClosure<T1, T2, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // PUT with Identifier
    fileprivate func putSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableClosure<T1, T2, T3, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // PATCH
    fileprivate func patchSafely<T: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableClosure<T, Id, I, O>) {
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
            self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                guard let typedMiddleware = typedMiddleware else {
                    return next()
                }
                handler(typedMiddleware, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))

            }
        }
    }
    
    // PATCH
    fileprivate func patchSafely<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableClosure<T1, T2, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                
            }
        }
    }
    
    // PATCH
    fileprivate func patchSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier, I: Codable, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableClosure<T1, T2, T3, Id, I, O>) {
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
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, identifier, codableInput, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                
            }
        }
    }
    
    // Typed Get Single
    fileprivate func getSafely<T: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping (MiddlewareSimpleCodableClosure<T, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                guard let typedMiddleware = typedMiddleware else {
                    return next()
                }
                handler(typedMiddleware, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Typed Get Single
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping (TwoMiddlewareSimpleCodableClosure<T1, T2, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Typed Get Single
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping (ThreeMiddlewareSimpleCodableClosure<T1, T2, T3, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Typed Get Array
    fileprivate func getSafely<T: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping (MiddlewareCodableArrayClosure<T, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                guard let typedMiddleware = typedMiddleware else {
                    return next()
                }
                handler(typedMiddleware, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Typed Get Array
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping (TwoMiddlewareCodableArrayClosure<T1, T2, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Typed Get Array
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping (ThreeMiddlewareCodableArrayClosure<T1, T2, T3, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Get array of (Id, Codable) tuples
    fileprivate func getSafely<T: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierCodableArrayClosure<T, Id, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                guard let typedMiddleware = typedMiddleware else {
                    return next()
                }
                handler(typedMiddleware, CodableHelpers.constructTupleArrayOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Get array of (Id, Codable) tuples
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierCodableArrayClosure<T1, T2, Id, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, CodableHelpers.constructTupleArrayOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Get array of (Id, Codable) tuples
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierCodableArrayClosure<T1, T2, T3, Id, O>) {
        get(route) { request, response, next in
            Log.verbose("Received GET(Array) typed middleware request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, CodableHelpers.constructTupleArrayOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Get w/Query Parameters
    fileprivate func getSafely<T: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                    guard let typedMiddleware = typedMiddleware else {
                        return next()
                    }
                    handler(typedMiddleware, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // Get w/Query Parameters
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                    guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                        return next()
                    }
                    handler(typedMiddleware1, typedMiddleware2, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // Get w/Query Parameters
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping CodableArrayResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                    guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                        return next()
                    }
                    handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // Get w/Query Parameters with CodableResultClosure
    fileprivate func getSafely<T: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T, Q, @escaping CodableResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (singular) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            // Define result handler
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                    guard let typedMiddleware = typedMiddleware else {
                        return next()
                    }
                    handler(typedMiddleware, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // Get w/Query Parameters with CodableResultClosure
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping CodableResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (singular) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            // Define result handler
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                    guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                        return next()
                    }
                    handler(typedMiddleware1, typedMiddleware2, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // Get w/Query Parameters with CodableResultClosure
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Q: QueryParams, O: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping CodableResultClosure<O>) -> Void) {
        get(route) { request, response, next in
            Log.verbose("Received GET (singular) type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            // Define result handler
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                    guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                        return next()
                    }
                    handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, query, CodableHelpers.constructOutResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // Get single identified element
    fileprivate func getSafely<T: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping MiddlewareIdentifierSimpleCodableClosure<T, Id, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        get(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received GET (singular with identifier and middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                guard let typedMiddleware = typedMiddleware else {
                    return next()
                }
                handler(typedMiddleware, identifier, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Get single identified element
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping TwoMiddlewareIdentifierSimpleCodableClosure<T1, T2, Id, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        get(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received GET (singular with identifier and middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, identifier, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // Get single identified element
    fileprivate func getSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier, O: Codable>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierSimpleCodableClosure<T1, T2, T3, Id, O>) {
        if parameterIsPresent(in: route) {
            return
        }
        get(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received GET (singular with identifier and middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, identifier, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE
    fileprivate func deleteSafely<T: TypedMiddleware>(_ route: String, handler: @escaping MiddlewareNonCodableClosure<T>) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural with middleware) type-safe request")
            self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                guard let typedMiddleware = typedMiddleware else {
                    return next()
                }
                handler(typedMiddleware, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE
    fileprivate func deleteSafely<T1: TypedMiddleware, T2: TypedMiddleware>(_ route: String, handler: @escaping TwoMiddlewareNonCodableClosure<T1, T2>) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural with middleware) type-safe request")
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE
    fileprivate func deleteSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware>(_ route: String, handler: @escaping ThreeMiddlewareNonCodableClosure<T1, T2, T3>) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE (plural with middleware) type-safe request")
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE single element
    fileprivate func deleteSafely<T: TypedMiddleware, Id: Identifier>(_ route: String, handler: @escaping MiddlewareIdentifierNonCodableClosure<T, Id>) {
        if parameterIsPresent(in: route) {
            return
        }
        delete(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received DELETE (singular with middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                guard let typedMiddleware = typedMiddleware else {
                    return next()
                }
                handler(typedMiddleware, identifier, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE single element
    fileprivate func deleteSafely<T1: TypedMiddleware, T2: TypedMiddleware, Id: Identifier>(_ route: String, handler: @escaping TwoMiddlewareIdentifierNonCodableClosure<T1, T2, Id>) {
        if parameterIsPresent(in: route) {
            return
        }
        delete(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received DELETE (singular with middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, identifier, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE single element
    fileprivate func deleteSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Id: Identifier>(_ route: String, handler: @escaping ThreeMiddlewareIdentifierNonCodableClosure<T1, T2, T3, Id>) {
        if parameterIsPresent(in: route) {
            return
        }
        delete(join(path: route, with: ":id")) { request, response, next in
            Log.verbose("Received DELETE (singular with middleware) type-safe request")
            guard let identifier = CodableHelpers.parseIdOrSetResponseStatus(Id.self, from: request, response: response) else {
                next()
                return
            }
            self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                    return next()
                }
                handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, identifier, CodableHelpers.constructResultHandler(response: response, completion: next))
            }
        }
    }
    
    // DELETE w/Query Parameters
    fileprivate func deleteSafely<T: TypedMiddleware, Q: Codable>(_ route: String, handler: @escaping (T, Q, @escaping ResultClosure) -> Void) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T.self, request: request, response: response) { typedMiddleware in
                    guard let typedMiddleware = typedMiddleware else {
                        return next()
                    }
                    handler(typedMiddleware, query, CodableHelpers.constructResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // DELETE w/Query Parameters
    fileprivate func deleteSafely<T1: TypedMiddleware, T2: TypedMiddleware, Q: Codable>(_ route: String, handler: @escaping (T1, T2, Q, @escaping ResultClosure) -> Void) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, request: request, response: response) { typedMiddleware1, typedMiddleware2 in
                    guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2 else {
                        return next()
                    }
                    handler(typedMiddleware1, typedMiddleware2, query, CodableHelpers.constructResultHandler(response: response, completion: next))
                }
            } catch {
                // Http 400 error
                response.status(.badRequest)
                next()
            }
        }
    }
    
    // DELETE w/Query Parameters
    fileprivate func deleteSafely<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware, Q: Codable>(_ route: String, handler: @escaping (T1, T2, T3, Q, @escaping ResultClosure) -> Void) {
        delete(route) { request, response, next in
            Log.verbose("Received DELETE type-safe request with middleware and Query Parameters")
            Log.verbose("Query Parameters: \(request.queryParameters)")
            do {
                let query: Q = try QueryDecoder(dictionary: request.queryParameters).decode(Q.self)
                self.handleMiddleware(T1.self, T2.self, T3.self, request: request, response: response) { typedMiddleware1, typedMiddleware2, typedMiddleware3 in
                    guard let typedMiddleware1 = typedMiddleware1, let typedMiddleware2 = typedMiddleware2, let typedMiddleware3 = typedMiddleware3 else {
                        return next()
                    }
                    handler(typedMiddleware1, typedMiddleware2, typedMiddleware3, query, CodableHelpers.constructResultHandler(response: response, completion: next))
                }
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

    //TODO: Remove print statements and parallelize multiple middleware
    private func handleMiddleware<T: TypedMiddleware>(_ middlewareType: T.Type, request: RouterRequest, response: RouterResponse, completion: @escaping (T?) -> Void) {
        T.handle(request: request, response: response) { (typedMiddleware: T?, error: RequestError?) in
            print("T.handle called")
            guard let typedMiddleware = typedMiddleware else {
                print("Failed Middleware")
                response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                completion(nil)
                return
            }
            print("created typed middleware: \(typedMiddleware)")
            completion(typedMiddleware)
        }
    }
    
    private func handleMiddleware<T1: TypedMiddleware, T2: TypedMiddleware>(_ middlewareOneType: T1.Type, _ middlewareTwoType: T2.Type, request: RouterRequest, response: RouterResponse, completion: @escaping (T1?, T2?) -> Void) {
        T1.handle(request: request, response: response) { (typedMiddleware1: T1?, error: RequestError?) in
            print("T.handle called")
            guard let typedMiddleware1 = typedMiddleware1 else {
                print("Failed Middleware")
                response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                completion(nil, nil)
                return
            }
            print("created typed middleware: \(typedMiddleware1)")
            T2.handle(request: request, response: response) { (typedMiddleware2: T2?, error: RequestError?) in
                print("T.handle called")
                guard let typedMiddleware2 = typedMiddleware2 else {
                    print("Failed Middleware")
                    response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                    completion(nil, nil)
                    return
                }
                print("created typed middleware: \(typedMiddleware2)")
                completion(typedMiddleware1, typedMiddleware2)
            }
        }
    }
    
    private func handleMiddleware<T1: TypedMiddleware, T2: TypedMiddleware, T3: TypedMiddleware>(_ middlewareOneType: T1.Type, _ middlewareTwoType: T2.Type, _ middlewareThreeType: T3.Type, request: RouterRequest, response: RouterResponse, completion: @escaping (T1?, T2?, T3?) -> Void) {
        T1.handle(request: request, response: response) { (typedMiddleware1: T1?, error: RequestError?) in
            print("T.handle called")
            guard let typedMiddleware1 = typedMiddleware1 else {
                print("Failed Middleware")
                response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                completion(nil, nil, nil)
                return
            }
            print("created typed middleware: \(typedMiddleware1)")
            T2.handle(request: request, response: response) { (typedMiddleware2: T2?, error: RequestError?) in
                print("T.handle called")
                guard let typedMiddleware2 = typedMiddleware2 else {
                    print("Failed Middleware")
                    response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                    completion(nil, nil, nil)
                    return
                }
                print("created typed middleware: \(typedMiddleware2)")
                T3.handle(request: request, response: response) { (typedMiddleware3: T3?, error: RequestError?) in
                    print("T.handle called")
                    guard let typedMiddleware3 = typedMiddleware3 else {
                        print("Failed Middleware")
                        response.status(CodableHelpers.httpStatusCode(from: error ?? .internalServerError))
                        completion(nil, nil, nil)
                        return
                    }
                    print("created typed middleware: \(typedMiddleware3)")
                    completion(typedMiddleware1, typedMiddleware2, typedMiddleware3)
                }
            }
        }
    }
}

