// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
  name: "erxes_flutter_sdk",
  platforms: [
    .iOS("16.0")
  ],
  products: [
    .library(name: "erxes-flutter-sdk", targets: ["erxes_flutter_sdk"])
  ],
  dependencies: [
    // The native Erxes messenger SDK is distributed via SPM only.
    // Pin to the latest published version at build time.
    .package(
      url: "https://github.com/erxes/erxes-ios-sdk.git",
      exact: "0.30.13"
    )
  ],
  targets: [
    .target(
      name: "erxes_flutter_sdk",
      dependencies: [
        .product(name: "MessengerSDK", package: "erxes-ios-sdk")
      ]
    )
  ]
)
