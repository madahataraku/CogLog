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
    // Core ML Gemma E2B runtime (ANE). Matches mlboydaisuke/gemma-4-E2B-coreml.
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
      ]
    ),
  ]
)
