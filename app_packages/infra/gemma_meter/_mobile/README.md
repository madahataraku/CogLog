# infra_gemma_meter_mobile

Flutter plugin for meter-reading Gemma E2B via LiteRT-LM.

## Android

Gradle pulls `com.google.ai.edge.litertlm:litertlm-android` (concrete recent
release; product docs do not pin a model or SDK version). Models download into
`context.noBackupFilesDir/gemma_meter/` (OS backup excluded).

## iOS / LiteRTLM (SPM)

`ios/infra_gemma_meter_mobile/Package.swift` declares:

- FlutterFramework (Flutter-generated path for plugin packages)
- LiteRTLM from `https://github.com/google-ai-edge/LiteRT-LM` (`from: "0.12.0"`)

With Flutter Swift Package Manager enabled (default on Flutter 3.44+), the plugin
target links LiteRTLM and `canImport(LiteRTLM)` is true.

CocoaPods still compiles the same Sources as a fallback. Without LiteRTLM on the
pod target, availability stays `unavailable` until SPM is used.

Model files are stored under Application Support/`gemma_meter` with
`NSURLIsExcludedFromBackupKey`.
