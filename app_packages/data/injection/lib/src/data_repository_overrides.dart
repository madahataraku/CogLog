import 'dart:io';

import 'package:data_database/data_database.dart';
import 'package:data_repository_app_review/data_repository_app_review.dart';
import 'package:data_repository_app_review_impl/data_repository_app_review_impl.dart';
import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:data_repository_achievement_impl/data_repository_achievement_impl.dart';
import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_daily_goal_impl/data_repository_daily_goal_impl.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_exercise_history_impl/data_repository_exercise_history_impl.dart';
import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:data_repository_notification_settings_impl/data_repository_notification_settings_impl.dart';
import 'package:data_repository_top_screen_metric/data_repository_top_screen_metric.dart';
import 'package:data_repository_top_screen_metric_impl/data_repository_top_screen_metric_impl.dart';
import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:data_repository_tutorial_impl/data_repository_tutorial_impl.dart';
import 'package:riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 運動履歴・指標選択・一日あたり目標・アチーブメント・チュートリアル・アプリ内レビュー抑止の本番実装を上書きする。
///
/// [histories] を渡したときは、Drift の代わりにそれを読む。
/// [cacheDirectory] はアプリ内レビュー抑止フラグの置き場に使う。
///
/// Example:
/// ```dart
/// dataRepositoryOverrides(
///   preferences: preferences,
///   database: database,
///   documentsDirectory: documents,
///   cacheDirectory: cache,
/// );
/// ```
List<Override> dataRepositoryOverrides({
  required SharedPreferences preferences,
  required AppDatabase database,
  required Directory documentsDirectory,
  required Directory cacheDirectory,
  ExerciseHistoryRepository? histories,
}) => [
  exerciseHistoryRepositoryProvider.overrideWith(
    (ref) =>
        histories ??
        DriftExerciseHistoryRepository(
          database: database,
          photos: ExerciseHistoryPhotoStore(documentsDirectory),
        ),
  ),
  topScreenMetricRepositoryProvider.overrideWith(
    (ref) => SharedPreferencesTopScreenMetricRepository(preferences),
  ),
  dailyGoalRepositoryProvider.overrideWith(
    (ref) => SharedPreferencesDailyGoalRepository(preferences),
  ),
  notificationSettingsRepositoryProvider.overrideWith(
    (ref) => SharedPreferencesNotificationSettingsRepository(preferences),
  ),
  achievementRepositoryProvider.overrideWith(
    (ref) => SharedPreferencesAchievementRepository(preferences),
  ),
  tutorialRepositoryProvider.overrideWith(
    (ref) => SharedPreferencesTutorialRepository(preferences),
  ),
  appReviewSuppressionRepositoryProvider.overrideWith(
    (ref) => CacheFileAppReviewSuppressionRepository(cacheDirectory),
  ),
];
