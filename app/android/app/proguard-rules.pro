# Keep ML Kit GenAI Prompt internals if release minification is enabled.
# Mirrors app_packages_fork/flutter_device_ai/android/consumer-rules.pro.
-keep class com.google.mlkit.genai.** { *; }
-keep class com.google.mlkit.common.** { *; }
-keep class com.google.android.gms.internal.mlkit_genai_prompt.** { *; }
-keep class com.google.android.gms.internal.mlkit_genai_common.** { *; }
