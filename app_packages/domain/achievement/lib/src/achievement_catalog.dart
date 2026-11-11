import 'achievement_criterion.dart';
import 'achievement_definition.dart';

/// v1 アチーブメント定義の固定一覧。
///
/// [all] の並びがそのまま画面の表示順になる。雨天条件は含めない。
///
/// Example:
/// ```dart
/// final first = AchievementCatalog.all.first;
/// ```
final class AchievementCatalog {
  /// カタログ参照用の名前空間。
  ///
  /// Example:
  /// ```dart
  /// AchievementCatalog.all.length;
  /// ```
  const AchievementCatalog._();

  /// v1 で採用する定義を記載順で返す。
  ///
  /// Example:
  /// ```dart
  /// for (final definition in AchievementCatalog.all) {
  ///   definition.id;
  /// }
  /// ```
  static const List<AchievementDefinition> all = [
    AchievementDefinition(
      id: 'first_record',
      criterion: AchievementCriterion.firstRecord,
      target: 1,
      binaryProgress: true,
    ),
    AchievementDefinition(
      id: 'streak_3',
      criterion: AchievementCriterion.maxStreakDays,
      target: 3,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'streak_7',
      criterion: AchievementCriterion.maxStreakDays,
      target: 7,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'streak_14',
      criterion: AchievementCriterion.maxStreakDays,
      target: 14,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'streak_30',
      criterion: AchievementCriterion.maxStreakDays,
      target: 30,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'streak_60',
      criterion: AchievementCriterion.maxStreakDays,
      target: 60,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'streak_90',
      criterion: AchievementCriterion.maxStreakDays,
      target: 90,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'unique_100',
      criterion: AchievementCriterion.uniqueDays,
      target: 100,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'streak_365',
      criterion: AchievementCriterion.maxStreakDays,
      target: 365,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'distance_1',
      criterion: AchievementCriterion.totalDistanceKm,
      target: 1,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'distance_10',
      criterion: AchievementCriterion.totalDistanceKm,
      target: 10,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'distance_50',
      criterion: AchievementCriterion.totalDistanceKm,
      target: 50,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'distance_100',
      criterion: AchievementCriterion.totalDistanceKm,
      target: 100,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'distance_500',
      criterion: AchievementCriterion.totalDistanceKm,
      target: 500,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'distance_1000',
      criterion: AchievementCriterion.totalDistanceKm,
      target: 1000,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'distance_5000',
      criterion: AchievementCriterion.totalDistanceKm,
      target: 5000,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'distance_10000',
      criterion: AchievementCriterion.totalDistanceKm,
      target: 10000,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'distance_40075',
      criterion: AchievementCriterion.totalDistanceKm,
      target: 40075,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'single_duration_10m',
      criterion: AchievementCriterion.singleDuration,
      target: 600,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'single_duration_30m',
      criterion: AchievementCriterion.singleDuration,
      target: 1800,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'single_duration_60m',
      criterion: AchievementCriterion.singleDuration,
      target: 3600,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'total_duration_10h',
      criterion: AchievementCriterion.totalDuration,
      target: 36000,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'total_duration_24h',
      criterion: AchievementCriterion.totalDuration,
      target: 86400,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'total_duration_48h',
      criterion: AchievementCriterion.totalDuration,
      target: 172800,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'total_duration_96h',
      criterion: AchievementCriterion.totalDuration,
      target: 345600,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'total_duration_100h',
      criterion: AchievementCriterion.totalDuration,
      target: 360000,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'total_duration_300h',
      criterion: AchievementCriterion.totalDuration,
      target: 1080000,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'total_duration_1000h',
      criterion: AchievementCriterion.totalDuration,
      target: 3600000,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'calories_50',
      criterion: AchievementCriterion.totalCaloriesKcal,
      target: 50,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'calories_100',
      criterion: AchievementCriterion.totalCaloriesKcal,
      target: 100,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'calories_150',
      criterion: AchievementCriterion.totalCaloriesKcal,
      target: 150,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'calories_200',
      criterion: AchievementCriterion.totalCaloriesKcal,
      target: 200,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'calories_300',
      criterion: AchievementCriterion.totalCaloriesKcal,
      target: 300,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'calories_500',
      criterion: AchievementCriterion.totalCaloriesKcal,
      target: 500,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'calories_1000',
      criterion: AchievementCriterion.totalCaloriesKcal,
      target: 1000,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'calories_1500',
      criterion: AchievementCriterion.totalCaloriesKcal,
      target: 1500,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'calories_3000',
      criterion: AchievementCriterion.totalCaloriesKcal,
      target: 3000,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'calories_5000',
      criterion: AchievementCriterion.totalCaloriesKcal,
      target: 5000,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'calories_10000',
      criterion: AchievementCriterion.totalCaloriesKcal,
      target: 10000,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'best_distance',
      criterion: AchievementCriterion.bestDistanceUpdate,
      target: 1,
      binaryProgress: true,
    ),
    AchievementDefinition(
      id: 'best_duration',
      criterion: AchievementCriterion.bestDurationUpdate,
      target: 1,
      binaryProgress: true,
    ),
    AchievementDefinition(
      id: 'gap_restart_30',
      criterion: AchievementCriterion.gapRestartDays,
      target: 30,
      binaryProgress: true,
    ),
    AchievementDefinition(
      id: 'leap_day',
      criterion: AchievementCriterion.leapDay,
      target: 1,
      binaryProgress: true,
    ),
    AchievementDefinition(
      id: 'day_11_11',
      criterion: AchievementCriterion.dayMonth1111,
      target: 1,
      binaryProgress: true,
    ),
    AchievementDefinition(
      id: 'count_100',
      criterion: AchievementCriterion.recordCount,
      target: 100,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'same_day_2',
      criterion: AchievementCriterion.maxSameDayCount,
      target: 2,
      binaryProgress: false,
    ),
    AchievementDefinition(
      id: 'year_end_new_year',
      criterion: AchievementCriterion.yearEndNewYearSeason,
      target: 6,
      binaryProgress: false,
    ),
  ];
}
