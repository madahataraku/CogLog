/// メーター読み取りエンジンの種別。
///
/// 利用順は OS ごとに injection が決める。
enum MeterReadingEngineKind {
  /// iOS Foundation Models。
  foundationModel,

  /// Android Gemini Nano。
  geminiNano,
}
