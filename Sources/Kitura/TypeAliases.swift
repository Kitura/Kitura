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

import KituraContracts

/*
  This file declares public typealiases for types stored in the dependencies.
  The purpose is to expose these types at the top level without having to import a specific dependency.
*/

/// Bridge [QueryParams](https://github.com/IBM-Swift/KituraContracts/blob/master/Sources/KituraContracts/Contracts.swift#L525)
/// from [KituraContracts](https://ibm-swift.github.io/KituraContracts) so that you only need to import
/// `Kitura` to access it.
public typealias QueryParams = KituraContracts.QueryParams

/// Bridge [Identifier](https://github.com/IBM-Swift/KituraContracts/blob/master/Sources/KituraContracts/Contracts.swift#L568)
/// from [KituraContracts](https://ibm-swift.github.io/KituraContracts) so that you only need to import
/// `Kitura` to access it.
public typealias Identifier = KituraContracts.Identifier


/// Bridge [GreaterThan](https://github.com/IBM-Swift/KituraContracts/blob/master/Sources/KituraContracts/Contracts.swift#L1159)
/// from [KituraContracts](https://ibm-swift.github.io/KituraContracts) so that you only need to import
/// `Kitura` to access it.
public typealias GreaterThan = KituraContracts.GreaterThan

/// Bridge [LowerThan](https://github.com/IBM-Swift/KituraContracts/blob/master/Sources/KituraContracts/Contracts.swift#L1254)
/// from [KituraContracts](https://ibm-swift.github.io/KituraContracts) so that you only need to import
/// `Kitura` to access it.
public typealias LowerThan = KituraContracts.LowerThan

/// Bridge [GreaterThanOrEqual](https://github.com/IBM-Swift/KituraContracts/blob/master/Sources/KituraContracts/Contracts.swift#L1206)
/// from [KituraContracts](https://ibm-swift.github.io/KituraContracts) so that you only need to import
/// `Kitura` to access it.
public typealias GreaterThanOrEqual = KituraContracts.GreaterThanOrEqual

/// Bridge [LowerThanOrEqual](https://github.com/IBM-Swift/KituraContracts/blob/master/Sources/KituraContracts/Contracts.swift#L1301)
/// from [KituraContracts](https://ibm-swift.github.io/KituraContracts) so that you only need to import
/// `Kitura` to access it.
public typealias LowerThanOrEqual = KituraContracts.LowerThanOrEqual

/// Bridge [InclusiveRange](https://github.com/IBM-Swift/KituraContracts/blob/master/Sources/KituraContracts/Contracts.swift#L1348)
/// from [KituraContracts](https://ibm-swift.github.io/KituraContracts) so that you only need to import
/// `Kitura` to access it.
public typealias InclusiveRange = KituraContracts.InclusiveRange

/// Bridge [ExclusiveRange](https://github.com/IBM-Swift/KituraContracts/blob/master/Sources/KituraContracts/Contracts.swift#L1402)
/// from [KituraContracts](https://ibm-swift.github.io/KituraContracts) so that you only need to import
/// `Kitura` to access it.
public typealias ExclusiveRange = KituraContracts.ExclusiveRange

/// Bridge [Pagination](https://github.com/IBM-Swift/KituraContracts/blob/master/Sources/KituraContracts/Contracts.swift#L1057)
/// from [KituraContracts](https://ibm-swift.github.io/KituraContracts) so that you only need to import
/// `Kitura` to access it.
public typealias Pagination = KituraContracts.Pagination

/// Bridge [Ordering](https://github.com/IBM-Swift/KituraContracts/blob/master/Sources/KituraContracts/Contracts.swift#L983)
/// from [KituraContracts](https://ibm-swift.github.io/KituraContracts) so that you only need to import
/// `Kitura` to access it.
public typealias Ordering = KituraContracts.Ordering

/// Bridge [Order](https://github.com/IBM-Swift/KituraContracts/blob/master/Sources/KituraContracts/Contracts.swift#L983)
/// from [KituraContracts](https://ibm-swift.github.io/KituraContracts) so that you only need to import
/// `Kitura` to access it.
public typealias Order = KituraContracts.Order
