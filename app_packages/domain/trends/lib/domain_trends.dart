/// 推移グラフの期間バケットと系列集約。
///
/// 点間隔ごとの区間切りと、運動合計・身体最終・線種判定を提供する。
///
/// Example:
/// ```dart
/// final buckets = TrendsBucketBuilder.build(
///   nowLocal: DateTime(2026, 11, 10),
///   spec: TrendsPeriodSpec.days30,
/// );
/// ```
library;

export 'src/trends_body_aggregator.dart';
export 'src/trends_bucket.dart';
export 'src/trends_bucket_builder.dart';
export 'src/trends_exercise_aggregator.dart';
export 'src/trends_line_builder.dart';
export 'src/trends_line_kind.dart';
export 'src/trends_line_segment.dart';
export 'src/trends_metric_kind.dart';
export 'src/trends_period_spec.dart';
export 'src/trends_sample.dart';
export 'src/trends_series_point.dart';
