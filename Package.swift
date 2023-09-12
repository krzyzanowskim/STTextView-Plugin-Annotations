// swift-tools-version: 5.8

import PackageDescription

let pluginName = "Dummy"
let pluginTargetName = "\(pluginName)Plugin"

let package = Package(
    name: "STTextView-Plugin-\(pluginName)",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "STTextView\(pluginName)Plugin",
            targets: [pluginTargetName]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/STTextView", from: "0.8.12")
    ],
    targets: [
        .target(
            name: pluginTargetName,
            dependencies: [
                .product(name: "STTextView", package: "STTextView")
            ]
        )
    ]
)
