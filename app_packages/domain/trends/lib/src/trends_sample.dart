/// 集約前の 1 計測／記録。
///
/// [at] は計測または記録の日時。[value] は指標の数値。
///
/// Example:
/// ```dart
/// const TrendsSample(at: DateTime(2026, 11, 10, 12), value: 200);
/// ```
final class TrendsSample {
  /// 日時と値を持つサンプルを作る。
  ///
  /// Example:
  /// ```dart
  /// const TrendsSample(at: DateTime(2026, 11, 9, 8), value: 70.5);
  /// ```
  const TrendsSample({required this.at, required this.value});

  /// 計測／記録の日時。
  final DateTime at;

  /// 指標の値。
  final double value;
}
