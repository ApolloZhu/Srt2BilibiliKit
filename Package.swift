import PackageDescription

let package = Package(
    name: "Srt2BilibiliKit",
    targets: [
        Target(name: "Srt2BilibiliKit", dependencies: []),
        Target(name: "Srt2Bilibili-cli", dependencies: ["Srt2BilibiliKit"])
    ],
    exclude: ["Tests"]
)
