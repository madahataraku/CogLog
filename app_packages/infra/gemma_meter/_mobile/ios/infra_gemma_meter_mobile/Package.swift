// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "infra_gemma_meter_mobile",
  platforms: [
    .iOS("18.0"),
  ],
  products: [
    .library(name: "infra-gemma-meter-mobile", targets: ["infra_gemma_meter_mobile"]),
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
    // LiteRT-LM LFM VL runtime (CPU main/vision, MTP off). Same .litertlm as Android.
    .package(url: "https://github.com/google-ai-edge/LiteRT-LM", from: "0.19.1"),
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
      ],
      // Keep plugin sources on Swift 5 language mode under tools 6.0.
      swiftSettings: [
        .swiftLanguageMode(.v5),
      ]
    ),
  ]
)
