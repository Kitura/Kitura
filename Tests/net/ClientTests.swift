/**
 * Copyright IBM Corporation 2016
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
 **/

import Foundation

import XCTest

@testable import KituraNet

class ClientTests: XCTestCase {

    static var allTests : [(String, ClientTests -> () throws -> Void)] {
        return [
            ("testSimpleHttpClient", testSimpleHttpClient)
        ]
    }
    
    func testSimpleHttpClient() {
        _ = Http.get("http://www.ibm.com") {response in
            XCTAssertNotNil(response, "ERROR!!! ClientRequest response object was nil")
            XCTAssertEqual(response!.statusCode, HttpStatusCode.OK, "HTTP Status code was \(response!.statusCode)")
            let contentType = response!.headers["Content-Type"]
            XCTAssertNotNil(contentType, "No ContentType header in response")
            XCTAssertEqual(contentType!, "text/html", "Content-Type header wasn't `text/html`")
        }
    }
}