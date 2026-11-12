import 'dart:typed_data';

import 'package:data_repository_achievement_testing/data_repository_achievement_testing.dart';
import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:test/test.dart';
import 'package:usecase_evaluate_achievements/usecase_evaluate_achievements.dart';
import 'package:usecase_evaluate_achievements_impl/usecase_evaluate_achievements_impl.dart';

void main() {
  final now = DateTime(2026, 11, 10, 15);
  final photo = Uint8List.fromList([1]);

  Future<void> addHistory(
    MemoryExerciseHistoryRepository histories,
    DateTime recordedAt,
  ) {
    return histories.create(
      creationStartedAt: recordedAt,
      capturedAt: recordedAt,
      recordedAt: recordedAt,
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 30),
      caloriesKcal: 100,
      averageSpeedKmh: 2,
      healthWorkoutId: null,
      photoBytes: photo,
    );
  }

  test('unlocks 空+過去達成なら emit true でも merge あり newly 空', () async {
    final achievements = MemoryAchievementRepository();
    final histories = MemoryExerciseHistoryRepository();
    await addHistory(histories, DateTime(2026, 11, 9, 10));

    final result = await EvaluateAchievementsUsecaseImpl(
      achievements: achievements,
      histories: histories,
    ).execute(EvaluateAchievementsRequest(now: now, emitNotifications: true));

    expect(result.newlyUnlocked, isEmpty);
    final unlocks = await achievements.readUnlocks();
    expect(unlocks.map((u) => u.id), contains('first_record'));
  });

  test('既に unlock あり+新規なら emit true で newly に載る', () async {
    final achievements = MemoryAchievementRepository();
    await achievements.mergeUnlocks([
      AchievementUnlock(
        id: 'first_record',
        unlockedAt: DateTime.utc(2026, 11, 1),
      ),
    ]);
    final histories = MemoryExerciseHistoryRepository();
    await addHistory(histories, DateTime(2026, 11, 8, 10));
    await addHistory(histories, DateTime(2026, 11, 9, 10));
    await addHistory(histories, DateTime(2026, 11, 10, 10));

    final result = await EvaluateAchievementsUsecaseImpl(
      achievements: achievements,
      histories: histories,
    ).execute(EvaluateAchievementsRequest(now: now, emitNotifications: true));

    expect(result.newlyUnlocked.map((u) => u.id), contains('streak_3'));
    final unlocks = await achievements.readUnlocks();
    expect(unlocks.map((u) => u.id), containsAll(['first_record', 'streak_3']));
  });

  test('emit false なら新規達成でも newly 空', () async {
    final achievements = MemoryAchievementRepository();
    await achievements.mergeUnlocks([
      AchievementUnlock(
        id: 'first_record',
        unlockedAt: DateTime.utc(2026, 11, 1),
      ),
    ]);
    final histories = MemoryExerciseHistoryRepository();
    await addHistory(histories, DateTime(2026, 11, 8, 10));
    await addHistory(histories, DateTime(2026, 11, 9, 10));
    await addHistory(histories, DateTime(2026, 11, 10, 10));

    final result = await EvaluateAchievementsUsecaseImpl(
      achievements: achievements,
      histories: histories,
    ).execute(EvaluateAchievementsRequest(now: now, emitNotifications: false));

    expect(result.newlyUnlocked, isEmpty);
    final unlocks = await achievements.readUnlocks();
    expect(unlocks.map((u) => u.id), contains('streak_3'));
  });

  test('既存 unlockedAt は評価後も維持する', () async {
    final achievements = MemoryAchievementRepository();
    final original = DateTime.utc(2026, 10, 1);
    await achievements.mergeUnlocks([
      AchievementUnlock(id: 'first_record', unlockedAt: original),
    ]);
    final histories = MemoryExerciseHistoryRepository();
    await addHistory(histories, DateTime(2026, 11, 10, 10));

    await EvaluateAchievementsUsecaseImpl(
      achievements: achievements,
      histories: histories,
    ).execute(EvaluateAchievementsRequest(now: now, emitNotifications: true));

    final unlocks = await achievements.readUnlocks();
    final first = unlocks.firstWhere((u) => u.id == 'first_record');
    expect(first.unlockedAt, original);
  });
}
