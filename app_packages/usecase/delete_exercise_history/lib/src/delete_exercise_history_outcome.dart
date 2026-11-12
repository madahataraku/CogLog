/// 運動履歴削除の成否区分。
enum DeleteExerciseHistoryOutcome {
  /// 削除できた。
  success,

  /// 対象が無い、または永続化削除に失敗した。
  notFoundOrFailed,
}
