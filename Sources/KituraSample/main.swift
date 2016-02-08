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

import sys
import net
import router

import HeliumLogger

#if os(Linux)
    import Glibc
#endif

//import SwiftyJSON

import Foundation

class EchoTest: RouterMiddleware {
    func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        for  (key, value) in request.headers {
            print("EchoTest. key=\(key). value=\(value).")
        }
    }
}


let router = Router()
Log.logger = BasicLogger()
        

router.use("/zxcv/*", middleware: EchoTest())


router.all("/zxcv/:p1") { request, _, next in
    request.userInfo["u1"] = "Ploni Almoni".bridge()
    next()
}

router.get("/qwer") { _, response, next in
    response.setHeader("Content-Type", value: "text/html; charset=utf-8")
    do {
        try response.status(HttpStatusCode.OK).end("<!DOCTYPE html><html><body><b>Received</b></body></html>\n\n")
    }
    catch {}
    next()
}

// router.get("/") { _, response, next in
//     response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
//     do {
//         try response.status(HttpStatusCode.OK).send("Hello World!").end()
//     }
//     catch {}
//     next()
// }


router.get("/zxcv/:p1") { request, response, next in
    response.setHeader("Content-Type", value: "text/html; charset=utf-8")
    let p1 = request.params["p1"] ?? "(nil)"
    let q = request.queryParams["q"] ?? "(nil)"
    let u1 = request.userInfo["u1"] as? NSString ?? "(nil)"
    do {
        try response.status(HttpStatusCode.OK).send("<!DOCTYPE html><html><body><b>Received /zxcv</b><p><p>p1=\(p1)<p><p>q=\(q)<p><p>u1=\(u1)</body></html>\n\n").end()
    }
    catch {}
    next()
}

        
router.get("/redir") { _, response, next in
    do {
        try response.redirect("http://www.ibm.com")
    }
    catch {}

    next()
}

        
router.get("/error") { _, response, next in
    response.error = NSError(domain: "RouterTestDomain", code: 1, userInfo: [:])
    next()
}


router.use("/bodytest", middleware: BodyParser())
        
router.post("/bodytest") { request, response, next in
    // if let json = request.body?.asJson() {
    //     response.setHeader("Content-Type", value: "text/html; charset=utf-8")
    //     do {
    //         try response.status(HttpStatusCode.OK).end("<!DOCTYPE html><html><body><b>Received JSON body </b><br>\(json)</body></html>\n\n")
    //     }
    //     catch {}
    // }
    if let body = request.body?.asUrlEncoded() {
        response.setHeader("Content-Type", value: "text/html; charset=utf-8")
        do {
            try response.status(HttpStatusCode.OK).end("<!DOCTYPE html><html><body><b>Received URL encoded body</b><br> \(body) </body></html>\n\n")
        }
        catch {}
    }
    else if let text = request.body?.asText() {
        response.setHeader("Content-Type", value: "text/html; charset=utf-8")
        do {
            try response.status(HttpStatusCode.OK).end("<!DOCTYPE html><html><body><b>Received text body: </b>\(text)</body></html>\n\n")
        }
        catch {}
    }
    else {
        response.error = NSError(domain: "RouterTestDomain", code: 1, userInfo: [NSLocalizedDescriptionKey:"Failed to parse request body"])
    }

    next()
}


// router.get("/json/:p1") { request, response, next in
//     let p1 = request.params["p1"] ?? ""
//     let dict: [String: AnyObject] = ["a": "asdf", "b": [1,2,3], "c":true, "d": NSNull(), "e": 123, "f": ["p1": p1]]
//     let json = JSON(dict)
//     do {
//         try response.status(.OK).sendJson(json).end()
//     }
//     catch {}
//     next()
// }

        
let server = HttpServer.listen(8090, delegate: router)
        
Server.run()


