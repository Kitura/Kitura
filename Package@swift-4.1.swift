// swift-tools-version:4.0

/**
 * Copyright IBM Corporation 2016, 2017
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

import PackageDescription
import Foundation

var kituraNetPackage: Package.Dependency

if ProcessInfo.processInfo.environment["KITURA_NIO"] != nil {
    kituraNetPackage = .package(url: "https://github.com/IBM-Swift/Kitura-NIO.git", .branch("unix-domain-sockets-support"))
} else {
    kituraNetPackage = .package(url: "https://github.com/djones6/Kitura-net.git", .branch("master"))
}

let package = Package(
    name: "Kitura",
    products: [
        .library(
            name: "Kitura",
            targets: ["Kitura"]
        )
    ],
    dependencies: [
        kituraNetPackage,
        .package(url: "https://github.com/IBM-Swift/Kitura-TemplateEngine.git", from: "2.0.0"),
        .package(url: "https://github.com/IBM-Swift/KituraContracts.git", from: "1.0.0"),
        .package(url: "https://github.com/IBM-Swift/TypeDecoder.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "Kitura",
            dependencies: ["KituraNet", "KituraTemplateEngine", "KituraContracts", "TypeDecoder"]
        ),
        .testTarget(
            name: "KituraTests",
            dependencies: ["Kitura", "KituraContracts", "TypeDecoder"]
        )
    ]
)
