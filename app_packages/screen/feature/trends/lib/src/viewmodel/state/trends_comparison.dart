import 'package:domain_trends/domain_trends.dart';
import 'package:meta/meta.dart';

/// 推移画面の比較プリセット。
///
/// Example:
/// ```dart
/// TrendsComparison.caloriesBodyKg;
/// ```
@internal
enum TrendsComparison {
  /// 消費カロリー × 体重・除脂肪体重（初期）。
  caloriesBodyKg,

  /// 消費カロリー × 体脂肪率。
  caloriesBodyFat,

  /// 運動時間 × 走行距離。
  durationDistance,
}

/// 比較プリセットの派生属性。
@internal
extension TrendsComparisonX on TrendsComparison {
  /// 身体指標を 1 本でも含むか。
  ///
  /// Example:
  /// ```dart
  /// TrendsComparison.caloriesBodyKg.includesBody;
  /// ```
  bool get includesBody => switch (this) {
    TrendsComparison.caloriesBodyKg || TrendsComparison.caloriesBodyFat => true,
    TrendsComparison.durationDistance => false,
  };

  /// この比較で同時表示する指標。
  ///
  /// Example:
  /// ```dart
  /// TrendsComparison.durationDistance.metrics;
  /// ```
  List<TrendsMetricKind> get metrics => switch (this) {
    TrendsComparison.caloriesBodyKg => [
      TrendsMetricKind.exerciseCaloriesKcal,
      TrendsMetricKind.bodyWeightKg,
      TrendsMetricKind.bodyLeanMassKg,
    ],
    TrendsComparison.caloriesBodyFat => [
      TrendsMetricKind.exerciseCaloriesKcal,
      TrendsMetricKind.bodyFatPercent,
    ],
    TrendsComparison.durationDistance => [
      TrendsMetricKind.exerciseDurationMinutes,
      TrendsMetricKind.exerciseDistanceKm,
    ],
  };
}
