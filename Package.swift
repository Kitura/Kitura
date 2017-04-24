// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "K2Spike",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/CHTTPParser.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/carlbrown/HTTPSketch.git", majorVersion: 0),
        .Package(url: "https://github.com/IBM-Swift/LoggerAPI.git", majorVersion: 1, minor: 7),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 7),
        .Package(url: "https://github.com/IBM-Swift/BlueSocket.git", majorVersion: 0, minor: 12),
        .Package(url: "https://github.com/IBM-Swift/CCurl.git", majorVersion: 0, minor: 2)
    ]
)

#if os(Linux)
    package.dependencies.append(
        .Package(url: "https://github.com/IBM-Swift/CEpoll.git", majorVersion: 0, minor: 1))
    package.dependencies.append(
        .Package(url: "https://github.com/IBM-Swift/BlueSignals.git", majorVersion: 0, minor: 9))
#endif
