// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "StorageKit",
  platforms: [
    .iOS(.v15),
    .macOS(.v12)
  ],
  products: [
    .library(
      name: "StorageKit",
      targets: ["StorageKit"]
    )
  ],
  targets: [
    .target(
      name: "StorageKit"
    ),
    .testTarget(
      name: "StorageKitTests",
      dependencies: ["StorageKit"]
    )
  ]
)
