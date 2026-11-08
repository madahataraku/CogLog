/// メーター記録保存の成否区分。
enum SaveMeterCaptureOutcome {
  /// 永続化できた。
  success,

  /// 登録可能条件を満たさない。
  invalidInput,

  /// 永続化に失敗した。
  saveFailed,
}
