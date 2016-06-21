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

// MARK Router

extension Router {
    // MARK: All
    @discardableResult
    public func all(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.all, pattern: path, handler: handler)
    }

    @discardableResult
    public func all(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.all, pattern: path, handler: handler)
    }

    @discardableResult
    public func all(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.all, pattern: path, middleware: middleware)
    }

    public func all(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.all, pattern: path, middleware: middleware)
    }

    // MARK: Get
    @discardableResult
    public func get(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.get, pattern: path, handler: handler)
    }

    @discardableResult
    public func get(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.get, pattern: path, handler: handler)
    }

    public func get(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.get, pattern: path, middleware: middleware)
    }

    public func get(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.get, pattern: path, middleware: middleware)
    }

    // MARK: Head
    public func head(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.head, pattern: path, handler: handler)
    }

    public func head(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.head, pattern: path, handler: handler)
    }

    public func head(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.head, pattern: path, middleware: middleware)
    }

    public func head(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.head, pattern: path, middleware: middleware)
    }

    // MARK: Post
    @discardableResult
    public func post(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.post, pattern: path, handler: handler)
    }

    @discardableResult
    public func post(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.post, pattern: path, handler: handler)
    }

    public func post(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.post, pattern: path, middleware: middleware)
    }

    public func post(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.post, pattern: path, middleware: middleware)
    }

    // MARK: Put
    @discardableResult
    public func put(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.put, pattern: path, handler: handler)
    }

    @discardableResult
    public func put(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.put, pattern: path, handler: handler)
    }

    public func put(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.put, pattern: path, middleware: middleware)
    }

    public func put(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.put, pattern: path, middleware: middleware)
    }

    // MARK: Delete
    @discardableResult
    public func delete(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.delete, pattern: path, handler: handler)
    }

    @discardableResult
    public func delete(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.delete, pattern: path, handler: handler)
    }

    public func delete(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.delete, pattern: path, middleware: middleware)
    }

    public func delete(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.delete, pattern: path, middleware: middleware)
    }

    // MARK: Options
    @discardableResult
    public func options(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.options, pattern: path, handler: handler)
    }

    @discardableResult
    public func options(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.options, pattern: path, handler: handler)
    }

    public func options(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.options, pattern: path, middleware: middleware)
    }

    public func options(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.options, pattern: path, middleware: middleware)
    }

    // MARK: Trace
    public func trace(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.trace, pattern: path, handler: handler)
    }

    public func trace(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.trace, pattern: path, handler: handler)
    }

    public func trace(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.trace, pattern: path, middleware: middleware)
    }

    public func trace(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.trace, pattern: path, middleware: middleware)
    }

    // MARK: Copy
    public func copy(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.copy, pattern: path, handler: handler)
    }

    public func copy(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.copy, pattern: path, handler: handler)
    }

    public func copy(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.copy, pattern: path, middleware: middleware)
    }

    public func copy(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.copy, pattern: path, middleware: middleware)
    }

    // MARK: Lock
    public func lock(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.lock, pattern: path, handler: handler)
    }

    public func lock(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.lock, pattern: path, handler: handler)
    }

    public func lock(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.lock, pattern: path, middleware: middleware)
    }

    public func lock(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.lock, pattern: path, middleware: middleware)
    }

    // MARK: MkCol
    public func mkCol(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.mkCol, pattern: path, handler: handler)
    }

    public func mkCol(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.mkCol, pattern: path, handler: handler)
    }

    public func mkCol(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.mkCol, pattern: path, middleware: middleware)
    }

    public func mkCol(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.mkCol, pattern: path, middleware: middleware)
    }

    // MARK: Move
    public func move(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.move, pattern: path, handler: handler)
    }

    public func move(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.move, pattern: path, handler: handler)
    }

    public func move(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.move, pattern: path, middleware: middleware)
    }

    public func move(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.move, pattern: path, middleware: middleware)
    }

    // MARK: Purge
    public func purge(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.purge, pattern: path, handler: handler)
    }

    public func purge(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.purge, pattern: path, handler: handler)
    }

    public func purge(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.purge, pattern: path, middleware: middleware)
    }

    public func purge(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.purge, pattern: path, middleware: middleware)
    }

    // MARK: PropFind
    public func propFind(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.propFind, pattern: path, handler: handler)
    }

    public func propFind(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.propFind, pattern: path, handler: handler)
    }

    public func propFind(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.propFind, pattern: path, middleware: middleware)
    }

    public func propFind(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.propFind, pattern: path, middleware: middleware)
    }

    // MARK: PropPatch
    public func propPatch(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.propPatch, pattern: path, handler: handler)
    }

    public func propPatch(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.propPatch, pattern: path, handler: handler)
    }

    public func propPatch(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.propPatch, pattern: path, middleware: middleware)
    }

    public func propPatch(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.propPatch, pattern: path, middleware: middleware)
    }

    // MARK: Unlock
    public func unlock(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.unlock, pattern: path, handler: handler)
    }

    public func unlock(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.unlock, pattern: path, handler: handler)
    }

    public func unlock(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.unlock, pattern: path, middleware: middleware)
    }

    public func unlock(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.unlock, pattern: path, middleware: middleware)
    }

    // MARK: Report
    public func report(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.report, pattern: path, handler: handler)
    }

    public func report(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.report, pattern: path, handler: handler)
    }

    public func report(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.report, pattern: path, middleware: middleware)
    }

    public func report(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.report, pattern: path, middleware: middleware)
    }

    // MARK: MkActivity
    public func mkActivity(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.mkActivity, pattern: path, handler: handler)
    }

    public func mkActivity(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.mkActivity, pattern: path, handler: handler)
    }

    public func mkActivity(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.mkActivity, pattern: path, middleware: middleware)
    }

    public func mkActivity(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.mkActivity, pattern: path, middleware: middleware)
    }

    // MARK: Checkout
    public func checkout(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.checkout, pattern: path, handler: handler)
    }

    public func checkout(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.checkout, pattern: path, handler: handler)
    }

    public func checkout(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.checkout, pattern: path, middleware: middleware)
    }

    public func checkout(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.checkout, pattern: path, middleware: middleware)
    }

    // MARK: Merge
    public func merge(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.merge, pattern: path, handler: handler)
    }

    public func merge(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.merge, pattern: path, handler: handler)
    }

    public func merge(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.merge, pattern: path, middleware: middleware)
    }

    public func merge(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.merge, pattern: path, middleware: middleware)
    }

    // MARK: MSearch
    public func mSearch(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.mSearch, pattern: path, handler: handler)
    }

    public func mSearch(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.mSearch, pattern: path, handler: handler)
    }

    public func mSearch(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.mSearch, pattern: path, middleware: middleware)
    }

    public func mSearch(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.mSearch, pattern: path, middleware: middleware)
    }

    // MARK: Notify
    public func notify(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.notify, pattern: path, handler: handler)
    }

    public func notify(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.notify, pattern: path, handler: handler)
    }

    public func notify(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.notify, pattern: path, middleware: middleware)
    }

    public func notify(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.notify, pattern: path, middleware: middleware)
    }

    // MARK: Subscribe
    public func subscribe(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.subscribe, pattern: path, handler: handler)
    }

    public func subscribe(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.subscribe, pattern: path, handler: handler)
    }

    public func subscribe(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.subscribe, pattern: path, middleware: middleware)
    }

    public func subscribe(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.subscribe, pattern: path, middleware: middleware)
    }

    // MARK: Unsubscribe
    public func unsubscribe(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.unsubscribe, pattern: path, handler: handler)
    }

    public func unsubscribe(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.unsubscribe, pattern: path, handler: handler)
    }

    public func unsubscribe(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.unsubscribe, pattern: path, middleware: middleware)
    }

    public func unsubscribe(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.unsubscribe, pattern: path, middleware: middleware)
    }

    // MARK: Patch
    @discardableResult
    public func patch(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.patch, pattern: path, handler: handler)
    }

    @discardableResult
    public func patch(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.patch, pattern: path, handler: handler)
    }

    public func patch(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.patch, pattern: path, middleware: middleware)
    }

    public func patch(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.patch, pattern: path, middleware: middleware)
    }

    // MARK: Search
    public func search(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.search, pattern: path, handler: handler)
    }

    public func search(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.search, pattern: path, handler: handler)
    }

    public func search(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.search, pattern: path, middleware: middleware)
    }

    public func search(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.search, pattern: path, middleware: middleware)
    }

    // MARK: Connect
    public func connect(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.connect, pattern: path, handler: handler)
    }

    public func connect(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.connect, pattern: path, handler: handler)
    }

    public func connect(_ path: String?=nil, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.connect, pattern: path, middleware: middleware)
    }

    public func connect(_ path: String?=nil, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.connect, pattern: path, middleware: middleware)
    }

    // MARK: error
    @discardableResult
    public func error(_ handler: RouterHandler...) -> Router {
        return routingHelper(.error, pattern: nil, handler: handler)
    }

    @discardableResult
    public func error(_ handler: [RouterHandler]) -> Router {
        return routingHelper(.error, pattern: nil, handler: handler)
    }

    public func error(_ middleware: RouterMiddleware...) -> Router {
        return routingHelper(.error, pattern: nil, middleware: middleware)
    }

    public func error(_ middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.error, pattern: nil, middleware: middleware)
    }
}