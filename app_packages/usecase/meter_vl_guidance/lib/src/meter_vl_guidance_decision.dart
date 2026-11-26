/// メーター VL 誘導ダイアログの要否を表す。
///
/// Example:
/// ```dart
/// const MeterVlGuidanceDecision(shouldShow: true);
/// ```
final class MeterVlGuidanceDecision {
  /// 誘導ダイアログの要否を表す。
  ///
  /// Example:
  /// ```dart
  /// const MeterVlGuidanceDecision(shouldShow: true);
  /// ```
  const MeterVlGuidanceDecision({required this.shouldShow});

  /// true のとき メーター VL 未ダウンロード誘導 (B) の対象。
  ///
  /// Example:
  /// ```dart
  /// decision.shouldShow;
  /// ```
  final bool shouldShow;
}
