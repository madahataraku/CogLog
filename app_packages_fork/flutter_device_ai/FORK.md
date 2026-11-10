# Fork notes

Upstream: `flutter_device_ai` 0.3.0.

CogLog changes:

- Android `checkStatus()` / GenAI / download failures include the Java exception class name (and cause chain + short stack) so the debug screen can show why AICore queries fail when `e.message` is null.
- Android pins `com.google.mlkit:genai-prompt` to `1.0.0-beta2` (same as Gemini Nano Playground). `beta3`/`beta4` request AICore feature IDs that many shipping builds lack.
- Android warms `Generation.getClient()` on plugin attach and retries `checkStatus()` after delay / client reset when AICore returns a raw `NullPointerException` (known bind race).
- GenAI `checkStatus` / generate / download run on `Dispatchers.IO` (Playground pattern).
- `getPlatformInfo` diagnostic notes include `genai-prompt` version and AICore `versionName` / `versionCode`.
- Android pins `kotlinx-coroutines-android` to 1.11.0.
- `FlutterDeviceAi.diagnoseGenerateNative` bypasses readiness/fallback for connection diagnosis.
- Android Gradle uses Kotlin `compilerOptions` (Kotlin 2.2.x).
- Fallback `respondStream` `stop()` closes the relay controller so cancellation unblocks the session.
- Local LLM stream cancel during acquire releases `_active` correctly.
- `RagIndex.addDocument` validates embed batch size and restores prior records on upsert failure.
- `GenUiBlockTypes` / `GenUiModuleSpec.tryFromJson` avoid throwing `TypeError` on malformed model JSON.
- `OnDeviceUiGenerator` keeps `createSession` inside the try/catch contract.
- JSON extract accepts top-level scalar values; `estimateTokens` counts non-ASCII separately.
