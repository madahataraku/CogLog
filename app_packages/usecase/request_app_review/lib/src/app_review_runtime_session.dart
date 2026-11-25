/// アプリ内レビュー依頼のプロセス内状態。
///
/// Example:
/// ```dart
/// AppReviewRuntimeSession();
/// ```
final class AppReviewRuntimeSession {
  /// 未実行の状態で作る。
  ///
  /// Example:
  /// ```dart
  /// AppReviewRuntimeSession();
  /// ```
  AppReviewRuntimeSession();

  /// いま request 処理中なら true。
  bool requestInFlight = false;
}
