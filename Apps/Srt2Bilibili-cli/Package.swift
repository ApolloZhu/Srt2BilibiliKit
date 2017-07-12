import PackageDescription

let package = Package(
    name: "Srt2Bilibili-cli",
    dependencies: [.Package("Srt2BilibiliKit", majorVersion: 1)],
    exclude: ["Tests"]
)
