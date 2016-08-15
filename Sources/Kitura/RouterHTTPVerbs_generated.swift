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

    @discardableResult
    public func all(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.all, pattern: path, handler: handler)
    }

    @discardableResult
    public func all(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.all, pattern: path, handler: handler)
    }

    @discardableResult
    public func all(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.all, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func all(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.all, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
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

    @discardableResult
    public func get(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.get, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func get(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.get, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Head

    @discardableResult
    public func head(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.head, pattern: path, handler: handler)
    }

    @discardableResult
    public func head(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.head, pattern: path, handler: handler)
    }

    @discardableResult
    public func head(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.head, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func head(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.head, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
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

    @discardableResult
    public func post(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.post, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func post(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.post, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
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

    @discardableResult
    public func put(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.put, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func put(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.put, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
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

    @discardableResult
    public func delete(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.delete, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func delete(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.delete, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
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

    @discardableResult
    public func options(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.options, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func options(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.options, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Trace

    @discardableResult
    public func trace(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.trace, pattern: path, handler: handler)
    }

    @discardableResult
    public func trace(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.trace, pattern: path, handler: handler)
    }

    @discardableResult
    public func trace(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.trace, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func trace(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.trace, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Copy

    @discardableResult
    public func copy(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.copy, pattern: path, handler: handler)
    }

    @discardableResult
    public func copy(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.copy, pattern: path, handler: handler)
    }

    @discardableResult
    public func copy(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.copy, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func copy(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.copy, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Lock

    @discardableResult
    public func lock(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.lock, pattern: path, handler: handler)
    }

    @discardableResult
    public func lock(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.lock, pattern: path, handler: handler)
    }

    @discardableResult
    public func lock(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.lock, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func lock(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.lock, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: MkCol

    @discardableResult
    public func mkCol(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.mkCol, pattern: path, handler: handler)
    }

    @discardableResult
    public func mkCol(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.mkCol, pattern: path, handler: handler)
    }

    @discardableResult
    public func mkCol(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.mkCol, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func mkCol(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.mkCol, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Move

    @discardableResult
    public func move(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.move, pattern: path, handler: handler)
    }

    @discardableResult
    public func move(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.move, pattern: path, handler: handler)
    }

    @discardableResult
    public func move(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.move, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func move(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.move, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Purge

    @discardableResult
    public func purge(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.purge, pattern: path, handler: handler)
    }

    @discardableResult
    public func purge(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.purge, pattern: path, handler: handler)
    }

    @discardableResult
    public func purge(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.purge, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func purge(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.purge, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: PropFind

    @discardableResult
    public func propFind(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.propFind, pattern: path, handler: handler)
    }

    @discardableResult
    public func propFind(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.propFind, pattern: path, handler: handler)
    }

    @discardableResult
    public func propFind(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.propFind, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func propFind(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.propFind, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: PropPatch

    @discardableResult
    public func propPatch(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.propPatch, pattern: path, handler: handler)
    }

    @discardableResult
    public func propPatch(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.propPatch, pattern: path, handler: handler)
    }

    @discardableResult
    public func propPatch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.propPatch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func propPatch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.propPatch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Unlock

    @discardableResult
    public func unlock(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.unlock, pattern: path, handler: handler)
    }

    @discardableResult
    public func unlock(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.unlock, pattern: path, handler: handler)
    }

    @discardableResult
    public func unlock(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.unlock, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func unlock(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.unlock, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Report

    @discardableResult
    public func report(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.report, pattern: path, handler: handler)
    }

    @discardableResult
    public func report(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.report, pattern: path, handler: handler)
    }

    @discardableResult
    public func report(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.report, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func report(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.report, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: MkActivity

    @discardableResult
    public func mkActivity(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.mkActivity, pattern: path, handler: handler)
    }

    @discardableResult
    public func mkActivity(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.mkActivity, pattern: path, handler: handler)
    }

    @discardableResult
    public func mkActivity(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.mkActivity, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func mkActivity(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.mkActivity, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Checkout

    @discardableResult
    public func checkout(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.checkout, pattern: path, handler: handler)
    }

    @discardableResult
    public func checkout(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.checkout, pattern: path, handler: handler)
    }

    @discardableResult
    public func checkout(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.checkout, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func checkout(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.checkout, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Merge

    @discardableResult
    public func merge(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.merge, pattern: path, handler: handler)
    }

    @discardableResult
    public func merge(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.merge, pattern: path, handler: handler)
    }

    @discardableResult
    public func merge(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.merge, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func merge(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.merge, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: MSearch

    @discardableResult
    public func mSearch(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.mSearch, pattern: path, handler: handler)
    }

    @discardableResult
    public func mSearch(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.mSearch, pattern: path, handler: handler)
    }

    @discardableResult
    public func mSearch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.mSearch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func mSearch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.mSearch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Notify

    @discardableResult
    public func notify(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.notify, pattern: path, handler: handler)
    }

    @discardableResult
    public func notify(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.notify, pattern: path, handler: handler)
    }

    @discardableResult
    public func notify(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.notify, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func notify(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.notify, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Subscribe

    @discardableResult
    public func subscribe(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.subscribe, pattern: path, handler: handler)
    }

    @discardableResult
    public func subscribe(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.subscribe, pattern: path, handler: handler)
    }

    @discardableResult
    public func subscribe(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.subscribe, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func subscribe(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.subscribe, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Unsubscribe

    @discardableResult
    public func unsubscribe(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.unsubscribe, pattern: path, handler: handler)
    }

    @discardableResult
    public func unsubscribe(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.unsubscribe, pattern: path, handler: handler)
    }

    @discardableResult
    public func unsubscribe(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.unsubscribe, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func unsubscribe(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.unsubscribe, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
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

    @discardableResult
    public func patch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.patch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func patch(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.patch, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Search

    @discardableResult
    public func search(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.search, pattern: path, handler: handler)
    }

    @discardableResult
    public func search(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.search, pattern: path, handler: handler)
    }

    @discardableResult
    public func search(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.search, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func search(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.search, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
    // MARK: Connect

    @discardableResult
    public func connect(_ path: String?=nil, handler: RouterHandler...) -> Router {
        return routingHelper(.connect, pattern: path, handler: handler)
    }

    @discardableResult
    public func connect(_ path: String?=nil, handler: [RouterHandler]) -> Router {
        return routingHelper(.connect, pattern: path, handler: handler)
    }

    @discardableResult
    public func connect(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: RouterMiddleware...) -> Router {
        return routingHelper(.connect, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }

    @discardableResult
    public func connect(_ path: String?=nil, allowPartialMatch: Bool = true, middleware: [RouterMiddleware]) -> Router {
        return routingHelper(.connect, pattern: path, allowPartialMatch: allowPartialMatch, middleware: middleware)
    }
}
