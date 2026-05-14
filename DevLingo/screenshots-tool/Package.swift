// swift-tools-version: 6.0
import PackageDescription

// IMPORTANT: keep `swift-tools-version: 6.0` and `.macOS(.v15)` — they are
// required by `MeshGradient` and other modern SwiftUI APIs the kit may use.
// Downgrading either will fail to compile.

let package = Package(
    name: "DevLingoScreenshots",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "DevLingoScreenshots",
            targets: ["DevLingoScreenshots"]
        )
    ],
    dependencies: [
        // Path resolves from <App>/<App>/screenshots-tool to the shared kit.
        // If your nesting is different, adjust the number of `..` segments.
        .package(path: "../../../GambitStudioAppCreator/GambitScreenshotKit")
    ],
    targets: [
        .executableTarget(
            name: "DevLingoScreenshots",
            dependencies: [
                .product(name: "GambitScreenshotKit", package: "GambitScreenshotKit")
            ],
            path: "Sources/DevLingoScreenshots",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
