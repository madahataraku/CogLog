/// Gemma 誘導ダイアログの要否を表す。
///
/// Example:
/// ```dart
/// const GemmaMeterGuidanceDecision(shouldShow: true);
/// ```
final class GemmaMeterGuidanceDecision {
  /// 誘導ダイアログの要否を表す。
  ///
  /// Example:
  /// ```dart
  /// const GemmaMeterGuidanceDecision(shouldShow: true);
  /// ```
  const GemmaMeterGuidanceDecision({required this.shouldShow});

  /// true のとき Gemma 未ダウンロード誘導 (B) の対象。
  ///
  /// Example:
  /// ```dart
  /// decision.shouldShow;
  /// ```
  final bool shouldShow;
}
