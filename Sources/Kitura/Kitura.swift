/*
 * Copyright IBM Corporation 2015-2019
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
 Facilities for creating, starting and stopping Kitura-based servers.
 ### Usage Example: ###
 In this example, a `Router` is created, and a single route registered that responds to an HTTP GET request on "/" with a plain text response.
 An HTTP server is created on port 8080, and is started with the `Kitura.run()` function (note that this function does not return).
 The route can then be accessed by visiting `http://localhost:8080`.
 ```swift
 let router = Router()
 router.get("/") { request, response, next in
     response.send("Hello world")
     next()
 }
 Kitura.addHTTPServer(onPort: 8080, with: router)
 Kitura.run()
 ```
 */
public class Kitura {

    // Socket types that we currently support
    private enum ListenerType {
        case inet(Int)
        case unix(String)
    }

    // MARK: Create Server
    
    /// Add an HTTPServer on a port with a delegate.
    ///
    /// The server is only registered with the framework, it does not start listening
    /// on the port until `Kitura.run()` or `Kitura.start()` are called.
    ///
    ///### Usage Example: ###
    ///```swift
    /// let router = Router()
    /// Kitura.addHTTPServer(onPort: 8080, with: router)
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
        return Kitura._addHTTPServer(on: .inet(port), with: delegate, withSSL: sslConfig, keepAlive: keepAliveState, allowPortReuse: allowPortReuse)
    }

    /// Add an HTTPServer on a Unix domain socket path with a delegate.
    ///
    /// The server is only registered with the framework, it does not start listening
    /// on the Unix socket until `Kitura.run()` or `Kitura.start()` are called.
    ///
    ///### Usage Example: ###
    ///```swift
    /// let router = Router()
    /// Kitura.addHTTPServer(onUnixDomainSocket: "/tmp/mySocket", with: router)
    ///```
    /// - Parameter onUnixDomainSocket: The path of the Unix domain socket to listen on.
    /// - Parameter with: The `ServerDelegate` to use.
    /// - Parameter withSSL: The `sslConfig` to use.
    /// - Parameter keepAlive: The maximum number of additional requests to permit per Keep-Alive connection. Defaults to `.unlimited`. If set to `.disabled`, Keep-Alive will not be permitted.
    /// - Returns: The created `HTTPServer`.
    @discardableResult
    public class func addHTTPServer(onUnixDomainSocket socketPath: String,
                                    with delegate: ServerDelegate,
                                    withSSL sslConfig: SSLConfig?=nil,
                                    keepAlive keepAliveState: KeepAliveState = .unlimited) -> HTTPServer {
        return Kitura._addHTTPServer(on: .unix(socketPath), with: delegate, withSSL: sslConfig, keepAlive: keepAliveState)
    }

    private class func _addHTTPServer(on listenType: ListenerType,
                                    with delegate: ServerDelegate,
                                    withSSL sslConfig: SSLConfig?=nil,
                                    keepAlive keepAliveState: KeepAliveState = .unlimited,
                                    allowPortReuse: Bool = false) -> HTTPServer {
        let server = HTTP.createServer()
        server.delegate = delegate
        server.sslConfig = sslConfig?.config
        server.keepAliveState = keepAliveState
        server.allowPortReuse = allowPortReuse
        serverLock.lock()
        switch listenType {
        case .inet(let port):
            httpServersAndPorts.append((server: server, port: port))
        case .unix(let socketPath):
            httpServersAndUnixSocketPaths.append((server: server, socketPath: socketPath))
        }
        serverLock.unlock()
        return server
    }

    /// Add a FastCGIServer on a port with a delegate.
    ///
    /// The server is only registered with the framework, it does not start listening
    /// on the port until `Kitura.run()` or `Kitura.start()` are called.
    ///
    ///### Usage Example: ###
    ///```swift
    /// let router = Router()
    /// Kitura.addFastCGIServer(onPort: 8080, with: router)
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
        serverLock.lock()
        fastCGIServersAndPorts.append((server: server, port: port))
        serverLock.unlock()
        return server
    }

    // MARK: Start Servers
    
    /// Start the Kitura framework.
    /// By default, the Kitura framework process will exit if one or more of the servers fails to start. To prevent the Kitura framework process from exiting with set the `exitOnFailure` parameter to false.
    ///
    ///### Usage Example: ###
    /// Make all registered servers start listening on their port.
    ///```swift
    /// let router = Router()
    /// Kitura.addHTTPServer(onPort: 8080, with: router)
    /// Kitura.run()
    ///```
    /// Make all registered servers start listening on their port and exit if any fail to start.
    ///```swift
    /// let router = Router()
    /// Kitura.addHTTPServer(onPort: 8080, with: router)
    /// Kitura.run(exitOnFailure: false)
    ///```
    /// - note: This function never returns - it should be the last call in your `main.swift` file.
    /// - Parameter exitOnFailure: Determines whether the Kitura process can return a non-zero exit code should any of the servers fail to start. Defaults to true, indicating it will exit if any of the servers fail to start.
    public class func run(exitOnFailure: Bool = true) {
        Log.verbose("Starting Kitura framework...")
        if exitOnFailure {
            let numberOfFailures = startWithStatus()
            if numberOfFailures > 0 {
                exit(Int32(numberOfFailures))
            }
        } else {
            start()
        }
        ListenerGroup.waitForListeners()
    }

    /// Start all registered servers and return.
    ///
    ///### Usage Example: ###
    /// Make all registered servers start listening on their port.
    ///```swift
    /// let router = Router()
    /// Kitura.addHTTPServer(onPort: 8080, with: router)
    /// Kitura.start()
    ///```
    public class func start() {
        _ = startWithStatus()
    }
    
    /// Wait on all registered servers.
    ///
    ///### Usage Example: ###
    ///
    ///```swift
    /// let failures = Kitura.startWithStatus()
    /// if failures == 0 {
    ///   Kitura.wait()
    /// else {
    ///   // handle failures
    /// }
    ///```
    public class func wait() {
        ListenerGroup.waitForListeners()
    }
    
    /// Start all registered servers and return the number of servers that failed to start.
    ///
    ///### Usage Example: ###
    /// Make all registered servers start listening on their port.
    ///```swift
    /// let router = Router()
    /// Kitura.addHTTPServer(onPort: 8080, with: router)
    /// Kitura.startWithStatus() // Returns the number of failed server starts.
    ///```
    public class func startWithStatus() -> Int {
        serverLock.lock()
        var numberOfFailures = 0
        for (server, port) in httpServersAndPorts {
            Log.verbose("Starting an HTTP Server on port \(port)...")
            do {
                try server.listen(on: port)
            } catch {
                numberOfFailures += 1
                Log.error("Error listening on port \(port): \(error). Use server.failed(callback:) to handle")
            }
        }
        for (server, path) in httpServersAndUnixSocketPaths {
            Log.verbose("Starting an HTTP Server on path \(path)...")
            do {
                try server.listen(unixDomainSocketPath: path)
            } catch {
                Log.error("Error listening on path \(path): \(error). Use server.failed(callback:) to handle")
            }
        }
        for (server, port) in fastCGIServersAndPorts {
            Log.verbose("Starting a FastCGI Server on port \(port)...")
            do {
                try server.listen(on: port)
            } catch {
                numberOfFailures += 1
                Log.error("Error listening on port \(port): \(error). Use server.failed(callback:) to handle")
            }
        }
        serverLock.unlock()
        return numberOfFailures
    }

    // MARK: Stop Servers
    
    /// Stop all registered servers.
    ///
    ///### Usage Example: ###
    /// Make all registered servers stop listening on their port.
    ///```swift
    /// let router = Router()
    /// Kitura.addHTTPServer(onPort: 8080, with: router)
    /// Kitura.start()
    /// Kitura.stop()
    ///```
    ///
    /// - Parameter unregister: If servers should be unregistered after they are stopped (default true).
    public class func stop(unregister: Bool = true) {
        serverLock.lock()
        for (server, port) in httpServersAndPorts {
            Log.verbose("Stopping HTTP Server on port \(port)...")
            server.stop()
        }

        for (server, path) in httpServersAndUnixSocketPaths {
            Log.verbose("Stopping HTTP Server on path \(path)...")
            server.stop()
        }

        for (server, port) in fastCGIServersAndPorts {
            Log.verbose("Stopping FastCGI Server on port \(port)...")
            server.stop()
        }

        if unregister {
            httpServersAndPorts.removeAll()
            httpServersAndUnixSocketPaths.removeAll()
            fastCGIServersAndPorts.removeAll()
        }
        serverLock.unlock()
    }

    typealias Port = Int
    internal static let serverLock = NSLock()
    internal private(set) static var httpServersAndPorts = [(server: HTTPServer, port: Port)]()
    internal private(set) static var httpServersAndUnixSocketPaths = [(server: HTTPServer, socketPath: String)]()
    internal private(set) static var fastCGIServersAndPorts = [(server: FastCGIServer, port: Port)]()
}
