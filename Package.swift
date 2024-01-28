// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "STTextView-Plugin-Annotations",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "STTextViewAnnotationsPlugin",
            targets: ["STAnnotationsPlugin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/STTextView", from: "0.8.25")
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
