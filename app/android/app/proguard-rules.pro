# Keep ML Kit GenAI Prompt internals if release minification is enabled.
# Mirrors infra_on_device_llm_mobile/android/consumer-rules.pro.
-keep class com.google.mlkit.genai.** { *; }
-keep class com.google.mlkit.common.** { *; }
-keep class com.google.android.gms.internal.mlkit_genai_prompt.** { *; }
-keep class com.google.android.gms.internal.mlkit_genai_common.** { *; }

# google_mlkit_text_recognition は未同梱の任意スクリプト用 Options を参照する。
# 日本語は build.gradle.kts の implementation で入れ、他は使わないので R8 に無視させる。
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.korean.**
