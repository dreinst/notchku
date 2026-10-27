// swift-tools-version:5.9
import PackageDescription
let package = Package(
    name: "NotchKu",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/Lakr233/ColorfulX", from: "5.7.0"),
        .package(url: "https://github.com/EmergeTools/Pow", from: "1.0.6"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.3.0"),
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin-Modern", from: "1.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "NotchKu",
            dependencies: [
                "ColorfulX", "Pow",
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "LaunchAtLogin", package: "LaunchAtLogin-Modern"),
            ],
            path: "Sources/NotchKu",
            exclude: ["Assets.xcassets", "Info.plist", "NotchDrop.entitlements", "InfoPlist.xcstrings", "Localizable.xcstrings"],
            swiftSettings: [.unsafeFlags(["-swift-version", "5"])]
        ),
    ]
)
