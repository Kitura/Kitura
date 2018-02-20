/*
 * Copyright IBM Corporation 2018
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

/// A dummy class to get the documentation for the HTTPStatusCode below to be emitted.
private class DummyHTTPStatusCodeClass {}

/// Bridge [HTTPStatusCode](http://ibm-swift.github.io/Kitura-net/Enums/HTTPStatusCode.html)
/// from [KituraNet](http://ibm-swift.github.io/Kitura-net) so that you only need to import
/// `Kitura` to access it.
public typealias HTTPStatusCode = KituraNet.HTTPStatusCode
