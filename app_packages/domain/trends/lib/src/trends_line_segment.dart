import 'trends_line_kind.dart';
import 'trends_series_point.dart';

/// グラフ上の 2 点を結ぶ 1 線分。
///
/// [kind] はバケット index の隣接関係で決まる。
///
/// Example:
/// ```dart
/// TrendsLineSegment(
///   from: const TrendsSeriesPoint(
///     representativeDate: DateTime(2026, 11, 9),
///     value: 100,
///   ),
///   to: const TrendsSeriesPoint(
///     representativeDate: DateTime(2026, 11, 10),
///     value: 200,
///   ),
///   kind: TrendsLineKind.solid,
/// );
/// ```
final class TrendsLineSegment {
  /// 両端と線種を持つ線分を作る。
  ///
  /// Example:
  /// ```dart
  /// TrendsLineSegment(
  ///   from: const TrendsSeriesPoint(
  ///     representativeDate: DateTime(2026, 11, 8),
  ///     value: 50,
  ///   ),
  ///   to: const TrendsSeriesPoint(
  ///     representativeDate: DateTime(2026, 11, 10),
  ///     value: 80,
  ///   ),
  ///   kind: TrendsLineKind.dashed,
  /// );
  /// ```
  const TrendsLineSegment({
    required this.from,
    required this.to,
    required this.kind,
  });

  /// 始点（代表日が若い側）。
  final TrendsSeriesPoint from;

  /// 終点（代表日が新しい側）。
  final TrendsSeriesPoint to;

  /// 実線または点線。
  final TrendsLineKind kind;
}
