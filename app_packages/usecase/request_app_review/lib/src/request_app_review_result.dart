/// アプリ内レビュー依頼の結果区分。
///
/// Example:
/// ```dart
/// RequestAppReviewResult.requested;
/// ```
enum RequestAppReviewResult {
  /// production 以外のため呼ばなかった。
  skippedFlavor,

  /// 抑止済みのため呼ばなかった。
  skippedSuppressed,

  /// チュートリアル未完了または読取失敗のため呼ばなかった。
  skippedTutorial,

  /// isAvailable が偽のため呼ばなかった。
  skippedUnavailable,

  /// 同一プロセスで実行中のため呼ばなかった。
  skippedInFlight,

  /// requestReview を呼び、抑止を試みた。
  requested,
}
