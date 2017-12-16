// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Srt2BilibiliKit",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Srt2BilibiliKit",
            targets: ["Srt2BilibiliKit"]),
        .executable(
            name: "Srt2Bilibili-cli",
            targets: ["Srt2Bilibili-cli"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        // .package(url: "https://github.com/ApolloZhu/BilibiliKit", .branch("master")),
        // .package(url: "https://github.com/ApolloZhu/swift_qrcodejs", .branch("master")),
        .package(url: "../BilibiliKit", .branch("master")),
        .package(url: "../swift_qrcodejs", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Srt2BilibiliKit",
            dependencies: ["BilibiliKit"]),
        .target(
            name: "Srt2Bilibili-cli",
            dependencies: ["BilibiliKit", "Srt2BilibiliKit", "swift_qrcodejs"]),
        .testTarget(
            name: "Srt2BilibiliKitTests",
            dependencies: ["Srt2BilibiliKit"]),
    ]
)
