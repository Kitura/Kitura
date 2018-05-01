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

    /// TODO - document
    public typealias CodableTypedArrayClosure<T: TypedMiddleware, O: Codable> = ((T, @escaping ([O]?, RequestError?) -> Void) -> Void)
    
    /// TODO - document
    public typealias CodableTypedClosure<T: TypedMiddleware, I: Codable, O: Codable> = ((T, I, @escaping (O?, RequestError?) -> Void) -> Void)

    /// TODO - document
    public func get<T: TypedMiddleware, O: Codable>(_ route: String, handler: @escaping (CodableTypedArrayClosure<T, O>)) {
        getSafely(route, handler: handler)
    }
    
    /// TODO - document
    public func post<T: TypedMiddleware, I: Codable, O: Codable>(_ route: String, handler: @escaping CodableTypedClosure<T, I, O>) {
        postSafely(route, handler: handler)
    }

    // Get
    fileprivate func getSafely<T: TypedMiddleware, O: Codable>(_ route: String, handler userCodableRequestHandler: @escaping (CodableTypedArrayClosure<T, O>)) {
        get(route) { request, response, next in
            Log.verbose("Received GET (plural) type-safe request")
            print("Handling Request")

            // Define result handler
            T.handle(request: request, response: response) { (tMiddle: T?, error: RequestError?) in
                print("T.handle")
                guard let typedMiddleware = tMiddle else {
                    print("no auth")
                    response.status(CodableHelpers.httpStatusCode(from: error!))
                    next()
                    return
                }
                print(typedMiddleware)
                userCodableRequestHandler(typedMiddleware, CodableHelpers.constructOutResultHandler(response: response, completion: next))
            }
        }
    }
    
    // POST
    fileprivate func postSafely<T: TypedMiddleware, I: Codable, O: Codable>(_ route: String, handler userCodableRequestHandler: @escaping CodableTypedClosure<T, I, O>) {
        post(route) { request, response, next in
            Log.verbose("Received POST type-safe request")
            guard let codableInput = CodableHelpers.readCodableOrSetResponseStatus(I.self, from: request, response: response) else {
                next()
                return
            }
            // Define result handler
            T.handle(request: request, response: response) { (tMiddle: T?, error: RequestError?) in
                print("T.handle")
                guard let typedMiddleware = tMiddle else {
                    print("no auth")
                    response.status(CodableHelpers.httpStatusCode(from: error!))
                    next()
                    return
                }
                print(typedMiddleware)
                userCodableRequestHandler(typedMiddleware, codableInput, CodableHelpers.constructOutResultHandler(successStatus: .created, response: response, completion: next))
            }
        }
    }

}

