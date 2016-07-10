/**
 * Copyright IBM Corporation 2015
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

import KituraNet
import LoggerAPI

import Foundation
import Dispatch


// MARK Kitura

public class Kitura {
    //
    // add an HTTPServer on a port with a delegate. The server is only registered with the framework,
    // it does not start listening on the port until Kitura.run() is called
    //
    @discardableResult
    public class func addHTTPServer(onPort port: Int, with delegate: ServerDelegate) -> HTTPServer {
        let server = HTTP.createServer()
        server.delegate = delegate
        httpServersAndPorts.append(server: server, port: port)
        return server
    }

    //
    // Start Kitura framework - make all the registered servers to start listening on their port
    // The function never returns - should be the last call in main.swift
    //
    public class func run() {
        Log.verbose("Staring Kitura framework...")
        for (server, port) in httpServersAndPorts {
            Log.verbose("Starting an HTTP Server on port \(port)...")
            server.listen(port: port, notOnMainQueue: false)
        }
        HTTPServer.waitForListeners()
    }
    
    typealias Port = Int
    private static var httpServersAndPorts = [(server: HTTPServer, port: Port)]()

}
