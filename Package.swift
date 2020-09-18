// swift-tools-version:5.0

import PackageDescription
import Foundation

var kituraNetPackage: Package.Dependency

if ProcessInfo.processInfo.environment["KITURA_NIO"] != nil {
    kituraNetPackage = .package(url: "https://github.com/Kitura/Kitura-NIO.git", from: "2.3.0")
} else {
    kituraNetPackage = .package(url: "https://github.com/Kitura/Kitura-net.git", from: "2.4.0")
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
        .package(url: "https://github.com/Kitura/LoggerAPI.git", from: "1.9.0"),
        .package(url: "https://github.com/apple/swift-log.git", Version("0.0.0") ..< Version("2.0.0")),
        kituraNetPackage,
        .package(url: "https://github.com/Kitura/Kitura-TemplateEngine.git", from: "2.0.0"),
        .package(url: "https://github.com/Kitura/KituraContracts.git", from: "1.0.0"),
        .package(url: "https://github.com/Kitura/TypeDecoder.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "Kitura",
            dependencies: ["KituraNet", "KituraTemplateEngine", "KituraContracts", "TypeDecoder", "LoggerAPI", "Logging"]
        ),
        .testTarget(
            name: "KituraTests",
            dependencies: ["Kitura", "KituraContracts", "TypeDecoder", "LoggerAPI"]
        )
    ]
)
