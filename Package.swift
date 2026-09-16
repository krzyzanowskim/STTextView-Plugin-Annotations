// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "STTextView-Plugin-Annotations",
    platforms: [.macOS(.v14), .iOS(.v16), .macCatalyst(.v16)],
    products: [
        .library(
            name: "STTextViewAnnotationsPlugin",
            targets: ["STAnnotationsPlugin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/STTextView", branch: "main")
    ],
    targets: [
        .target(
            name: "STAnnotationsPlugin",
            dependencies: [
                .product(name: "STTextView", package: "STTextView")
            ]
        ),
        .testTarget(
            name: "STAnnotationsPluginTests",
            dependencies: [
                .target(name: "STAnnotationsPlugin")
            ]
        )
    ]
)
