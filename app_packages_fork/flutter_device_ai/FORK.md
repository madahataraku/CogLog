# Fork notes

Upstream: `flutter_device_ai` 0.3.0.

CogLog change: Android `checkStatus()` / GenAI failures now include the Java exception class name (and cause chain) in the message so the debug screen can show why AICore queries fail when `e.message` is null.
