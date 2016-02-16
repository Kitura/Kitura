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

// KituraSample shows examples for creating custom routes.

import sys
import net
import router

import LoggerAPI
import HeliumLogger

#if os(Linux)
    import Glibc
#endif

import Foundation

#if os(OSX)
    import Mustache
#endif

// All Web apps need a router to define routes
let router = Router()

// Using an implementation for a Logger
Log.logger = HeliumLogger()

/** 
* RouterMiddleware can be used for intercepting requests and handling custom behavior
* such as authentication and other routing
*/
class BasicAuthMiddleware: RouterMiddleware {
    func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        
        let authString = request.headers["Authorization"]
        
        Log.info("Authorization: \(authString)")
        
        // Check authorization string in database to approve the request if fail
        // response.error = NSError(domain: "AuthFailure", code: 1, userInfo: [:])
    }
}


// This route executes the echo middleware
router.use("/*", middleware: BasicAuthMiddleware())

router.get("/hello") { _, response, next in
     response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
     do {
         try response.status(HttpStatusCode.OK).send("Hello World!").end()
     }
     catch {}
     next()
}

router.post("/") {request, response, next in
    response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
    do {
        try response.status(HttpStatusCode.OK).send("Got a POST request").end()
    }
    catch {}
    next()
}

router.put("/") {request, response, next in
    response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
    do {
        try response.status(HttpStatusCode.OK).send("Got a PUT request").end()
    }
    catch {}
    next()
}

router.delete("/") {request, response, next in
    response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
    do {
        try response.status(HttpStatusCode.OK).send("Got a DELETE request").end()
    }
    catch {}
    next()
}

// Handing errors
router.get("/error") { _, response, next in
    response.error = NSError(domain: "RouterTestDomain", code: 1, userInfo: [:])
    next()
}

// Handling redirects
router.get("/redir") { _, response, next in
    do {
        try response.redirect("http://www.ibm.com")
    }
    catch {}
    
    next()
}

// Reading parameters
router.get("/users/:user") { request, response, next in
    response.setHeader("Content-Type", value: "text/html; charset=utf-8")
    let p1 = request.params["user"] ?? "(nil)"
    do {
        try response.status(HttpStatusCode.OK).send(
            "<!DOCTYPE html><html><body>" +
            "<b>User:</b> \(p1)" +
            "</body></html>\n\n").end()
    }
    catch {}
    next()
}

#if os(OSX) // Mustache implented for OSX only yet
router.get("/mustache") { _, response, next in
    defer {
        next()
    }
    do {
        // the example from https://github.com/groue/GRMustache.swift/blob/master/README.md
        let template = try Template(string: "Hello {{name}}\n" +
            "Your beard trimmer will arrive on {{format(date)}}.\n" +
            "{{#late}}" +
            "Well, on {{format(realDate)}} because of a Martian attack." +
            "{{/late}}")
        // Let template format dates with `{{format(...)}}`
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        template.registerInBaseContext("format", Box(dateFormatter))

        // The rendered data
        let data = [
            "name": "Arthur",
            "date": NSDate(),
            "realDate": NSDate().dateByAddingTimeInterval(60*60*24*3),
            "late": true
        ]
        var rendering = ""
        // The rendering: "Hello Arthur..."
        do {
            rendering = try template.render(Box(data))
        }
        catch {
            Log.error("Failed to render mustache template")
        }

        do {
            try response.status(HttpStatusCode.OK).end(rendering)
        }
        catch {
            Log.error("Failed to send response")
        }
    }
    catch {
        Log.error("Failed to create mustache template")
    }
}
#endif

let server = HttpServer.listen(8090,
    delegate: router)

Server.run()


