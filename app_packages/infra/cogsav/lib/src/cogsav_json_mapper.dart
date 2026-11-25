import 'package:domain_achievement/domain_achievement.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:meta/meta.dart';

import 'cogsav_exceptions.dart';

/// `data.json` とドメイン型の相互変換。
///
/// Example:
/// ```dart
/// CogsavJsonMapper.encodeDataPayload(
///   exerciseHistories: const [],
///   dailyGoal: DailyGoal.unset,
///   dailyGoalAutoUpdate: DailyGoalAutoUpdateSettings.defaults,
///   notificationSettings: NotificationSettings.initial,
///   achievementUnlocks: const [],
///   achievementLastViewedAt: null,
///   tutorial: TutorialProgress.initial,
/// );
/// ```
@internal
abstract final class CogsavJsonMapper {
  /// ドメイン値を `data.json` 用 Map にする。
  ///
  /// [tutorial] は常に非 null で、`tutorial` キーを必ず出す。
  ///
  /// Example:
  /// ```dart
  /// CogsavJsonMapper.encodeDataPayload(
  ///   exerciseHistories: const [],
  ///   dailyGoal: DailyGoal.unset,
  ///   dailyGoalAutoUpdate: DailyGoalAutoUpdateSettings.defaults,
  ///   notificationSettings: NotificationSettings.initial,
  ///   achievementUnlocks: const [],
  ///   achievementLastViewedAt: null,
  ///   tutorial: TutorialProgress.initial,
  /// );
  /// ```
  static Map<String, Object?> encodeDataPayload({
    required List<ExerciseHistory> exerciseHistories,
    required DailyGoal dailyGoal,
    required DailyGoalAutoUpdateSettings dailyGoalAutoUpdate,
    required NotificationSettings notificationSettings,
    required List<AchievementUnlock> achievementUnlocks,
    required DateTime? achievementLastViewedAt,
    required TutorialProgress tutorial,
  }) {
    return <String, Object?>{
      'exerciseHistories': [
        for (final history in exerciseHistories) _encodeHistory(history),
      ],
      'dailyGoal': _encodeDailyGoal(dailyGoal),
      'dailyGoalAutoUpdate': _encodeAutoUpdate(dailyGoalAutoUpdate),
      'notificationSettings': <String, Object?>{
        'enabled': notificationSettings.enabled,
      },
      'achievementUnlocks': [
        for (final unlock in achievementUnlocks) _encodeUnlock(unlock),
      ],
      'achievementLastViewedAt': achievementLastViewedAt
          ?.toUtc()
          .toIso8601String(),
      'tutorial': _encodeTutorial(tutorial),
    };
  }

  /// `data.json` の Map をドメイン値にする。必須欠落・型不正は [CogsavCorruptException]。
  ///
  /// `tutorial` キー欠落は null。キーありで不正なら破損。
  ///
  /// Example:
  /// ```dart
  /// CogsavJsonMapper.decodeDataPayload(<String, Object?>{
  ///   'exerciseHistories': <Object?>[],
  ///   'dailyGoal': <String, Object?>{
  ///     'durationSeconds': null,
  ///     'caloriesKcal': null,
  ///     'distanceKm': null,
  ///   },
  ///   'dailyGoalAutoUpdate': <String, Object?>{
  ///     'enabled': false,
  ///     'level': 'normal',
  ///     'enabledOnLocalDate': null,
  ///     'streakEpochLocalDate': null,
  ///     'lastAppliedLocalDate': null,
  ///     'weeklyAchievementDays': null,
  ///   },
  ///   'notificationSettings': <String, Object?>{'enabled': false},
  ///   'achievementUnlocks': <Object?>[],
  ///   'achievementLastViewedAt': null,
  /// });
  /// ```
  static ({
    List<ExerciseHistory> exerciseHistories,
    DailyGoal dailyGoal,
    DailyGoalAutoUpdateSettings dailyGoalAutoUpdate,
    NotificationSettings notificationSettings,
    List<AchievementUnlock> achievementUnlocks,
    DateTime? achievementLastViewedAt,
    TutorialProgress? tutorial,
  })
  decodeDataPayload(Map<Object?, Object?> raw) {
    final historiesRaw = _requireList(raw, 'exerciseHistories');
    final dailyGoalRaw = _requireMap(raw, 'dailyGoal');
    final autoRaw = _requireMap(raw, 'dailyGoalAutoUpdate');
    final notificationRaw = _requireMap(raw, 'notificationSettings');
    final unlocksRaw = _requireList(raw, 'achievementUnlocks');
    if (!raw.containsKey('achievementLastViewedAt')) {
      throw const CogsavCorruptException(
        'data.json に achievementLastViewedAt が無い',
      );
    }

    final histories = <ExerciseHistory>[];
    for (final entry in historiesRaw) {
      histories.add(_decodeHistory(entry));
    }

    final unlocks = <AchievementUnlock>[];
    for (final entry in unlocksRaw) {
      unlocks.add(_decodeUnlock(entry));
    }

    final lastViewedRaw = raw['achievementLastViewedAt'];
    final DateTime? lastViewed;
    if (lastViewedRaw == null) {
      lastViewed = null;
    } else if (lastViewedRaw is String) {
      lastViewed = _parseUtcDateTime(
        lastViewedRaw,
        field: 'achievementLastViewedAt',
      );
    } else {
      throw const CogsavCorruptException('achievementLastViewedAt の型が不正');
    }

    final TutorialProgress? tutorial;
    if (!raw.containsKey('tutorial')) {
      tutorial = null;
    } else {
      tutorial = _decodeTutorial(raw['tutorial']);
    }

    return (
      exerciseHistories: histories,
      dailyGoal: _decodeDailyGoal(dailyGoalRaw),
      dailyGoalAutoUpdate: _decodeAutoUpdate(autoRaw),
      notificationSettings: _decodeNotification(notificationRaw),
      achievementUnlocks: unlocks,
      achievementLastViewedAt: lastViewed,
      tutorial: tutorial,
    );
  }

  static Map<String, Object?> _encodeHistory(ExerciseHistory history) {
    return <String, Object?>{
      'id': history.id,
      'savedAt': history.savedAt.toUtc().toIso8601String(),
      'creationStartedAt': history.creationStartedAt.toUtc().toIso8601String(),
      'capturedAt': history.capturedAt.toUtc().toIso8601String(),
      'recordedAt': history.recordedAt.toUtc().toIso8601String(),
      'recordedAtManuallySet': history.recordedAtManuallySet,
      'distanceKm': history.distanceKm,
      'durationMs': history.duration.inMilliseconds,
      'caloriesKcal': history.caloriesKcal,
      'averageSpeedKmh': history.averageSpeedKmh,
      'healthWorkoutId': history.healthWorkoutId,
    };
  }

  static final RegExp _historyId = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static ExerciseHistory _decodeHistory(Object? raw) {
    final map = _asMap(raw, field: 'exerciseHistories[]');
    final id = _requireString(map, 'id');
    if (!_historyId.hasMatch(id)) {
      throw CogsavCorruptException('運動履歴 ID が UUID でない: $id');
    }
    final durationMs = _requireInt(map, 'durationMs');
    if (durationMs < 0) {
      throw const CogsavCorruptException('durationMs が負');
    }
    final duration = Duration(milliseconds: durationMs);
    if (duration.inSeconds == 0) {
      throw const CogsavCorruptException('durationMs が 0 秒相当');
    }
    return ExerciseHistory(
      id: id,
      savedAt: _parseUtcDateTime(
        _requireString(map, 'savedAt'),
        field: 'savedAt',
      ),
      creationStartedAt: _parseUtcDateTime(
        _requireString(map, 'creationStartedAt'),
        field: 'creationStartedAt',
      ),
      capturedAt: _parseUtcDateTime(
        _requireString(map, 'capturedAt'),
        field: 'capturedAt',
      ),
      recordedAt: _parseUtcDateTime(
        _requireString(map, 'recordedAt'),
        field: 'recordedAt',
      ),
      recordedAtManuallySet: _requireBool(map, 'recordedAtManuallySet'),
      distanceKm: _requireDouble(map, 'distanceKm'),
      duration: duration,
      caloriesKcal: _requireDouble(map, 'caloriesKcal'),
      averageSpeedKmh: _requireDouble(map, 'averageSpeedKmh'),
      photoRelativePath: 'exercise_histories/$id/meter.jpg',
      healthWorkoutId: _optionalString(map, 'healthWorkoutId'),
    );
  }

  static Map<String, Object?> _encodeDailyGoal(DailyGoal goal) {
    return <String, Object?>{
      'durationSeconds': goal.duration?.inSeconds,
      'caloriesKcal': goal.caloriesKcal,
      'distanceKm': goal.distanceKm,
    };
  }

  static DailyGoal _decodeDailyGoal(Map<Object?, Object?> raw) {
    if (!raw.containsKey('durationSeconds') ||
        !raw.containsKey('caloriesKcal') ||
        !raw.containsKey('distanceKm')) {
      throw const CogsavCorruptException('dailyGoal の必須キーが欠ける');
    }
    final durationRaw = raw['durationSeconds'];
    final Duration? duration;
    if (durationRaw == null) {
      duration = null;
    } else if (durationRaw is int) {
      duration = Duration(seconds: durationRaw);
    } else if (durationRaw is num) {
      duration = Duration(seconds: durationRaw.toInt());
    } else {
      throw const CogsavCorruptException('durationSeconds の型が不正');
    }
    return DailyGoal(
      duration: duration,
      caloriesKcal: _optionalDouble(raw, 'caloriesKcal'),
      distanceKm: _optionalDouble(raw, 'distanceKm'),
    );
  }

  static Map<String, Object?> _encodeAutoUpdate(
    DailyGoalAutoUpdateSettings settings,
  ) {
    return <String, Object?>{
      'enabled': settings.enabled,
      'level': settings.level.name,
      'enabledOnLocalDate': _formatLocalDate(settings.enabledOnLocalDate),
      'streakEpochLocalDate': _formatLocalDate(settings.streakEpochLocalDate),
      'lastAppliedLocalDate': _formatLocalDate(settings.lastAppliedLocalDate),
      'weeklyAchievementDays': settings.weeklyAchievementDays,
    };
  }

  static DailyGoalAutoUpdateSettings _decodeAutoUpdate(
    Map<Object?, Object?> raw,
  ) {
    final levelRaw = _requireString(raw, 'level');
    final level = switch (levelRaw) {
      'slow' => DailyGoalAutoUpdateLevel.slow,
      'normal' => DailyGoalAutoUpdateLevel.normal,
      'challenging' => DailyGoalAutoUpdateLevel.challenging,
      _ => throw CogsavCorruptException('level が不明: $levelRaw'),
    };
    final weeklyRaw = raw['weeklyAchievementDays'];
    final int? weekly;
    if (weeklyRaw == null) {
      weekly = null;
    } else if (weeklyRaw is int) {
      weekly = weeklyRaw;
    } else if (weeklyRaw is num) {
      weekly = weeklyRaw.toInt();
    } else {
      throw const CogsavCorruptException('weeklyAchievementDays の型が不正');
    }
    return DailyGoalAutoUpdateSettings(
      enabled: _requireBool(raw, 'enabled'),
      level: level,
      enabledOnLocalDate: _parseLocalDate(
        raw['enabledOnLocalDate'],
        field: 'enabledOnLocalDate',
      ),
      streakEpochLocalDate: _parseLocalDate(
        raw['streakEpochLocalDate'],
        field: 'streakEpochLocalDate',
      ),
      lastAppliedLocalDate: _parseLocalDate(
        raw['lastAppliedLocalDate'],
        field: 'lastAppliedLocalDate',
      ),
      weeklyAchievementDays: weekly,
    );
  }

  static NotificationSettings _decodeNotification(Map<Object?, Object?> raw) {
    return NotificationSettings(enabled: _requireBool(raw, 'enabled'));
  }

  /// [progress] を `data.json` の `tutorial` オブジェクトにする。
  ///
  /// Example:
  /// ```dart
  /// CogsavJsonMapper._encodeTutorial(TutorialProgress.initial);
  /// ```
  static Map<String, Object?> _encodeTutorial(TutorialProgress progress) {
    return <String, Object?>{
      'mainCompleted': progress.mainCompleted,
      'cameraContextSeen': progress.cameraContextSeen,
      'meterEditContextSeen': progress.meterEditContextSeen,
      'trendsContextSeen': progress.trendsContextSeen,
      'historyContextSeen': progress.historyContextSeen,
      'achievementContextSeen': progress.achievementContextSeen,
    };
  }

  /// `tutorial` 値を [TutorialProgress] にする。
  ///
  /// 非オブジェクト・bool 欠落／非 bool は [CogsavCorruptException]。
  ///
  /// Example:
  /// ```dart
  /// CogsavJsonMapper._decodeTutorial(<String, Object?>{
  ///   'mainCompleted': false,
  ///   'cameraContextSeen': false,
  ///   'meterEditContextSeen': false,
  ///   'trendsContextSeen': false,
  ///   'historyContextSeen': false,
  ///   'achievementContextSeen': false,
  /// });
  /// ```
  static TutorialProgress _decodeTutorial(Object? raw) {
    final map = _asMap(raw, field: 'tutorial');
    return TutorialProgress(
      mainCompleted: _requireBool(map, 'mainCompleted'),
      cameraContextSeen: _requireBool(map, 'cameraContextSeen'),
      meterEditContextSeen: _requireBool(map, 'meterEditContextSeen'),
      trendsContextSeen: _requireBool(map, 'trendsContextSeen'),
      historyContextSeen: _requireBool(map, 'historyContextSeen'),
      achievementContextSeen: _requireBool(map, 'achievementContextSeen'),
    );
  }

  static Map<String, Object?> _encodeUnlock(AchievementUnlock unlock) {
    return <String, Object?>{
      'id': unlock.id,
      'unlockedAt': unlock.unlockedAt.toUtc().toIso8601String(),
    };
  }

  static AchievementUnlock _decodeUnlock(Object? raw) {
    final map = _asMap(raw, field: 'achievementUnlocks[]');
    return AchievementUnlock(
      id: _requireString(map, 'id'),
      unlockedAt: _parseUtcDateTime(
        _requireString(map, 'unlockedAt'),
        field: 'unlockedAt',
      ),
    );
  }

  static List<Object?> _requireList(Map<Object?, Object?> raw, String key) {
    if (!raw.containsKey(key)) {
      throw CogsavCorruptException('data.json に $key が無い');
    }
    final value = raw[key];
    if (value is! List<Object?>) {
      if (value is List) {
        return value.cast<Object?>();
      }
      throw CogsavCorruptException('$key が配列でない');
    }
    return value;
  }

  static Map<Object?, Object?> _requireMap(
    Map<Object?, Object?> raw,
    String key,
  ) {
    if (!raw.containsKey(key)) {
      throw CogsavCorruptException('data.json に $key が無い');
    }
    return _asMap(raw[key], field: key);
  }

  static Map<Object?, Object?> _asMap(Object? raw, {required String field}) {
    if (raw is Map<Object?, Object?>) {
      return raw;
    }
    if (raw is Map) {
      return raw.cast<Object?, Object?>();
    }
    throw CogsavCorruptException('$field がオブジェクトでない');
  }

  static String _requireString(Map<Object?, Object?> raw, String key) {
    final value = raw[key];
    if (value is! String) {
      throw CogsavCorruptException('$key が文字列でない');
    }
    return value;
  }

  static String? _optionalString(Map<Object?, Object?> raw, String key) {
    if (!raw.containsKey(key)) {
      throw CogsavCorruptException('$key が無い');
    }
    final value = raw[key];
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw CogsavCorruptException('$key が文字列でない');
    }
    return value;
  }

  static bool _requireBool(Map<Object?, Object?> raw, String key) {
    final value = raw[key];
    if (value is! bool) {
      throw CogsavCorruptException('$key が真偽値でない');
    }
    return value;
  }

  static int _requireInt(Map<Object?, Object?> raw, String key) {
    final value = raw[key];
    if (value is int) {
      return value;
    }
    throw CogsavCorruptException('$key が整数でない');
  }

  static double _requireDouble(Map<Object?, Object?> raw, String key) {
    final value = raw[key];
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    throw CogsavCorruptException('$key が数値でない');
  }

  static double? _optionalDouble(Map<Object?, Object?> raw, String key) {
    final value = raw[key];
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    throw CogsavCorruptException('$key が数値でない');
  }

  static DateTime _parseUtcDateTime(String raw, {required String field}) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      throw CogsavCorruptException('$field の日時が不正');
    }
    return parsed.toUtc();
  }

  static String? _formatLocalDate(DateTime? date) {
    if (date == null) {
      return null;
    }
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime? _parseLocalDate(Object? raw, {required String field}) {
    if (raw == null) {
      return null;
    }
    if (raw is! String) {
      throw CogsavCorruptException('$field が文字列でない');
    }
    final parts = raw.split('-');
    if (parts.length != 3) {
      throw CogsavCorruptException('$field の日付が不正');
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      throw CogsavCorruptException('$field の日付が不正');
    }
    return DateTime(year, month, day);
  }
}
