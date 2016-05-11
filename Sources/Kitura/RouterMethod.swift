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
public enum RouterMethod: String {
    case all = "ALL"
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case head = "HEAD"
    case delete = "DELETE"
    case options = "OPTIONS"
    case trace = "TRACE"
    case copy = "COPY"
    case lock = "LOCK"
    case mkCol = "MKCOL"
    case move = "MOVE"
    case purge = "PURGE"
    case propFind = "PROPFIND"
    case propPatch = "PROPPATCH"
    case unlock = "UNLOCK"
    case report = "REPORT"
    case mkActivity = "MKACTIVITY"
    case checkout = "CHECKOUT"
    case merge = "MERGE"
    case mSearch = "MSEARCH"
    case notify = "NOTIFY"
    case subscribe = "SUBSCRIBE"
    case unsubscribe = "UNSUBSCRIBE"
    case patch = "PATCH"
    case search = "SEARCH"
    case connect = "CONNECT"
    case error = "ERROR"
    case unknown = "UNKNOWN"

    init(fromRawValue: String){
        self = RouterMethod(rawValue: fromRawValue) ?? .unknown
    }    
}