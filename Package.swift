// swift-tools-version:5.2

/**
 * Copyright IBM Corporation and the Kitura project authors 2016-2020
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

// Note: This is a change in previous behavior.  NIO is now the default.
if ProcessInfo.processInfo.environment["KITURA_NIO"] == "0" {
    kituraNetPackage = .package(url: "https://github.com/Kitura/Kitura-net.git", from: "3.0.1")
} else {
    kituraNetPackage = .package(url: "https://github.com/Kitura/Kitura-NIO.git", from: "3.0.1")
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
        .package(url: "https://github.com/Kitura/LoggerAPI.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", Version("0.0.0") ..< Version("2.0.0")),
        kituraNetPackage,
        .package(url: "https://github.com/Kitura/Kitura-TemplateEngine.git", from: "3.0.0"),
        .package(url: "https://github.com/Kitura/KituraContracts.git", from: "2.0.1"),
        .package(url: "https://github.com/Kitura/TypeDecoder.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Kitura",
            dependencies: [
                .product(name: "KituraNet", package: "Kitura-NIO"),
                .product(name: "KituraTemplateEngine", package: "Kitura-TemplateEngine"),
                .product(name: "Logging", package: "swift-log"),
                "KituraContracts", "TypeDecoder", "LoggerAPI",
                ]
        ),
        .testTarget(
            name: "KituraTests",
            dependencies: ["Kitura", "KituraContracts", "TypeDecoder", "LoggerAPI"]
        )
    ]
)
