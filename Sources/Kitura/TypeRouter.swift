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

//Protocols - we will move them to a separate repo soon so they can be shared with other swift packages
public protocol Identifier {
    init(value: String) throws
}

// Need to define an Error entity that conforms to the Erro protocol
//Protocols

// Type-safe router
extension Router {
    public typealias ResultClosure = (Swift.Error?) -> Void
    public typealias CodableResultClosure<O: Codable> = (O) -> Void
    public typealias IdentifierCodableClosure<Id: Identifier, I: Codable, O: Codable> = (Id, I, @escaping CodableResultClosure<O>) throws -> Void
    public typealias CodableClosure<I: Codable,O: Codable> = (I, @escaping CodableResultClosure<O>) throws -> Void    
    public typealias NonCodableClosure = (@escaping ResultClosure) throws -> Void

    // DELETE
    public func delete(_ route: String, codableHandler: @escaping NonCodableClosure) {
        delete(route) { request, response, next in        
            let handler: ResultClosure = { error in
                if let _ = error {
                    response.status(.unprocessableEntity)                    
                }
                next()
            }  
            try codableHandler(handler)
        }
    }

    // PATCH
    public func patch<Id: Identifier, I: Codable, O: Codable>(_ route: String, codableHandler: @escaping IdentifierCodableClosure<Id, I, O>) {
        patch("\(route)/:id") { request, response, next in
            Log.verbose("Received PATCH type-safe request")
            let id = request.parameters["id"] ?? ""
            var data = Data()
            let _ = try request.read(into: &data)
            let param = try JSONDecoder().decode(I.self, from: data)
            let identifier = try Id(value: id)
            let handler: CodableResultClosure<O> = { result in
                do {
                   let encoded = try JSONEncoder().encode(result)
                   response.send(data: encoded)
                 } catch {
                     // Http error 422
                     response.status(.unprocessableEntity)
                 }
                 next()
            }
            try codableHandler(identifier, param, handler)
        }
    }
    
    // POST
	public func post<I: Codable, O: Codable>(_ route: String, codableHandler: @escaping CodableClosure<I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            do {
                var data = Data()
                let _ = try request.read(into: &data)
                let param = try JSONDecoder().decode(I.self, from: data)
                let handler: CodableResultClosure<O> = { result in
                    do {
                        let encoded = try JSONEncoder().encode(result)
                        response.status(.created)
                        response.send(data: encoded)
                    } catch {
                        // Http error 422
                        response.status(.unprocessableEntity)
                    }
                    next()
                }
                try codableHandler(param, handler)
            } catch {
                response.status(.internalServerError)
                response.send("\(error)")
                next()
            }
        }
    }

    // PUT with Identifier
    public func put<Id: Identifier, I: Codable, O: Codable>(_ route: String, codableHandler: @escaping IdentifierCodableClosure<Id, I, O>) {
        put("\(route)/:id") { request, response, next in
            Log.verbose("Received PUT type-safe request")
            let id = request.parameters["id"] ?? ""
            var data = Data()
            let _ = try request.read(into: &data)
            let param = try JSONDecoder().decode(I.self, from: data)
            let identifier = try Id(value: id)
            let handler: CodableResultClosure<O> = { result in
                do {
                   let encoded = try JSONEncoder().encode(result)
                   response.send(data: encoded)
                 } catch {
                     // Http error 422
                     response.status(.unprocessableEntity)
                 }
                 next()
            }
            try codableHandler(identifier, param, handler)
        }
    }
}

#endif
