/// メイン自動開始の判定結果。
///
/// Example:
/// ```dart
/// const EvaluateTutorialMainAutoStartResult(shouldStart: true);
/// ```
final class EvaluateTutorialMainAutoStartResult {
  /// [shouldStart] が true なら呼び出し側が開始する。
  ///
  /// Example:
  /// ```dart
  /// const EvaluateTutorialMainAutoStartResult(shouldStart: false);
  /// ```
  const EvaluateTutorialMainAutoStartResult({required this.shouldStart});

  /// メイン段階1を自動開始してよいとき true。
  final bool shouldStart;
}
