import 'trends_bucket.dart';
import 'trends_sample.dart';
import 'trends_series_point.dart';

/// 身体指標のサンプルをバケット最終値へ集約する。
///
/// バケット内で [TrendsSample.at] が最も遅い value を採る。0 件なら点なし。
///
/// Example:
/// ```dart
/// TrendsBodyAggregator.points(
///   samples: const [
///     TrendsSample(at: DateTime(2026, 11, 10, 8), value: 70),
///     TrendsSample(at: DateTime(2026, 11, 10, 20), value: 69.5),
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
final class TrendsBodyAggregator {
  /// 静的 API だけを公開する。
  ///
  /// Example:
  /// ```dart
  /// TrendsBodyAggregator.points(samples: const [], buckets: const []);
  /// ```
  const TrendsBodyAggregator._();

  /// 各バケットで計測日時が最も遅い点を古い→新しい順に返す。
  ///
  /// Example:
  /// ```dart
  /// TrendsBodyAggregator.points(
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
      TrendsSample? latest;
      for (final sample in samples) {
        if (!bucket.contains(sample.at)) {
          continue;
        }
        if (latest == null || sample.at.isAfter(latest.at)) {
          latest = sample;
        }
      }
      if (latest == null) {
        continue;
      }
      out.add(
        TrendsSeriesPoint(
          representativeDate: bucket.representativeDate,
          value: latest.value,
        ),
      );
    }
    return out;
  }
}
