import 'package:domain_achievement/domain_achievement.dart';

import 'strings.dart';

/// カタログ [id] の表示名を返す。
///
/// Example:
/// ```dart
/// resolveAchievementName('first_record');
/// ```
String resolveAchievementName(AchievementId id) => switch (id) {
  'first_record' => strings.screen_feature_achievement_name_first_record,
  'streak_3' => strings.screen_feature_achievement_name_streak_3,
  'streak_7' => strings.screen_feature_achievement_name_streak_7,
  'streak_14' => strings.screen_feature_achievement_name_streak_14,
  'streak_30' => strings.screen_feature_achievement_name_streak_30,
  'streak_60' => strings.screen_feature_achievement_name_streak_60,
  'streak_90' => strings.screen_feature_achievement_name_streak_90,
  'unique_100' => strings.screen_feature_achievement_name_unique_100,
  'streak_365' => strings.screen_feature_achievement_name_streak_365,
  'distance_1' => strings.screen_feature_achievement_name_distance_1,
  'distance_10' => strings.screen_feature_achievement_name_distance_10,
  'distance_50' => strings.screen_feature_achievement_name_distance_50,
  'distance_100' => strings.screen_feature_achievement_name_distance_100,
  'distance_500' => strings.screen_feature_achievement_name_distance_500,
  'distance_1000' => strings.screen_feature_achievement_name_distance_1000,
  'distance_5000' => strings.screen_feature_achievement_name_distance_5000,
  'distance_10000' => strings.screen_feature_achievement_name_distance_10000,
  'distance_40075' => strings.screen_feature_achievement_name_distance_40075,
  'single_duration_10m' =>
    strings.screen_feature_achievement_name_single_duration_10m,
  'single_duration_30m' =>
    strings.screen_feature_achievement_name_single_duration_30m,
  'single_duration_60m' =>
    strings.screen_feature_achievement_name_single_duration_60m,
  'total_duration_10h' =>
    strings.screen_feature_achievement_name_total_duration_10h,
  'total_duration_24h' =>
    strings.screen_feature_achievement_name_total_duration_24h,
  'total_duration_48h' =>
    strings.screen_feature_achievement_name_total_duration_48h,
  'total_duration_96h' =>
    strings.screen_feature_achievement_name_total_duration_96h,
  'total_duration_100h' =>
    strings.screen_feature_achievement_name_total_duration_100h,
  'total_duration_300h' =>
    strings.screen_feature_achievement_name_total_duration_300h,
  'total_duration_1000h' =>
    strings.screen_feature_achievement_name_total_duration_1000h,
  'calories_50' => strings.screen_feature_achievement_name_calories_50,
  'calories_100' => strings.screen_feature_achievement_name_calories_100,
  'calories_150' => strings.screen_feature_achievement_name_calories_150,
  'calories_200' => strings.screen_feature_achievement_name_calories_200,
  'calories_300' => strings.screen_feature_achievement_name_calories_300,
  'calories_500' => strings.screen_feature_achievement_name_calories_500,
  'calories_1000' => strings.screen_feature_achievement_name_calories_1000,
  'calories_1500' => strings.screen_feature_achievement_name_calories_1500,
  'calories_3000' => strings.screen_feature_achievement_name_calories_3000,
  'calories_5000' => strings.screen_feature_achievement_name_calories_5000,
  'calories_10000' => strings.screen_feature_achievement_name_calories_10000,
  'best_distance' => strings.screen_feature_achievement_name_best_distance,
  'best_duration' => strings.screen_feature_achievement_name_best_duration,
  'gap_restart_30' => strings.screen_feature_achievement_name_gap_restart_30,
  'leap_day' => strings.screen_feature_achievement_name_leap_day,
  'day_11_11' => strings.screen_feature_achievement_name_day_11_11,
  'count_100' => strings.screen_feature_achievement_name_count_100,
  'same_day_2' => strings.screen_feature_achievement_name_same_day_2,
  'year_end_new_year' =>
    strings.screen_feature_achievement_name_year_end_new_year,
  _ => id,
};

/// カタログ [id] の達成条件文を返す。
///
/// Example:
/// ```dart
/// resolveAchievementCondition('streak_3');
/// ```
String resolveAchievementCondition(AchievementId id) => switch (id) {
  'first_record' => strings.screen_feature_achievement_condition_first_record,
  'streak_3' => strings.screen_feature_achievement_condition_streak_3,
  'streak_7' => strings.screen_feature_achievement_condition_streak_7,
  'streak_14' => strings.screen_feature_achievement_condition_streak_14,
  'streak_30' => strings.screen_feature_achievement_condition_streak_30,
  'streak_60' => strings.screen_feature_achievement_condition_streak_60,
  'streak_90' => strings.screen_feature_achievement_condition_streak_90,
  'unique_100' => strings.screen_feature_achievement_condition_unique_100,
  'streak_365' => strings.screen_feature_achievement_condition_streak_365,
  'distance_1' => strings.screen_feature_achievement_condition_distance_1,
  'distance_10' => strings.screen_feature_achievement_condition_distance_10,
  'distance_50' => strings.screen_feature_achievement_condition_distance_50,
  'distance_100' => strings.screen_feature_achievement_condition_distance_100,
  'distance_500' => strings.screen_feature_achievement_condition_distance_500,
  'distance_1000' => strings.screen_feature_achievement_condition_distance_1000,
  'distance_5000' => strings.screen_feature_achievement_condition_distance_5000,
  'distance_10000' =>
    strings.screen_feature_achievement_condition_distance_10000,
  'distance_40075' =>
    strings.screen_feature_achievement_condition_distance_40075,
  'single_duration_10m' =>
    strings.screen_feature_achievement_condition_single_duration_10m,
  'single_duration_30m' =>
    strings.screen_feature_achievement_condition_single_duration_30m,
  'single_duration_60m' =>
    strings.screen_feature_achievement_condition_single_duration_60m,
  'total_duration_10h' =>
    strings.screen_feature_achievement_condition_total_duration_10h,
  'total_duration_24h' =>
    strings.screen_feature_achievement_condition_total_duration_24h,
  'total_duration_48h' =>
    strings.screen_feature_achievement_condition_total_duration_48h,
  'total_duration_96h' =>
    strings.screen_feature_achievement_condition_total_duration_96h,
  'total_duration_100h' =>
    strings.screen_feature_achievement_condition_total_duration_100h,
  'total_duration_300h' =>
    strings.screen_feature_achievement_condition_total_duration_300h,
  'total_duration_1000h' =>
    strings.screen_feature_achievement_condition_total_duration_1000h,
  'calories_50' => strings.screen_feature_achievement_condition_calories_50,
  'calories_100' => strings.screen_feature_achievement_condition_calories_100,
  'calories_150' => strings.screen_feature_achievement_condition_calories_150,
  'calories_200' => strings.screen_feature_achievement_condition_calories_200,
  'calories_300' => strings.screen_feature_achievement_condition_calories_300,
  'calories_500' => strings.screen_feature_achievement_condition_calories_500,
  'calories_1000' => strings.screen_feature_achievement_condition_calories_1000,
  'calories_1500' => strings.screen_feature_achievement_condition_calories_1500,
  'calories_3000' => strings.screen_feature_achievement_condition_calories_3000,
  'calories_5000' => strings.screen_feature_achievement_condition_calories_5000,
  'calories_10000' =>
    strings.screen_feature_achievement_condition_calories_10000,
  'best_distance' => strings.screen_feature_achievement_condition_best_distance,
  'best_duration' => strings.screen_feature_achievement_condition_best_duration,
  'gap_restart_30' =>
    strings.screen_feature_achievement_condition_gap_restart_30,
  'leap_day' => strings.screen_feature_achievement_condition_leap_day,
  'day_11_11' => strings.screen_feature_achievement_condition_day_11_11,
  'count_100' => strings.screen_feature_achievement_condition_count_100,
  'same_day_2' => strings.screen_feature_achievement_condition_same_day_2,
  'year_end_new_year' =>
    strings.screen_feature_achievement_condition_year_end_new_year,
  _ => id,
};

/// [unlocks] を [AchievementCatalog.all] の記載順に並べ替える。
///
/// Example:
/// ```dart
/// sortAchievementsByCatalogOrder(const []);
/// ```
List<AchievementUnlock> sortAchievementsByCatalogOrder(
  List<AchievementUnlock> unlocks,
) {
  final order = {
    for (var i = 0; i < AchievementCatalog.all.length; i++)
      AchievementCatalog.all[i].id: i,
  };
  final sorted = [
    ...unlocks,
  ]..sort((a, b) => (order[a.id] ?? 1 << 30).compareTo(order[b.id] ?? 1 << 30));
  return sorted;
}
