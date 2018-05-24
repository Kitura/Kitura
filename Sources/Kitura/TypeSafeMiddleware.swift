/*
 * Copyright IBM Corporation 2018
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

/**
 The protocol that type-safe middleware must implement to be used in Kitura Codable routes.
 
 Classes or structs conforming to TypeSafeMiddleware must contain a static handle function that processes an incoming request.
 On success, the handle function creates an instance of Self and passes this instance to the users route handler.
 ### Usage Example: ###
 In this example, a UserMiddleware struct is defined that checks the request for the header "TestHeader".
 If the header is found UserMiddleware initialises itself with the header and passes itself to the route.
 If the header is not found it returns a RequestError.
 ```swift
 struct UserMiddleware: TypeSafeMiddleware {
     let header: String
 
     static func handle(
                 request: RouterRequest,
                 response: RouterResponse,
                 completion: @escaping (UserMiddleware?, RequestError?) -> Void
     ) {
         guard let expectedHeader = request.headers["TestHeader"] else {
             return completion(nil, .badRequest)
         }
         let selfInstance: UserMiddleware = UserMiddleware(header: expectedHeader)
         completion(selfInstance, nil)
     }
 }
 ```
 */
public protocol TypeSafeMiddleware {
    
    /// Handle an incoming HTTP request.
    ///
    /// - Parameter request: The `RouterRequest` object used to work with the incoming
    ///                     HTTP request.
    /// - Parameter response: The `RouterResponse` object used to respond to the
    ///                     HTTP request.
    /// - Parameter completion: The closure to invoke once middleware processing is
    ///                         complete. Either an instance of Self or a RequestError
    ///                         should be provided, indicating a successful or failed
    ///                         attempt to process the request, respectively.
    static func handle(request: RouterRequest, response: RouterResponse, completion: @escaping (Self?, RequestError?) -> Void) -> Void

}
