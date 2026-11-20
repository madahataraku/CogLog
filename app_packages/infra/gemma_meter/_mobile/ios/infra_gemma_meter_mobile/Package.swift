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
    // Core ML Gemma E2B runtime (ANE). Chunked n1024 + vision from HF.
    .package(url: "https://github.com/john-rocky/CoreML-LLM", branch: "main"),
  ],
  targets: [
    .target(
      name: "infra_gemma_meter_mobile",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
        .product(name: "CoreMLLLM", package: "CoreML-LLM"),
      ],
      resources: [
        .process("PrivacyInfo.xcprivacy"),
        .copy("ios_monolithic_download_manifest.json"),
      ],
      // Keep plugin sources on Swift 5 language mode under tools 6.0.
      swiftSettings: [
        .swiftLanguageMode(.v5),
      ]
    ),
  ]
)
