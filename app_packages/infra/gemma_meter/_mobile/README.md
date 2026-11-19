# infra_gemma_meter_mobile

Flutter plugin for meter-reading Gemma E2B.

## Android

Gradle pulls `com.google.ai.edge.litertlm:litertlm-android` (concrete recent
release; product docs do not pin a model or SDK version). Models download into
`context.noBackupFilesDir/gemma_meter/` (OS backup excluded).

Default model URL (ungated Hugging Face `litert-community` Gemma 4 E2B):

`https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm`

Engine backends (physical device): main `backend: cpu`, `visionBackend: gpu`
(as reported by the Android plugin).

## iOS / CoreMLLLM (SPM)

`ios/infra_gemma_meter_mobile/Package.swift` declares:

- FlutterFramework (Flutter-generated path for plugin packages)
- CoreMLLLM from `https://github.com/john-rocky/CoreML-LLM` (`branch: "main"`)

Requires iOS 18+. With Flutter Swift Package Manager enabled (default on
Flutter 3.44+), the plugin target links CoreMLLLM and `canImport(CoreMLLLM)`
is true.

CocoaPods still compiles the same Sources as a fallback. Without CoreMLLLM on
the pod target, availability stays `unavailable` until SPM is used.

Models are **not** bundled. The plugin downloads a lean monolithic set from
Hugging Face `smdesai/gemma-4-E2B-coreml` (`main`): `model.mlpackage`,
`vision.mlpackage`, `hf_model/`, and `model_config.json` (~2.9 GB) into
`Documents/Models/gemma4-e2b/`. Chunked layouts / `vision_video` / `audio` /
PLE sidecars are not fetched (so CoreMLLLM uses the monolithic load path).
The `Models` tree is marked excluded from OS backup after prepare.

Debug availability reports the compute units that actually loaded:
`backend=ane` or `backend=gpu` (ANE first, then `.cpuAndGPU` if the
Neural Engine execution plan fails), and `visionBackend=gpu` for the
lean `vision.mlpackage` path.
