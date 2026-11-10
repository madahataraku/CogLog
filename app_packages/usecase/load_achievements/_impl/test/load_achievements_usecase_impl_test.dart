import 'dart:typed_data';

import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:data_repository_achievement_testing/data_repository_achievement_testing.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';
import 'package:usecase_evaluate_achievements_impl/usecase_evaluate_achievements_impl.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';
import 'package:usecase_load_achievements_impl/usecase_load_achievements_impl.dart';

void main() {
  final now = DateTime(2026, 11, 10, 15);
  final photo = Uint8List.fromList([1]);

  LoadAchievementsUsecaseImpl build({
    required AchievementRepository achievements,
    required ExerciseHistoryRepository histories,
  }) {
    return LoadAchievementsUsecaseImpl(
      achievements: achievements,
      histories: histories,
      evaluate: EvaluateAchievementsUsecaseImpl(
        achievements: achievements,
        histories: histories,
      ),
    );
  }

  test('履歴と獲得を合わせて行を返す', () async {
    final achievements = MemoryAchievementRepository();
    await achievements.mergeUnlocks([
      AchievementUnlock(
        id: 'first_record',
        unlockedAt: DateTime.utc(2026, 11, 1),
      ),
    ]);
    final histories = MemoryExerciseHistoryRepository();
    await histories.create(
      creationStartedAt: DateTime(2026, 11, 10, 10),
      capturedAt: DateTime(2026, 11, 10, 10),
      recordedAt: DateTime(2026, 11, 10, 10),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 30),
      caloriesKcal: 100,
      averageSpeedKmh: 2,
      photoBytes: photo,
    );

    final result = await build(
      achievements: achievements,
      histories: histories,
    ).execute(LoadAchievementsRequest(now: now));

    expect(result, isA<LoadAchievementsSuccess>());
    final rows = (result as LoadAchievementsSuccess).rows;
    expect(rows, hasLength(AchievementCatalog.all.length));
    expect(rows.first.id, AchievementCatalog.all.first.id);
    final first = rows.firstWhere((row) => row.id == 'first_record');
    expect(first.unlocked, isTrue);
    expect(first.progressRatio, 1);
    expect(first.binaryProgress, isTrue);
  });

  test('獲得が空でも過去履歴の充足分を遡及して開放表示する', () async {
    final achievements = MemoryAchievementRepository();
    final histories = MemoryExerciseHistoryRepository();
    await histories.create(
      creationStartedAt: DateTime(2026, 11, 10, 10),
      capturedAt: DateTime(2026, 11, 10, 10),
      recordedAt: DateTime(2026, 11, 10, 10),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 30),
      caloriesKcal: 100,
      averageSpeedKmh: 2,
      photoBytes: photo,
    );

    expect(await achievements.readUnlocks(), isEmpty);

    final result = await build(
      achievements: achievements,
      histories: histories,
    ).execute(LoadAchievementsRequest(now: now));

    expect(result, isA<LoadAchievementsSuccess>());
    final rows = (result as LoadAchievementsSuccess).rows;
    final first = rows.firstWhere((row) => row.id == 'first_record');
    expect(first.unlocked, isTrue);
    expect(await achievements.readUnlocks(), isNotEmpty);
  });

  test('読込例外は failed', () async {
    final result = await build(
      achievements: _ThrowingAchievementRepository(),
      histories: MemoryExerciseHistoryRepository(),
    ).execute(LoadAchievementsRequest(now: now));

    expect(result, isA<LoadAchievementsFailed>());
  });

  test('履歴読込例外は failed', () async {
    final result = await build(
      achievements: MemoryAchievementRepository(),
      histories: _ThrowingExerciseHistoryRepository(),
    ).execute(LoadAchievementsRequest(now: now));

    expect(result, isA<LoadAchievementsFailed>());
  });
}

/// [readUnlocks] で必ず失敗する。
final class _ThrowingAchievementRepository implements AchievementRepository {
  /// 失敗用のリポジトリを作る。
  ///
  /// Example:
  /// ```dart
  /// _ThrowingAchievementRepository();
  /// ```
  const _ThrowingAchievementRepository();

  @override
  Future<void> mergeUnlocks(List<AchievementUnlock> unlocks) async {}

  @override
  Future<List<AchievementUnlock>> readUnlocks() async {
    throw StateError('read failed');
  }
}

/// [list] で必ず失敗する。
final class _ThrowingExerciseHistoryRepository
    implements ExerciseHistoryRepository {
  /// 失敗用のリポジトリを作る。
  ///
  /// Example:
  /// ```dart
  /// _ThrowingExerciseHistoryRepository();
  /// ```
  const _ThrowingExerciseHistoryRepository();

  @override
  Future<ExerciseHistory> create({
    required DateTime creationStartedAt,
    required DateTime capturedAt,
    required DateTime recordedAt,
    required bool recordedAtManuallySet,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
    required double averageSpeedKmh,
    required Uint8List photoBytes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<ExerciseHistory?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<ExerciseHistory>> list() async {
    throw StateError('list failed');
  }

  @override
  Future<List<ExerciseHistory>> listPage({
    required int year,
    required int month,
    required int offset,
    required int limit,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String?> photoAbsolutePath(String id) {
    throw UnimplementedError();
  }

  @override
  Future<ExerciseHistory> update({
    required String id,
    required DateTime creationStartedAt,
    required DateTime capturedAt,
    required DateTime recordedAt,
    required bool recordedAtManuallySet,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
    required double averageSpeedKmh,
    Uint8List? photoBytes,
  }) {
    throw UnimplementedError();
  }
}
