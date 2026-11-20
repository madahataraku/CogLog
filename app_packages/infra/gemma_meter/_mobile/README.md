# infra_gemma_meter_mobile

Flutter plugin for meter-reading Gemma E2B (LiteRT-LM on Android and iOS).

## Android

Gradle pulls `com.google.ai.edge.litertlm:litertlm-android` (concrete recent
release; product docs do not pin a model or SDK version). Models download into
`context.noBackupFilesDir/gemma_meter/` (OS backup excluded).

Default model URL (ungated Hugging Face `litert-community` Gemma 4 E2B):

`https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm`

Engine backends (physical device): main `backend: gpu`, `visionBackend: gpu`,
and `speculativeDecodingConfig.mode: on` (MTP).

## iOS / LiteRTLM (SPM)

`ios/infra_gemma_meter_mobile/Package.swift` declares:

- FlutterFramework (Flutter-generated path for plugin packages)
- LiteRTLM from `https://github.com/google-ai-edge/LiteRT-LM` (`from: "0.19.1"`)

Requires iOS 18+. With Flutter Swift Package Manager enabled (default on
Flutter 3.44+), the plugin target links LiteRTLM and `canImport(LiteRTLM)`
is true. `app/ios/Runner.xcodeproj` also links LiteRTLM.

CocoaPods still compiles the same Sources as a fallback. Without LiteRTLM on
the pod target, availability stays `unavailable` until SPM is used.

Models are **not** bundled. The plugin downloads the same single `.litertlm`
(~2.59 GB) as Android into `Documents/Models/gemma_meter/`. The `Models` tree
is marked excluded from OS backup after prepare. Any leftover CoreMLLLM tree
at `Documents/Models/gemma4-e2b/` is deleted on prepare / availability.

Native availability reports configured backends: `backend=gpu` and
`visionBackend=gpu` (MTP enabled at engine init). `ready` requires
`Engine.initialize()` success in the current process (persisted prior
success is not enough). Undersized downloads are rejected; a plausible
on-disk artifact is kept across device-specific init failures.
