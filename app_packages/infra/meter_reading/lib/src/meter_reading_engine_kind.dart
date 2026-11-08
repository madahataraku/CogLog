/// メーター読み取りエンジンの種別。
///
/// 利用順は OS ごとに injection が決める。
enum MeterReadingEngineKind {
  /// iOS Vision OCR。
  visionOcr,

  /// iOS Foundation Models。
  foundationModel,

  /// Android ML Kit。
  mlKit,

  /// Android Gemini Nano。
  geminiNano,
}
