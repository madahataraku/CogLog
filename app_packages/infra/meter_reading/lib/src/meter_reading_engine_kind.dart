/// メーター読み取りエンジンの種別。
///
/// 利用順は OS ごとに injection が決める。
///
/// Example:
/// ```dart
/// MeterReadingEngineKind.gemmaE2b;
/// ```
enum MeterReadingEngineKind {
  /// iOS Foundation Models。
  foundationModel,

  /// Android Gemini Nano。
  geminiNano,

  /// LiteRT-LM 上の Gemma E2B（メーター読み取り専用）。
  gemmaE2b,
}
