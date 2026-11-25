import 'dart:typed_data';

import 'package:domain_achievement/domain_achievement.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:domain_tutorial/domain_tutorial.dart';

/// `.cogsav` 1 ファイル分の論理内容。
///
/// 写真は [photos] に ID キーで持つ。キーが無い履歴は写真欠落として扱う。
/// [tutorial] が null のときは decode 時にキーが無かったことを示す。
///
/// Example:
/// ```dart
/// CogsavDocument(
///   formatVersion: 1,
///   exportedAt: DateTime.utc(2026, 11, 20),
///   exerciseHistories: const [],
///   dailyGoal: DailyGoal.unset,
///   dailyGoalAutoUpdate: DailyGoalAutoUpdateSettings.defaults,
///   notificationSettings: NotificationSettings.initial,
///   achievementUnlocks: const [],
///   achievementLastViewedAt: null,
///   tutorial: TutorialProgress.initial,
///   photos: const {},
/// );
/// ```
final class CogsavDocument {
  /// 版・日時・設定・履歴・チュートリアル・写真をまとめる。
  ///
  /// Example:
  /// ```dart
  /// CogsavDocument(
  ///   formatVersion: 1,
  ///   exportedAt: DateTime.timestamp(),
  ///   exerciseHistories: const [],
  ///   dailyGoal: DailyGoal.unset,
  ///   dailyGoalAutoUpdate: DailyGoalAutoUpdateSettings.defaults,
  ///   notificationSettings: NotificationSettings.initial,
  ///   achievementUnlocks: const [],
  ///   achievementLastViewedAt: null,
  ///   tutorial: TutorialProgress.initial,
  ///   photos: const {},
  /// );
  /// ```
  const CogsavDocument({
    required this.formatVersion,
    required this.exportedAt,
    required this.exerciseHistories,
    required this.dailyGoal,
    required this.dailyGoalAutoUpdate,
    required this.notificationSettings,
    required this.achievementUnlocks,
    required this.achievementLastViewedAt,
    required this.tutorial,
    required this.photos,
  });

  /// アーカイブ形式の整数版。
  final int formatVersion;

  /// エクスポート時刻（UTC 想定）。
  final DateTime exportedAt;

  /// 運動履歴一覧。写真バイトは [photos] 側。
  final List<ExerciseHistory> exerciseHistories;

  /// 一日あたり目標。
  final DailyGoal dailyGoal;

  /// 目標の自動更新設定。
  final DailyGoalAutoUpdateSettings dailyGoalAutoUpdate;

  /// 通知設定。
  final NotificationSettings notificationSettings;

  /// アチーブメント獲得一覧。
  final List<AchievementUnlock> achievementUnlocks;

  /// アチーブメント最終閲覧日時。未設定は null。
  final DateTime? achievementLastViewedAt;

  /// チュートリアル進捗。キー欠落の decode のみ null。
  final TutorialProgress? tutorial;

  /// 履歴 ID から JPEG バイト。欠落キーは写真なし。
  final Map<String, Uint8List> photos;
}
