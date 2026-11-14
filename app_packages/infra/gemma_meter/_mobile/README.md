# infra_gemma_meter_mobile

Flutter plugin for meter-reading Gemma E2B via LiteRT-LM.

## Android

Gradle pulls `com.google.ai.edge.litertlm:litertlm-android` (concrete recent
release; product docs do not pin a model or SDK version). Models download into
`context.noBackupFilesDir/gemma_meter/` (OS backup excluded).

## iOS / LiteRTLM (SPM)

CocoaPods podspecs do not provide a stable `swift_package` hook for this
Flutter plugin. Add LiteRTLM with Swift Package Manager in the app project:

1. Xcode → File → Add Package Dependencies…
2. URL: `https://github.com/google-ai-edge/LiteRT-LM`
3. Rule: from `0.12.0`
4. Product: `LiteRTLM` → Runner target

Until the package is linked, `GemmaMeterPlugin.swift` builds with
`#if canImport(LiteRTLM)` and reports `unavailable` / prepare `generic`.

Model files are stored under Application Support/`gemma_meter` with
`NSURLIsExcludedFromBackupKey`.
