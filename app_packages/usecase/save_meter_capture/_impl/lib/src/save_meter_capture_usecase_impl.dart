import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_health_workout/infra_health_workout.dart';
import 'package:usecase_evaluate_achievements/usecase_evaluate_achievements.dart';
import 'package:usecase_evaluate_daily_goal_auto_update/usecase_evaluate_daily_goal_auto_update.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';

/// 登録可能条件を満たすときだけ永続化し、ヘルス失敗でも成功とする。
///
/// Example:
/// ```dart
/// SaveMeterCaptureUsecaseImpl(
///   histories: histories,
///   health: health,
///   evaluateAutoUpdate: evaluateAutoUpdate,
///   evaluateAchievements: evaluateAchievements,
/// ).execute(
///   SaveMeterCaptureRequest(
///     creationStartedAt: DateTime.timestamp(),
///     capturedAt: DateTime.timestamp(),
///     recordedAt: DateTime.timestamp(),
///     recordedAtManuallySet: false,
///     distanceKm: 1,
///     duration: const Duration(minutes: 1),
///     caloriesKcal: 1,
///     averageSpeedKmh: 1,
///     photoBytes: Uint8List(0),
///   ),
/// );
/// ```
final class SaveMeterCaptureUsecaseImpl implements SaveMeterCaptureUsecase {
  /// [histories]・[health]・[evaluateAutoUpdate]・[evaluateAchievements] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// SaveMeterCaptureUsecaseImpl(
  ///   histories: histories,
  ///   health: health,
  ///   evaluateAutoUpdate: evaluateAutoUpdate,
  ///   evaluateAchievements: evaluateAchievements,
  /// );
  /// ```
  const SaveMeterCaptureUsecaseImpl({
    required this.histories,
    required this.health,
    required this.evaluateAutoUpdate,
    required this.evaluateAchievements,
    required this.syncReminder,
  });

  /// 運動履歴の保存先。
  final ExerciseHistoryRepository histories;

  /// ヘルスへのサイクリング書き込み。
  final HealthWorkoutWriter health;

  /// 保存後の目標自動更新。
  final EvaluateDailyGoalAutoUpdateUsecase evaluateAutoUpdate;

  /// 保存後のアチーブメント評価。
  final EvaluateAchievementsUsecase evaluateAchievements;

  /// 保存後のリマインド同期。
  final SyncExerciseReminderUsecase syncReminder;

  /// [request] を検証し、作成後にヘルスへ書き、自動更新とアチーブメントを判定する。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   SaveMeterCaptureRequest(
  ///     creationStartedAt: DateTime.timestamp(),
  ///     capturedAt: DateTime.timestamp(),
  ///     recordedAt: DateTime.timestamp(),
  ///     recordedAtManuallySet: false,
  ///     distanceKm: 1,
  ///     duration: const Duration(minutes: 1),
  ///     caloriesKcal: 1,
  ///     averageSpeedKmh: 1,
  ///     photoBytes: Uint8List(0),
  ///   ),
  /// );
  /// ```
  @override
  Future<SaveMeterCaptureResult> execute(
    SaveMeterCaptureRequest request,
  ) async {
    if (!_isValid(request)) {
      return const SaveMeterCaptureResult(
        outcome: SaveMeterCaptureOutcome.invalidInput,
      );
    }

    try {
      var history = await histories.create(
        creationStartedAt: request.creationStartedAt,
        capturedAt: request.capturedAt,
        recordedAt: request.recordedAt,
        recordedAtManuallySet: request.recordedAtManuallySet,
        distanceKm: request.distanceKm,
        duration: request.duration,
        caloriesKcal: request.caloriesKcal,
        averageSpeedKmh: request.averageSpeedKmh,
        healthWorkoutId: null,
        photoBytes: request.photoBytes,
      );

      final externalId = await _writeHealth(request);
      var healthWriteSucceeded = false;
      if (externalId != null) {
        history = await _attachHealthWorkoutId(history, externalId);
        healthWriteSucceeded = history.healthWorkoutId != null;
      }
      final now = DateTime.now();
      final autoUpdate = await evaluateAutoUpdate.execute(
        EvaluateDailyGoalAutoUpdateRequest(now: now),
      );
      try {
        await syncReminder.execute(SyncExerciseReminderRequest(now: now));
      } on Object {
        // 通知の同期失敗で、保存済みの履歴を saveFailed にしない。
      }

      var newlyUnlocked = const <AchievementUnlock>[];
      try {
        final evaluated = await evaluateAchievements.execute(
          EvaluateAchievementsRequest(now: now, emitNotifications: true),
        );
        newlyUnlocked = evaluated.newlyUnlocked;
      } on Object {
        // アチーブメント評価失敗でも保存 success を維持するため newly を空にする。
        newlyUnlocked = const [];
      }

      return SaveMeterCaptureResult(
        outcome: SaveMeterCaptureOutcome.success,
        history: history,
        healthWriteSucceeded: healthWriteSucceeded,
        goalAutoUpdated: autoUpdate.applied,
        newlyUnlockedAchievements: newlyUnlocked,
      );
    } on Object {
      return const SaveMeterCaptureResult(
        outcome: SaveMeterCaptureOutcome.saveFailed,
      );
    }
  }

  /// 登録可能条件を満たすか。
  ///
  /// Example:
  /// ```dart
  /// _isValid(request);
  /// ```
  static bool _isValid(SaveMeterCaptureRequest request) {
    if (request.duration <= Duration.zero) {
      return false;
    }
    if (request.distanceKm < 0 ||
        request.averageSpeedKmh < 0 ||
        request.caloriesKcal < 0) {
      return false;
    }
    return true;
  }

  /// ヘルスへ書き、失敗や例外は null にする。
  ///
  /// Example:
  /// ```dart
  /// await _writeHealth(request);
  /// ```
  Future<String?> _writeHealth(SaveMeterCaptureRequest request) async {
    try {
      final start = request.recordedAt;
      final end = request.recordedAt.add(request.duration);
      return await health.writeCycling(
        start: start,
        end: end,
        distanceKm: request.distanceKm,
        duration: request.duration,
        caloriesKcal: request.caloriesKcal,
      );
    } on Object {
      return null;
    }
  }

  /// [history] に [externalId] だけを付ける。失敗時は再試行し、なお失敗ならヘルスを消す。
  ///
  /// 付与に成功するまで最大 3 回試す。すべて失敗したら [health.deleteCycling] を
  /// best-effort で呼び、ID 無しの元の [history] を返す。
  ///
  /// Example:
  /// ```dart
  /// await _attachHealthWorkoutId(history, 'fake-health-1');
  /// ```
  Future<ExerciseHistory> _attachHealthWorkoutId(
    ExerciseHistory history,
    String externalId,
  ) async {
    const maxAttempts = 3;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await histories.attachHealthWorkoutId(
          id: history.id,
          healthWorkoutId: externalId,
        );
      } on Object {
        // 付与失敗で create 済みの履歴を saveFailed にしない。再試行する。
      }
    }
    try {
      await health.deleteCycling(externalId: externalId);
    } on Object {
      // 孤児削除の失敗でもローカル保存 success を維持する。
    }
    return history;
  }
}
