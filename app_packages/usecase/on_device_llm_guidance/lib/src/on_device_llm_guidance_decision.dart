/// 誘導ダイアログの要否を表す。
///
/// Example:
/// ```dart
/// const OnDeviceLlmGuidanceDecision(shouldShow: true);
/// ```
final class OnDeviceLlmGuidanceDecision {
  /// 誘導ダイアログの要否を表す。
  ///
  /// Example:
  /// ```dart
  /// const OnDeviceLlmGuidanceDecision(shouldShow: true);
  /// ```
  const OnDeviceLlmGuidanceDecision({required this.shouldShow});

  /// true のとき未ダウンロード誘導の対象。
  ///
  /// Example:
  /// ```dart
  /// decision.shouldShow;
  /// ```
  final bool shouldShow;
}
