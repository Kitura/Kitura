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

// MARK Router

extension Router {
    // MARK: All

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when any request comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when any request comes to the server.
    @discardableResult
    public func all(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.all, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when any request comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when any request comes to the server.
    @discardableResult
    public func all(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.all, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when any request comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when any request comes to the server.
    @discardableResult
    public func all(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.all, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when any request comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when any request comes to the server.
    @discardableResult
    public func all(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.all, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Get

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP GET requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP GET requests comes to the server.
    @discardableResult
    public func get(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.get, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP GET requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP GET requests comes to the server.
    @discardableResult
    public func get(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.get, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP GET requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP GET requests comes to the server.
    @discardableResult
    public func get(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.get, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP GET requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP GET requests comes to the server.
    @discardableResult
    public func get(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.get, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Head

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP HEAD requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP HEAD requests comes to the server.
    @discardableResult
    public func head(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.head, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP HEAD requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP HEAD requests comes to the server.
    @discardableResult
    public func head(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.head, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP HEAD requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP HEAD requests comes to the server.
    @discardableResult
    public func head(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.head, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP HEAD requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP HEAD requests comes to the server.
    @discardableResult
    public func head(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.head, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Post

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP POST requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP POST requests comes to the server.
    @discardableResult
    public func post(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.post, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP POST requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP POST requests comes to the server.
    @discardableResult
    public func post(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.post, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP POST requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP POST requests comes to the server.
    @discardableResult
    public func post(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.post, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP POST requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP POST requests comes to the server.
    @discardableResult
    public func post(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.post, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Put

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP PUT requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP PUT requests comes to the server.
    @discardableResult
    public func put(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.put, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP PUT requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP PUT requests comes to the server.
    @discardableResult
    public func put(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.put, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP PUT requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP PUT requests comes to the server.
    @discardableResult
    public func put(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.put, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP PUT requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP PUT requests comes to the server.
    @discardableResult
    public func put(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.put, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Delete

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP DELETE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP DELETE requests comes to the server.
    @discardableResult
    public func delete(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.delete, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP DELETE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP DELETE requests comes to the server.
    @discardableResult
    public func delete(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.delete, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP DELETE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP DELETE requests comes to the server.
    @discardableResult
    public func delete(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.delete, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP DELETE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP DELETE requests comes to the server.
    @discardableResult
    public func delete(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.delete, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Options

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP OPTIONS requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP OPTIONS requests comes to the server.
    @discardableResult
    public func options(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.options, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP OPTIONS requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP OPTIONS requests comes to the server.
    @discardableResult
    public func options(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.options, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP OPTIONS requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP OPTIONS requests comes to the server.
    @discardableResult
    public func options(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.options, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP OPTIONS requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP OPTIONS requests comes to the server.
    @discardableResult
    public func options(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.options, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Trace

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP TRACE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP TRACE requests comes to the server.
    @discardableResult
    public func trace(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.trace, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP TRACE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP TRACE requests comes to the server.
    @discardableResult
    public func trace(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.trace, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP TRACE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP TRACE requests comes to the server.
    @discardableResult
    public func trace(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.trace, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP TRACE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP TRACE requests comes to the server.
    @discardableResult
    public func trace(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.trace, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Copy

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP COPY requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP COPY requests comes to the server.
    @discardableResult
    public func copy(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.copy, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP COPY requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP COPY requests comes to the server.
    @discardableResult
    public func copy(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.copy, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP COPY requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP COPY requests comes to the server.
    @discardableResult
    public func copy(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.copy, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP COPY requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP COPY requests comes to the server.
    @discardableResult
    public func copy(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.copy, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Lock

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP LOCK requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP LOCK requests comes to the server.
    @discardableResult
    public func lock(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.lock, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP LOCK requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP LOCK requests comes to the server.
    @discardableResult
    public func lock(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.lock, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP LOCK requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP LOCK requests comes to the server.
    @discardableResult
    public func lock(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.lock, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP LOCK requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP LOCK requests comes to the server.
    @discardableResult
    public func lock(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.lock, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: MkCol

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP MKCOL requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP MKCOL requests comes to the server.
    @discardableResult
    public func mkCol(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.mkCol, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP MKCOL requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP MKCOL requests comes to the server.
    @discardableResult
    public func mkCol(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.mkCol, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP MKCOL requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP MKCOL requests comes to the server.
    @discardableResult
    public func mkCol(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.mkCol, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP MKCOL requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP MKCOL requests comes to the server.
    @discardableResult
    public func mkCol(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.mkCol, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Move

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP MOVE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP MOVE requests comes to the server.
    @discardableResult
    public func move(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.move, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP MOVE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP MOVE requests comes to the server.
    @discardableResult
    public func move(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.move, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP MOVE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP MOVE requests comes to the server.
    @discardableResult
    public func move(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.move, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP MOVE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP MOVE requests comes to the server.
    @discardableResult
    public func move(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.move, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Purge

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP PURGE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP PURGE requests comes to the server.
    @discardableResult
    public func purge(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.purge, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP PURGE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP PURGE requests comes to the server.
    @discardableResult
    public func purge(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.purge, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP PURGE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP PURGE requests comes to the server.
    @discardableResult
    public func purge(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.purge, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP PURGE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP PURGE requests comes to the server.
    @discardableResult
    public func purge(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.purge, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: PropFind

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP PROPFIND requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP PROPFIND requests comes to the server.
    @discardableResult
    public func propFind(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.propFind, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP PROPFIND requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP PROPFIND requests comes to the server.
    @discardableResult
    public func propFind(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.propFind, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP PROPFIND requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP PROPFIND requests comes to the server.
    @discardableResult
    public func propFind(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.propFind, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP PROPFIND requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP PROPFIND requests comes to the server.
    @discardableResult
    public func propFind(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.propFind, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: PropPatch

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP PROPPATCH requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP PROPPATCH requests comes to the server.
    @discardableResult
    public func propPatch(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.propPatch, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP PROPPATCH requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP PROPPATCH requests comes to the server.
    @discardableResult
    public func propPatch(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.propPatch, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP PROPPATCH requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP PROPPATCH requests comes to the server.
    @discardableResult
    public func propPatch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.propPatch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP PROPPATCH requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP PROPPATCH requests comes to the server.
    @discardableResult
    public func propPatch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.propPatch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Unlock

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP UNLOCK requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP UNLOCK requests comes to the server.
    @discardableResult
    public func unlock(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.unlock, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP UNLOCK requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP UNLOCK requests comes to the server.
    @discardableResult
    public func unlock(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.unlock, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP UNLOCK requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP UNLOCK requests comes to the server.
    @discardableResult
    public func unlock(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.unlock, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP UNLOCK requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP UNLOCK requests comes to the server.
    @discardableResult
    public func unlock(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.unlock, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Report

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP REPORT requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP REPORT requests comes to the server.
    @discardableResult
    public func report(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.report, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP REPORT requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP REPORT requests comes to the server.
    @discardableResult
    public func report(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.report, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP REPORT requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP REPORT requests comes to the server.
    @discardableResult
    public func report(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.report, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP REPORT requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP REPORT requests comes to the server.
    @discardableResult
    public func report(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.report, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: MkActivity

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP MKACTIVITY requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP MKACTIVITY requests comes to the server.
    @discardableResult
    public func mkActivity(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.mkActivity, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP MKACTIVITY requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP MKACTIVITY requests comes to the server.
    @discardableResult
    public func mkActivity(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.mkActivity, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP MKACTIVITY requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP MKACTIVITY requests comes to the server.
    @discardableResult
    public func mkActivity(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.mkActivity, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP MKACTIVITY requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP MKACTIVITY requests comes to the server.
    @discardableResult
    public func mkActivity(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.mkActivity, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Checkout

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP CHECKOUT requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP CHECKOUT requests comes to the server.
    @discardableResult
    public func checkout(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.checkout, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP CHECKOUT requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP CHECKOUT requests comes to the server.
    @discardableResult
    public func checkout(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.checkout, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP CHECKOUT requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP CHECKOUT requests comes to the server.
    @discardableResult
    public func checkout(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.checkout, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP CHECKOUT requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP CHECKOUT requests comes to the server.
    @discardableResult
    public func checkout(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.checkout, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Merge

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP MERGE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP MERGE requests comes to the server.
    @discardableResult
    public func merge(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.merge, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP MERGE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP MERGE requests comes to the server.
    @discardableResult
    public func merge(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.merge, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP MERGE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP MERGE requests comes to the server.
    @discardableResult
    public func merge(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.merge, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP MERGE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP MERGE requests comes to the server.
    @discardableResult
    public func merge(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.merge, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: MSearch

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP MSEARCH requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP MSEARCH requests comes to the server.
    @discardableResult
    public func mSearch(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.mSearch, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP MSEARCH requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP MSEARCH requests comes to the server.
    @discardableResult
    public func mSearch(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.mSearch, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP MSEARCH requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP MSEARCH requests comes to the server.
    @discardableResult
    public func mSearch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.mSearch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP MSEARCH requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP MSEARCH requests comes to the server.
    @discardableResult
    public func mSearch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.mSearch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Notify

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP NOTIFY requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP NOTIFY requests comes to the server.
    @discardableResult
    public func notify(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.notify, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP NOTIFY requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP NOTIFY requests comes to the server.
    @discardableResult
    public func notify(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.notify, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP NOTIFY requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP NOTIFY requests comes to the server.
    @discardableResult
    public func notify(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.notify, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP NOTIFY requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP NOTIFY requests comes to the server.
    @discardableResult
    public func notify(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.notify, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Subscribe

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP SUBSCRIBE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP SUBSCRIBE requests comes to the server.
    @discardableResult
    public func subscribe(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.subscribe, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP SUBSCRIBE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP SUBSCRIBE requests comes to the server.
    @discardableResult
    public func subscribe(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.subscribe, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP SUBSCRIBE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP SUBSCRIBE requests comes to the server.
    @discardableResult
    public func subscribe(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.subscribe, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP SUBSCRIBE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP SUBSCRIBE requests comes to the server.
    @discardableResult
    public func subscribe(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.subscribe, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Unsubscribe

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP UNSUBSCRIBE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP UNSUBSCRIBE requests comes to the server.
    @discardableResult
    public func unsubscribe(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.unsubscribe, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP UNSUBSCRIBE requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP UNSUBSCRIBE requests comes to the server.
    @discardableResult
    public func unsubscribe(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.unsubscribe, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP UNSUBSCRIBE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP UNSUBSCRIBE requests comes to the server.
    @discardableResult
    public func unsubscribe(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.unsubscribe, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP UNSUBSCRIBE requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP UNSUBSCRIBE requests comes to the server.
    @discardableResult
    public func unsubscribe(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.unsubscribe, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Patch

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP PATCH requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP PATCH requests comes to the server.
    @discardableResult
    public func patch(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.patch, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP PATCH requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP PATCH requests comes to the server.
    @discardableResult
    public func patch(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.patch, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP PATCH requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP PATCH requests comes to the server.
    @discardableResult
    public func patch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.patch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP PATCH requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP PATCH requests comes to the server.
    @discardableResult
    public func patch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.patch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Search

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP SEARCH requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP SEARCH requests comes to the server.
    @discardableResult
    public func search(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.search, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP SEARCH requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP SEARCH requests comes to the server.
    @discardableResult
    public func search(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.search, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP SEARCH requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP SEARCH requests comes to the server.
    @discardableResult
    public func search(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.search, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP SEARCH requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP SEARCH requests comes to the server.
    @discardableResult
    public func search(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.search, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Connect

    /// Setup a set of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP CONNECT requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: A comma delimited set of `RouterHandler`s that will be
    ///                     invoked when HTTP CONNECT requests comes to the server.
    @discardableResult
    public func connect(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.connect, pattern: path, handler: handler)
    }

    /// Setup an array of one or more closures of the type `RouterHandler` that will be
    /// invoked when HTTP CONNECT requests comes to the server. If a path pattern is
    /// specified, the handlers will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the handlers to be invoked.
    /// - Parameter handler: The array of `RouterHandler`s that will be
    ///                     invoked when HTTP CONNECT requests comes to the server.
    @discardableResult
    public func connect(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.connect, pattern: path, handler: handler)
    }

    /// Setup a set of one or more `RouterMiddleware` that will be
    /// invoked when HTTP CONNECT requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: A comma delimited set of `RouterMiddleware` that will be
    ///                     invoked when HTTP CONNECT requests comes to the server.
    @discardableResult
    public func connect(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.connect, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    /// Setup an array of one or more `RouterMiddleware` that will be
    /// invoked when HTTP CONNECT requests comes to the server. If a path pattern is
    /// specified, the `RouterMiddleware` will only be invoked if the pattern is matched.
    ///
    /// - Parameter path: An optional String specifying the pattern that needs to be
    ///                  matched, in order for the `RouterMiddleware` to be invoked.
    /// - Parameter allowPartialMatch: A Bool that indicates whether or not a partial match of
    ///                               the path by the pattern is sufficient.
    /// - Parameter handler: The array of `RouterMiddleware` that will be
    ///                     invoked when HTTP CONNECT requests comes to the server.
    @discardableResult
    public func connect(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.connect, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
}
