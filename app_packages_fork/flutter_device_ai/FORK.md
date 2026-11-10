# Fork notes

Upstream: `flutter_device_ai` 0.3.0.

CogLog changes:

- Android `checkStatus()` / GenAI / download failures include the Java exception class name (and cause chain) so the debug screen can show why AICore queries fail when `e.message` is null.
- `FlutterDeviceAi.diagnoseGenerateNative` bypasses readiness/fallback for connection diagnosis.
- Android Gradle uses Kotlin `compilerOptions` (Kotlin 2.2.x).
- Fallback `respondStream` `stop()` closes the relay controller so cancellation unblocks the session.
- Local LLM stream cancel during acquire releases `_active` correctly.
- `RagIndex.addDocument` validates embed batch size and restores prior records on upsert failure.
- `GenUiBlockTypes` / `GenUiModuleSpec.tryFromJson` avoid throwing `TypeError` on malformed model JSON.
- `OnDeviceUiGenerator` keeps `createSession` inside the try/catch contract.
- JSON extract accepts top-level scalar values; `estimateTokens` counts non-ASCII separately.
