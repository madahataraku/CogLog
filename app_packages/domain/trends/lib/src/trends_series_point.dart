/// グラフに載せる 1 点。
///
/// [representativeDate] は所属バケットの代表日。[value] はそのバケットの集約値。
///
/// Example:
/// ```dart
/// const TrendsSeriesPoint(
///   representativeDate: DateTime(2026, 11, 10),
///   value: 200,
/// );
/// ```
final class TrendsSeriesPoint {
  /// 代表日と値を持つ点を作る。
  ///
  /// Example:
  /// ```dart
  /// const TrendsSeriesPoint(
  ///   representativeDate: DateTime(2026, 11, 9),
  ///   value: 100,
  /// );
  /// ```
  const TrendsSeriesPoint({
    required this.representativeDate,
    required this.value,
  });

  /// 所属バケットの代表日（現地 0:00）。
  final DateTime representativeDate;

  /// 集約後の値。
  final double value;
}
