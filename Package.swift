// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "STTextView-Plugin-Annotations-iOS",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "STTextViewAnnotationsPlugin",
            targets: ["STAnnotationsPlugin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/iXORTech/STTextView", branch: "feat/ios-plugin-loading")
    ],
    targets: [
        .target(
            name: "STAnnotationsPlugin",
            dependencies: [
                .product(name: "STTextView", package: "STTextView")
            ]
        )
    ]
)
