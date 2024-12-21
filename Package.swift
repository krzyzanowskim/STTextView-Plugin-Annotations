// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "STTextView-Plugin-Annotations",
    platforms: [.macOS(.v12), .iOS(.v16), .macCatalyst(.v16)],
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
                .target(name: "STAnnotationsPluginAppKit", condition: .when(platforms: [.macOS])),
                .target(name: "STAnnotationsPluginUIKit", condition: .when(platforms: [.iOS, .macCatalyst]))
            ]
        ),
        .target(
            name: "STAnnotationsPluginShared",
            dependencies: [
                .product(name: "STTextView", package: "STTextView")
            ]
        ),
        .target(
            name: "STAnnotationsPluginAppKit",
            dependencies: [
                .target(name: "STAnnotationsPluginShared"),
                .product(name: "STTextView", package: "STTextView")
            ]
        ),
        .target(
            name: "STAnnotationsPluginUIKit",
            dependencies: [
                .target(name: "STAnnotationsPluginShared"),
                .product(name: "STTextView", package: "STTextView")
            ]
        )
    ]
)
