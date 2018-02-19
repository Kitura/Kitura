/*
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
 */

import KituraNet
import LoggerAPI

import Foundation
import Dispatch

// MARK Kitura

/**
 A set of helper functions to make it easier to create, start, and stop Kitura based servers.
 ### Usage Example: ###
 In this example, a function called run is created, inside a server `Application.swift` file. This will create a Kitura server on the specified port, using the given router and run this created server. This `Application.run` function would then be called in your `main.swift` file as a non-returning function to initilize your Kitura server.
 ```swift
 let router = Router()
 let port: Int = 8080
 public func run() throws{
 ...
    Kitura.addHTTPServer(onPort: port, with: router)
    Kitura.run()
 }
 ```
 */
public class Kitura {

    /// Add an HTTPServer on a port with a delegate.
    ///
    /// The server is only registered with the framework, it does not start listening
    /// on the port until `Kitura.run()` or `Kitura.start()` are called.
    ///
    ///### Usage Example: ###
    ///```swift
    /// Kitura.addHTTPServer(onPort: port, with: router)
    ///```
    /// - Parameter onPort: The port to listen on.
    /// - Parameter with: The `ServerDelegate` to use.
    /// - Parameter withSSL: The `sslConfig` to use.
    /// - Parameter keepAlive: The maximum number of additional requests to permit per Keep-Alive connection. Defaults to `.unlimited`. If set to `.disabled`, Keep-Alive will not be permitted.
    /// - Parameter allowPortReuse: Determines whether the listener port may be shared with other Kitura instances (`SO_REUSEPORT`). Defaults to `false`. If the specified port is already in use by another listener that has not allowed sharing, the server will fail to start.
    /// - Returns: The created `HTTPServer`.
    @discardableResult
    public class func addHTTPServer(onPort port: Int,
                                    with delegate: ServerDelegate,
                                    withSSL sslConfig: SSLConfig?=nil,
                                    keepAlive keepAliveState: KeepAliveState = .unlimited,
                                    allowPortReuse: Bool = false) -> HTTPServer {
        let server = HTTP.createServer()
        server.delegate = delegate
        server.sslConfig = sslConfig?.config
        server.keepAliveState = keepAliveState
        server.allowPortReuse = allowPortReuse
        httpServersAndPorts.append((server: server, port: port))
        return server
    }

    /// Add a FastCGIServer on a port with a delegate.
    ///
    /// The server is only registered with the framework, it does not start listening
    /// on the port until `Kitura.run()` or `Kitura.start()` are called.
    ///
    ///### Usage Example: ###
    ///```swift
    /// Kitura.addFastCGIServer(onPort: port, with: router)
    ///```
    /// - Parameter onPort: The port to listen on.
    /// - Parameter with: The `ServerDelegate` to use.
    /// - Parameter allowPortReuse: Determines whether the listener port may be shared with other Kitura instances (`SO_REUSEPORT`). Defaults to `false`. If the specified port is already in use by another listener that has not allowed sharing, the server will fail to start.
    /// - Returns: The created `FastCGIServer`.
    @discardableResult
    public class func addFastCGIServer(onPort port: Int,
                                       with delegate: ServerDelegate,
                                       allowPortReuse: Bool = false) -> FastCGIServer {
        let server = FastCGI.createServer()
        server.delegate = delegate
        server.allowPortReuse = allowPortReuse
        fastCGIServersAndPorts.append((server: server, port: port))
        return server
    }

    /// Start the Kitura framework.
    ///
    ///### Usage Example: ###
    /// Make all registered servers start listening on their port.
    ///```swift
    /// Kitura.run()
    ///```
    /// - note: This function never returns - it should be the last call in your `main.swift` file.
    public class func run() {
        Log.verbose("Starting Kitura framework...")
        start()
        ListenerGroup.waitForListeners()
    }

    /// Start all registered servers and return.
    ///
    ///### Usage Example: ###
    /// Make all registered servers start listening on their port.
    ///```swift
    /// Kitura.start()
    ///```
    public class func start() {
        for (server, port) in httpServersAndPorts {
            Log.verbose("Starting an HTTP Server on port \(port)...")
            do {
                try server.listen(on: port)
            } catch {
                Log.error("Error listening on port \(port): \(error). Use server.failed(callback:) to handle")
            }
        }
        for (server, port) in fastCGIServersAndPorts {
            Log.verbose("Starting a FastCGI Server on port \(port)...")
            do {
                try server.listen(on: port)
            } catch {
                Log.error("Error listening on port \(port): \(error). Use server.failed(callback:) to handle")
            }
        }
    }

    /// Stop all registered servers.
    ///
    ///### Usage Example: ###
    /// Make all registered servers stop listening on their port.
    ///```swift
    /// Kitura.stop()
    ///```
    ///
    /// - Parameter unregister: If servers should be unregistered after they are stopped (default true).
    public class func stop(unregister: Bool = true) {
        for (server, port) in httpServersAndPorts {
            Log.verbose("Stopping HTTP Server on port \(port)...")
            server.stop()
        }

        for (server, port) in fastCGIServersAndPorts {
            Log.verbose("Stopping FastCGI Server on port \(port)...")
            server.stop()
        }

        if unregister {
            httpServersAndPorts.removeAll()
            fastCGIServersAndPorts.removeAll()
        }
    }

    typealias Port = Int
    internal private(set) static var httpServersAndPorts = [(server: HTTPServer, port: Port)]()
    internal private(set) static var fastCGIServersAndPorts = [(server: FastCGIServer, port: Port)]()
}
