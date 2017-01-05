/*
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
 */

/// An enum to describe the HTTP method (Get, Post, Put, Delete, etc) of an HTTP
/// request. In general they match the actual HTTP methods by the same name. There
/// are two special ones, used by `Router` when building up the set of mappings
/// between paths and handlers or middleware. They are:
public enum RouterMethod: String {
    /// Signifies that the particular path mapping is not dependent on the HTTP method
    case all = "ALL"

    /// The HTTP method for an HTTP GET request
    case get = "GET"

    /// The HTTP method for an HTTP POST request
    case post = "POST"

    /// The HTTP method for an HTTP PUT request
    case put = "PUT"

    /// The HTTP method for an HTTP HEAD request
    case head = "HEAD"

    /// The HTTP method for an HTTP DELETE request
    case delete = "DELETE"

    /// The HTTP method for an HTTP OPTIONS request
    case options = "OPTIONS"

    /// The HTTP method for an HTTP TRACE request
    case trace = "TRACE"

    /// The HTTP method for an HTTP COPY request
    case copy = "COPY"

    /// The HTTP method for an HTTP LOCK request
    case lock = "LOCK"

    /// The HTTP method for an HTTP MKCOL request
    case mkCol = "MKCOL"

    /// The HTTP method for an HTTP MOVE request
    case move = "MOVE"

    /// The HTTP method for an HTTP PURGE request
    case purge = "PURGE"

    /// The HTTP method for an HTTP PROPFIND request
    case propFind = "PROPFIND"

    /// The HTTP method for an HTTP PROPPATCH request
    case propPatch = "PROPPATCH"

    /// The HTTP method for an HTTP UNLOCK request
    case unlock = "UNLOCK"

    /// The HTTP method for an HTTP REPORT request
    case report = "REPORT"

    /// The HTTP method for an HTTP MKACTIVITY request
    case mkActivity = "MKACTIVITY"

    /// The HTTP method for an HTTP CHECKOUT request
    case checkout = "CHECKOUT"

    /// The HTTP method for an HTTP MERGE request
    case merge = "MERGE"

    /// The HTTP method for an HTTP MSEARCH request
    case mSearch = "MSEARCH"

    /// The HTTP method for an HTTP NOTIFY request
    case notify = "NOTIFY"

    /// The HTTP method for an HTTP SUBSCRIBE request
    case subscribe = "SUBSCRIBE"

    /// The HTTP method for an HTTP UNSUBSCRIBE request
    case unsubscribe = "UNSUBSCRIBE"

    /// The HTTP method for an HTTP PATCH request
    case patch = "PATCH"

    /// The HTTP method for an HTTP SEARCH request
    case search = "SEARCH"

    /// The HTTP method for an HTTP CONNECT request
    case connect = "CONNECT"

    /// Used to mark an error handler in the list of router mappings.
    case error = "ERROR"

    /// Created when creating instances of this enum from a string that doesn't match any of the other
    /// values.
    case unknown = "UNKNOWN"

    /// Convert a string to a `RouterMethod` instance.
    ///
    /// Parameter fromRawValue: The string form of an HTTP method to convert to an `RouterMethod` enum.
    init(fromRawValue: String) {
        self = RouterMethod(rawValue: fromRawValue) ?? .unknown
    }
}

// MARK: CustomStringConvertible extension
extension RouterMethod: CustomStringConvertible {
    /// String format of an `HTTPMethod` instance.
    public var description: String {
        return self.rawValue
    }
}
