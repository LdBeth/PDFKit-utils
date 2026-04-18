// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "PDFTools",
  platforms: [.macOS(.v14)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "PDFToolsCore",
      dependencies: [],
      path: "Sources/PDFToolsCore"
    ),
    .executableTarget(
      name: "pdftotext",
      dependencies: [
        "PDFToolsCore",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      path: "Sources/pdftotext"
    ),
    .executableTarget(
      name: "pdftoppm",
      dependencies: [
        "PDFToolsCore",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      path: "Sources/pdftoppm"
    ),
    .testTarget(
      name: "PDFToolsCoreTests",
      dependencies: ["PDFToolsCore"],
      path: "Tests/PDFToolsCoreTests"
    ),
  ]
)
