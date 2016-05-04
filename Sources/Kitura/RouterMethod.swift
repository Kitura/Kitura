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

///
/// Values for Router methods (Get, Post, Put, Delete, etc)
///
public enum RouterMethod: Int {
    
    case All, Get, Post, Put, Head, Delete, Options, Trace, Copy, Lock, MkCol, Move,
            Purge, PropFind, PropPatch, Unlock, Report, MkActivity, Checkout, Merge,
            MSearch, Notify, Subscribe, Unsubscribe, Patch, Search, Connect, Error, Unknown
    
    init(string: String) {
        switch string.lowercased() {
        case "all":
            self = .All
        case "get":
            self = .Get
        case "post":
            self = .Post
        case "put":
            self = .Put
        case "head":
            self = .Head
        case "delete":
            self = .Delete
        case "options":
            self = .Options
        case "trace":
            self = .Trace
        case "copy":
            self = .Copy
        case "lock":
            self = .Lock
        case "mkcol":
            self = .MkCol
        case "move":
            self = .Move
        case "purge":
            self = .Purge
        case "propfind":
            self = .PropFind
        case "proppatch":
            self = .PropPatch
        case "unlock":
            self = .Unlock
        case "report":
            self = .Report
        case "mkactivity":
            self = .MkActivity
        case "checkout":
            self = .Checkout
        case "merge":
            self = .Merge
        case "m-search":
            self = .MSearch
        case "notify":
            self = .Notify
        case "subscribe":
            self = .Subscribe
        case "unsubscribe":
            self = .Unsubscribe
        case "patch":
            self = .Patch
        case "search":
            self = .Search
        case "connect":
            self = .Connect
        case "error":
            self = .Error
        default:
            self = .Unknown
        }
    }
}