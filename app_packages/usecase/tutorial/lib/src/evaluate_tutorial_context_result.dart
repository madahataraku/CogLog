/// 文脈表示の判定結果。
///
/// Example:
/// ```dart
/// const EvaluateTutorialContextResult(shouldShow: true);
/// ```
final class EvaluateTutorialContextResult {
  /// [shouldShow] が true なら呼び出し側が表示する。
  ///
  /// Example:
  /// ```dart
  /// const EvaluateTutorialContextResult(shouldShow: false);
  /// ```
  const EvaluateTutorialContextResult({required this.shouldShow});

  /// 文脈コーチマークを出してよいとき true。
  final bool shouldShow;
}
