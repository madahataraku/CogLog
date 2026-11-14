// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "infra_gemma_meter_mobile",
  platforms: [
    .iOS("16.4"),
  ],
  products: [
    .library(name: "infra-gemma-meter-mobile", targets: ["infra_gemma_meter_mobile"]),
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
    // LiteRT-LM: product LiteRTLM. Floor 0.19.0 avoids older manifests with unsafeFlags.
    .package(url: "https://github.com/google-ai-edge/LiteRT-LM", from: "0.19.0"),
  ],
  targets: [
    .target(
      name: "infra_gemma_meter_mobile",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
        .product(name: "LiteRTLM", package: "LiteRT-LM"),
      ],
      resources: [
        .process("PrivacyInfo.xcprivacy"),
      ]
    ),
  ]
)
