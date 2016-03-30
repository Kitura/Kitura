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
import KituraSys

public class RouterGroup {

    private (set) var router: Router
    private var path: String?

    ///
    /// Initializes a Router Group
    ///
    /// - Parameter router: a Router object of current Group
    /// - Parameter path: a Path for Group routes
    ///
    /// - Returns: a Router Group instance
    ///
    public init(router: Router, path: String?) {
        self.router = router
        self.path = path
    }

    // MARK: RouterGroup
    public func group(path: String?=nil) -> RouterGroup {
        let group = RouterGroup(router: self.router, path: path)
        return group
    }

    // MARK: All
    public func all(handler: RouterHandler...) -> RouterGroup {
        router.all(path, handler: handler)
        return self
    }

    public func all(handler: [RouterHandler]) -> RouterGroup {
        router.all(path, handler: handler)
        return self
    }

    public func all(middleware: RouterMiddleware...) -> RouterGroup {
        router.all(path, middleware: middleware)
        return self
    }

    public func all(middleware: [RouterMiddleware]) -> RouterGroup {
        router.all(path, middleware: middleware)
        return self
    }

    // MARK: Get
    public func get(handler: RouterHandler...) -> RouterGroup {
        router.get(path, handler: handler)
        return self
    }

    public func get(handler: [RouterHandler]) -> RouterGroup {
        router.get(path, handler: handler)
        return self
    }

    public func get(middleware: RouterMiddleware...) -> RouterGroup {
        router.get(path, middleware: middleware)
        return self
    }

    public func get(middleware: [RouterMiddleware]) -> RouterGroup {
        router.get(path, middleware: middleware)
        return self
    }

    // MARK: Head
    public func head(handler: RouterHandler...) -> RouterGroup {
        router.head(path, handler: handler)
        return self
    }

    public func head(handler: [RouterHandler]) -> RouterGroup {
        router.head(path, handler: handler)
        return self
    }

    public func head(middleware: RouterMiddleware...) -> RouterGroup {
        router.head(path, middleware: middleware)
        return self
    }

    public func head(middleware: [RouterMiddleware]) -> RouterGroup {
        router.head(path, middleware: middleware)
        return self
    }

    // MARK: Post
    public func post(handler: RouterHandler...) -> RouterGroup {
        router.post(path, handler: handler)
        return self
    }

    public func post(handler: [RouterHandler]) -> RouterGroup {
        router.post(path, handler: handler)
        return self
    }

    public func post(middleware: RouterMiddleware...) -> RouterGroup {
        router.post(path, middleware: middleware)
        return self
    }

    public func post(middleware: [RouterMiddleware]) -> RouterGroup {
        router.post(path, middleware: middleware)
        return self
    }

    // MARK: Put
    public func put(handler: RouterHandler...) -> RouterGroup {
        router.put(path, handler: handler)
        return self
    }

    public func put(handler: [RouterHandler]) -> RouterGroup {
        router.put(path, handler: handler)
        return self
    }

    public func put(middleware: RouterMiddleware...) -> RouterGroup {
        router.put(path, middleware: middleware)
        return self
    }

    public func put(middleware: [RouterMiddleware]) -> RouterGroup {
        router.put(path, middleware: middleware)
        return self
    }

    // MARK: Delete
    public func delete(handler: RouterHandler...) -> RouterGroup {
        router.delete(path, handler: handler)
        return self
    }

    public func delete(handler: [RouterHandler]) -> RouterGroup {
        router.delete(path, handler: handler)
        return self
    }

    public func delete(middleware: RouterMiddleware...) -> RouterGroup {
        router.delete(path, middleware: middleware)
        return self
    }

    public func delete(middleware: [RouterMiddleware]) -> RouterGroup {
        router.delete(path, middleware: middleware)
        return self
    }

    // MARK: Options
    public func options(handler: RouterHandler...) -> RouterGroup {
        router.options(path, handler: handler)
        return self
    }

    public func options(handler: [RouterHandler]) -> RouterGroup {
        router.options(path, handler: handler)
        return self
    }

    public func options(middleware: RouterMiddleware...) -> RouterGroup {
        router.options(path, middleware: middleware)
        return self
    }

    public func options(middleware: [RouterMiddleware]) -> RouterGroup {
        router.options(path, middleware: middleware)
        return self
    }

    // MARK: Trace
    public func trace(handler: RouterHandler...) -> RouterGroup {
        router.trace(path, handler: handler)
        return self
    }

    public func trace(handler: [RouterHandler]) -> RouterGroup {
        router.trace(path, handler: handler)
        return self
    }

    public func trace(middleware: RouterMiddleware...) -> RouterGroup {
        router.trace(path, middleware: middleware)
        return self
    }

    public func trace(middleware: [RouterMiddleware]) -> RouterGroup {
        router.trace(path, middleware: middleware)
        return self
    }

    // MARK: Copy
    public func copy(handler: RouterHandler...) -> RouterGroup {
        router.copy(path, handler: handler)
        return self
    }

    public func copy(handler: [RouterHandler]) -> RouterGroup {
        router.copy(path, handler: handler)
        return self
    }

    public func copy(middleware: RouterMiddleware...) -> RouterGroup {
        router.copy(path, middleware: middleware)
        return self
    }

    public func copy(middleware: [RouterMiddleware]) -> RouterGroup {
        router.copy(path, middleware: middleware)
        return self
    }

    // MARK: Lock
    public func lock(handler: RouterHandler...) -> RouterGroup {
        router.lock(path, handler: handler)
        return self
    }

    public func lock(handler: [RouterHandler]) -> RouterGroup {
        router.lock(path, handler: handler)
        return self
    }

    public func lock(middleware: RouterMiddleware...) -> RouterGroup {
        router.lock(path, middleware: middleware)
        return self
    }

    public func lock(middleware: [RouterMiddleware]) -> RouterGroup {
        router.lock(path, middleware: middleware)
        return self
    }

    // MARK: MkCol
    public func mkCol(handler: RouterHandler...) -> RouterGroup {
        router.mkCol(path, handler: handler)
        return self
    }

    public func mkCol(handler: [RouterHandler]) -> RouterGroup {
        router.mkCol(path, handler: handler)
        return self
    }

    public func mkCol(middleware: RouterMiddleware...) -> RouterGroup {
        router.mkCol(path, middleware: middleware)
        return self
    }

    public func mkCol(middleware: [RouterMiddleware]) -> RouterGroup {
        router.mkCol(path, middleware: middleware)
        return self
    }

    // MARK: Move
    public func move(handler: RouterHandler...) -> RouterGroup {
        router.move(path, handler: handler)
        return self
    }

    public func move(handler: [RouterHandler]) -> RouterGroup {
        router.move(path, handler: handler)
        return self
    }

    public func move(middleware: RouterMiddleware...) -> RouterGroup {
        router.move(path, middleware: middleware)
        return self
    }

    public func move(middleware: [RouterMiddleware]) -> RouterGroup {
        router.move(path, middleware: middleware)
        return self
    }

    // MARK: Purge
    public func purge(handler: RouterHandler...) -> RouterGroup {
        router.purge(path, handler: handler)
        return self
    }

    public func purge(handler: [RouterHandler]) -> RouterGroup {
        router.purge(path, handler: handler)
        return self
    }

    public func purge(middleware: RouterMiddleware...) -> RouterGroup {
        router.purge(path, middleware: middleware)
        return self
    }

    public func purge(middleware: [RouterMiddleware]) -> RouterGroup {
        router.purge(path, middleware: middleware)
        return self
    }

    // MARK: PropFind
    public func propFind(handler: RouterHandler...) -> RouterGroup {
        router.propFind(path, handler: handler)
        return self
    }

    public func propFind(handler: [RouterHandler]) -> RouterGroup {
        router.propFind(path, handler: handler)
        return self
    }

    public func propFind(middleware: RouterMiddleware...) -> RouterGroup {
        router.propFind(path, middleware: middleware)
        return self
    }

    public func propFind(middleware: [RouterMiddleware]) -> RouterGroup {
        router.propFind(path, middleware: middleware)
        return self
    }

    // MARK: PropPatch
    public func propPatch(handler: RouterHandler...) -> RouterGroup {
        router.propPatch(path, handler: handler)
        return self
    }

    public func propPatch(handler: [RouterHandler]) -> RouterGroup {
        router.propPatch(path, handler: handler)
        return self
    }

    public func propPatch(middleware: RouterMiddleware...) -> RouterGroup {
        router.propPatch(path, middleware: middleware)
        return self
    }

    public func propPatch(middleware: [RouterMiddleware]) -> RouterGroup {
        router.propPatch(path, middleware: middleware)
        return self
    }

    // MARK: Unlock
    public func unlock(handler: RouterHandler...) -> RouterGroup {
        router.unlock(path, handler: handler)
        return self
    }

    public func unlock(handler: [RouterHandler]) -> RouterGroup {
        router.unlock(path, handler: handler)
        return self
    }

    public func unlock(middleware: RouterMiddleware...) -> RouterGroup {
        router.unlock(path, middleware: middleware)
        return self
    }

    public func unlock(middleware: [RouterMiddleware]) -> RouterGroup {
        router.unlock(path, middleware: middleware)
        return self
    }

    // MARK: Report
    public func report(handler: RouterHandler...) -> RouterGroup {
        router.report(path, handler: handler)
        return self
    }

    public func report(handler: [RouterHandler]) -> RouterGroup {
        router.report(path, handler: handler)
        return self
    }

    public func report(middleware: RouterMiddleware...) -> RouterGroup {
        router.report(path, middleware: middleware)
        return self
    }

    public func report(middleware: [RouterMiddleware]) -> RouterGroup {
        router.report(path, middleware: middleware)
        return self
    }

    // MARK: MkActivity
    public func mkActivity(handler: RouterHandler...) -> RouterGroup {
        router.mkActivity(path, handler: handler)
        return self
    }

    public func mkActivity(handler: [RouterHandler]) -> RouterGroup {
        router.mkActivity(path, handler: handler)
        return self
    }

    public func mkActivity(middleware: RouterMiddleware...) -> RouterGroup {
        router.mkActivity(path, middleware: middleware)
        return self
    }

    public func mkActivity(middleware: [RouterMiddleware]) -> RouterGroup {
        router.mkActivity(path, middleware: middleware)
        return self
    }

    // MARK: Checkout
    public func checkout(handler: RouterHandler...) -> RouterGroup {
        router.checkout(path, handler: handler)
        return self
    }

    public func checkout(handler: [RouterHandler]) -> RouterGroup {
        router.checkout(path, handler: handler)
        return self
    }

    public func checkout(middleware: RouterMiddleware...) -> RouterGroup {
        router.checkout(path, middleware: middleware)
        return self
    }

    public func checkout(middleware: [RouterMiddleware]) -> RouterGroup {
        router.checkout(path, middleware: middleware)
        return self
    }

    // MARK: Merge
    public func merge(handler: RouterHandler...) -> RouterGroup {
        router.merge(path, handler: handler)
        return self
    }

    public func merge(handler: [RouterHandler]) -> RouterGroup {
        router.merge(path, handler: handler)
        return self
    }

    public func merge(middleware: RouterMiddleware...) -> RouterGroup {
        router.merge(path, middleware: middleware)
        return self
    }

    public func merge(middleware: [RouterMiddleware]) -> RouterGroup {
        router.merge(path, middleware: middleware)
        return self
    }

    // MARK: MSearch
    public func mSearch(handler: RouterHandler...) -> RouterGroup {
        router.mSearch(path, handler: handler)
        return self
    }

    public func mSearch(handler: [RouterHandler]) -> RouterGroup {
        router.mSearch(path, handler: handler)
        return self
    }

    public func mSearch(middleware: RouterMiddleware...) -> RouterGroup {
        router.mSearch(path, middleware: middleware)
        return self
    }

    public func mSearch(middleware: [RouterMiddleware]) -> RouterGroup {
        router.mSearch(path, middleware: middleware)
        return self
    }

    // MARK: Notify
    public func notify(handler: RouterHandler...) -> RouterGroup {
        router.notify(path, handler: handler)
        return self
    }

    public func notify(handler: [RouterHandler]) -> RouterGroup {
        router.notify(path, handler: handler)
        return self
    }

    public func notify(middleware: RouterMiddleware...) -> RouterGroup {
        router.notify(path, middleware: middleware)
        return self
    }

    public func notify(middleware: [RouterMiddleware]) -> RouterGroup {
        router.notify(path, middleware: middleware)
        return self
    }

    // MARK: Subscribe
    public func subscribe(handler: RouterHandler...) -> RouterGroup {
        router.subscribe(path, handler: handler)
        return self
    }

    public func subscribe(handler: [RouterHandler]) -> RouterGroup {
        router.subscribe(path, handler: handler)
        return self
    }

    public func subscribe(middleware: RouterMiddleware...) -> RouterGroup {
        router.subscribe(path, middleware: middleware)
        return self
    }

    public func subscribe(middleware: [RouterMiddleware]) -> RouterGroup {
        router.subscribe(path, middleware: middleware)
        return self
    }

    // MARK: Unsubscribe
    public func unsubscribe(handler: RouterHandler...) -> RouterGroup {
        router.unsubscribe(path, handler: handler)
        return self
    }

    public func unsubscribe(handler: [RouterHandler]) -> RouterGroup {
        router.unsubscribe(path, handler: handler)
        return self
    }

    public func unsubscribe(middleware: RouterMiddleware...) -> RouterGroup {
        router.unsubscribe(path, middleware: middleware)
        return self
    }

    public func unsubscribe(middleware: [RouterMiddleware]) -> RouterGroup {
        router.unsubscribe(path, middleware: middleware)
        return self
    }

    // MARK: Patch
    public func patch(handler: RouterHandler...) -> RouterGroup {
        router.patch(path, handler: handler)
        return self
    }

    public func patch(handler: [RouterHandler]) -> RouterGroup {
        router.patch(path, handler: handler)
        return self
    }

    public func patch(middleware: RouterMiddleware...) -> RouterGroup {
        router.patch(path, middleware: middleware)
        return self
    }

    public func patch(middleware: [RouterMiddleware]) -> RouterGroup {
        router.patch(path, middleware: middleware)
        return self
    }

    // MARK: Search
    public func search(handler: RouterHandler...) -> RouterGroup {
        router.search(path, handler: handler)
        return self
    }

    public func search(handler: [RouterHandler]) -> RouterGroup {
        router.search(path, handler: handler)
        return self
    }

    public func search(middleware: RouterMiddleware...) -> RouterGroup {
        router.search(path, middleware: middleware)
        return self
    }

    public func search(middleware: [RouterMiddleware]) -> RouterGroup {
        router.search(path, middleware: middleware)
        return self
    }

    // MARK: Connect
    public func connect(handler: RouterHandler...) -> RouterGroup {
        router.connect(path, handler: handler)
        return self
    }

    public func connect(handler: [RouterHandler]) -> RouterGroup {
        router.connect(path, handler: handler)
        return self
    }

    public func connect(middleware: RouterMiddleware...) -> RouterGroup {
        router.connect(path, middleware: middleware)
        return self
    }

    public func connect(middleware: [RouterMiddleware]) -> RouterGroup {
        router.connect(path, middleware: middleware)
        return self
    }
}
