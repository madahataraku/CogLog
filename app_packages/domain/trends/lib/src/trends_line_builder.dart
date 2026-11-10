import 'trends_bucket.dart';
import 'trends_line_kind.dart';
import 'trends_line_segment.dart';
import 'trends_series_point.dart';

/// 系列点から実線／点線の線分列を作る。
///
/// バケット index が隣なら solid、飛んでいれば dashed。点が 2 未満なら空。
///
/// Example:
/// ```dart
/// TrendsLineBuilder.segments(
///   points: const [
///     TrendsSeriesPoint(
///       representativeDate: DateTime(2026, 11, 9),
///       value: 100,
///     ),
///     TrendsSeriesPoint(
///       representativeDate: DateTime(2026, 11, 10),
///       value: 200,
///     ),
///   ],
///   buckets: const [],
/// );
/// ```
final class TrendsLineBuilder {
  const TrendsLineBuilder._();

  /// [points] を代表日昇順に並べ、隣接関係で線種を決めた線分列を返す。
  ///
  /// Example:
  /// ```dart
  /// TrendsLineBuilder.segments(
  ///   points: const [
  ///     TrendsSeriesPoint(
  ///       representativeDate: DateTime(2026, 11, 10),
  ///       value: 1,
  ///     ),
  ///   ],
  ///   buckets: const [],
  /// );
  /// ```
  static List<TrendsLineSegment> segments({
    required List<TrendsSeriesPoint> points,
    required List<TrendsBucket> buckets,
  }) {
    if (points.length < 2) {
      return const [];
    }
    final indexByDate = <DateTime, int>{
      for (var i = 0; i < buckets.length; i++) buckets[i].representativeDate: i,
    };
    final ordered = [...points]
      ..sort((a, b) => a.representativeDate.compareTo(b.representativeDate));
    final out = <TrendsLineSegment>[];
    for (var i = 0; i < ordered.length - 1; i++) {
      final from = ordered[i];
      final to = ordered[i + 1];
      final fromIndex = indexByDate[from.representativeDate]!;
      final toIndex = indexByDate[to.representativeDate]!;
      final kind = toIndex == fromIndex + 1
          ? TrendsLineKind.solid
          : TrendsLineKind.dashed;
      out.add(TrendsLineSegment(from: from, to: to, kind: kind));
    }
    return out;
  }
}
