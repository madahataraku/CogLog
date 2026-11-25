# infra_gemma_meter_mobile

Flutter plugin for meter-reading LFM VL (LiteRT-LM on Android and iOS).

## Android

Gradle pulls `com.google.ai.edge.litertlm:litertlm-android` (concrete recent
release; product docs do not pin a model or SDK version). Models download into
`context.noBackupFilesDir/lfm_meter/` (OS backup excluded).

Default model URL (ungated Hugging Face `litert-community` LFM2.5-VL-1.6B fixB):

`https://huggingface.co/litert-community/LFM2.5-VL-1.6B/resolve/main/LFM2.5-VL-1.6B_int4_fixB.litertlm`

Engine backends (physical device): main `backend: gpu`, `visionBackend: cpu`,
and `speculativeDecodingConfig.mode: off` (MTP off).

Previous Gemma downloads under `noBackupFilesDir/gemma_meter/` are deleted on
prepare / availability.

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
(~1.30 GB) as Android into `Documents/Models/lfm_meter/`. The `Models` tree
is marked excluded from OS backup after prepare. Leftover trees at
`Documents/Models/gemma_meter/` and `Documents/Models/gemma4-e2b/` are deleted
on prepare / availability.

Native availability reports configured backends: `backend=cpu` and
`visionBackend=cpu` (MTP off at engine init; Metal GPU init is unreliable for
this family). `ready` requires `Engine.initialize()` success in the current
process (persisted prior success is not enough). Undersized downloads are
rejected; a plausible on-disk artifact is kept across device-specific init
failures.
