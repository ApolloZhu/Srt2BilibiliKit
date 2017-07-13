import PackageDescription

let package = Package(
    name: "Srt2Bilibili-cli",
    dependencies: [.Package(url: "https://github.com/ApolloZhu/Srt2BilibiliKit", majorVersion: 1)],
    exclude: ["Tests"]
)
