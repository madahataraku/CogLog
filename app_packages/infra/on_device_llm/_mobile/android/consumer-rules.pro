# ML Kit GenAI Prompt uses reflection / manifest discovery; R8 must not strip it.
# Same class of issue as googlesamples/mlkit#1018 (getClient NPE after shrinking).
-keep class com.google.mlkit.genai.** { *; }
-keep class com.google.mlkit.common.** { *; }
-keep class com.google.android.gms.internal.mlkit_genai_prompt.** { *; }
-keep class com.google.android.gms.internal.mlkit_genai_common.** { *; }
-keepclassmembers class * extends com.google.android.gms.internal.mlkit_genai_prompt.zzaoo {
  <fields>;
}
