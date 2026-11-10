import 'trends_bucket.dart';
import 'trends_sample.dart';
import 'trends_series_point.dart';

/// 運動指標のサンプルをバケット合計へ集約する。
///
/// バケット内の value を足す。件数が 0 のバケットは点を作らない。
///
/// Example:
/// ```dart
/// TrendsExerciseAggregator.points(
///   samples: const [
///     TrendsSample(at: DateTime(2026, 11, 10, 8), value: 100),
///   ],
///   buckets: const [
///     TrendsBucket(
///       startInclusive: DateTime(2026, 11, 10),
///       endExclusive: DateTime(2026, 11, 11),
///       representativeDate: DateTime(2026, 11, 10),
///     ),
///   ],
/// );
/// ```
final class TrendsExerciseAggregator {
  /// 静的 API だけを公開する。
  ///
  /// Example:
  /// ```dart
  /// TrendsExerciseAggregator.points(samples: const [], buckets: const []);
  /// ```
  const TrendsExerciseAggregator._();

  /// 各バケットでサンプル value の合計点を古い→新しい順に返す。
  ///
  /// Example:
  /// ```dart
  /// TrendsExerciseAggregator.points(
  ///   samples: const [],
  ///   buckets: const [],
  /// );
  /// ```
  static List<TrendsSeriesPoint> points({
    required List<TrendsSample> samples,
    required List<TrendsBucket> buckets,
  }) {
    final out = <TrendsSeriesPoint>[];
    for (final bucket in buckets) {
      var sum = 0.0;
      var count = 0;
      for (final sample in samples) {
        if (!bucket.contains(sample.at)) {
          continue;
        }
        sum += sample.value;
        count += 1;
      }
      if (count == 0) {
        continue;
      }
      out.add(
        TrendsSeriesPoint(
          representativeDate: bucket.representativeDate,
          value: sum,
        ),
      );
    }
    return out;
  }
}
