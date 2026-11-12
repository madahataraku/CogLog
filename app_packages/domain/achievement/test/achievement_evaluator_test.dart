import 'package:domain_achievement/domain_achievement.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

ExerciseHistory ride({
  required DateTime recordedAt,
  String id = '11111111-1111-4111-8111-111111111111',
  double distanceKm = 1,
  Duration duration = const Duration(minutes: 1),
  double caloriesKcal = 1,
}) {
  return ExerciseHistory(
    id: id,
    savedAt: recordedAt,
    creationStartedAt: recordedAt,
    capturedAt: recordedAt,
    recordedAt: recordedAt,
    recordedAtManuallySet: false,
    distanceKm: distanceKm,
    duration: duration,
    caloriesKcal: caloriesKcal,
    averageSpeedKmh: 1,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
    healthWorkoutId: null,
  );
}

AchievementProgress progressOf(List<AchievementProgress> all, String id) {
  return all.firstWhere((progress) => progress.id == id);
}

void main() {
  final now = DateTime(2026, 11, 10, 12);

  group('AchievementEvaluator', () {
    // テスト対象:
    // AchievementEvaluator.evaluate / maxStreakDays
    //
    // テスト内容:
    // 連続日 1,2,3 と孤立日 10 があるとき、史上最長連続は 3 になる。
    test('日付 1,2,3 と 10 なら maxStreak は 3', () {
      final progress = AchievementEvaluator.evaluate([
        ride(recordedAt: DateTime(2026, 11, 1, 10)),
        ride(
          recordedAt: DateTime(2026, 11, 2, 10),
          id: '22222222-2222-4222-8222-222222222222',
        ),
        ride(
          recordedAt: DateTime(2026, 11, 3, 10),
          id: '33333333-3333-4333-8333-333333333333',
        ),
        ride(
          recordedAt: DateTime(2026, 11, 10, 10),
          id: '44444444-4444-4444-8444-444444444444',
        ),
      ], now);

      final streak3 = progressOf(progress, 'streak_3');
      expect(streak3.current, 3, reason: '史上最長連続日数は 3 であること');
      expect(streak3.achieved, isTrue, reason: 'streak_3 は達成であること');
      expect(
        progressOf(progress, 'streak_7').achieved,
        isFalse,
        reason: 'streak_7 は未達であること',
      );
    });

    // テスト対象:
    // AchievementEvaluator.evaluate / uniqueDays
    //
    // テスト内容:
    // 同日に 2 件記録してもユニーク日数は 1 になる。
    test('同日 2 件なら uniqueDays は 1', () {
      final progress = AchievementEvaluator.evaluate([
        ride(recordedAt: DateTime(2026, 11, 5, 10)),
        ride(
          recordedAt: DateTime(2026, 11, 5, 18),
          id: '22222222-2222-4222-8222-222222222222',
        ),
      ], now);

      expect(
        progressOf(progress, 'unique_100').current,
        1,
        reason: '同日複数はユニーク日数 1 と数えること',
      );
      expect(
        progressOf(progress, 'same_day_2').achieved,
        isTrue,
        reason: '同一日 2 回で same_day_2 を達成すること',
      );
    });

    // テスト対象:
    // AchievementEvaluator.evaluate / singleDuration
    //
    // テスト内容:
    // 1 回の運動時間がちょうど 600 秒のとき single_duration_10m を達成する。
    test('duration ちょうど 600 秒なら single_duration_10m を達成', () {
      final progress = AchievementEvaluator.evaluate([
        ride(
          recordedAt: DateTime(2026, 11, 5, 10),
          duration: const Duration(seconds: 600),
        ),
      ], now);

      final single10 = progressOf(progress, 'single_duration_10m');
      expect(single10.current, 600, reason: '最長 1 回時間が 600 秒であること');
      expect(single10.achieved, isTrue, reason: '閾値ちょうどで達成すること');
      expect(single10.ratio, 1.0, reason: '達成率は 1.0 であること');
    });

    // テスト対象:
    // AchievementEvaluator.evaluate / bestDistanceUpdate
    //
    // テスト内容:
    // 履歴が 1 件だけのときは best_distance を達成しない。
    test('1 件のみなら best_distance は未達', () {
      final progress = AchievementEvaluator.evaluate([
        ride(recordedAt: DateTime(2026, 11, 5, 10), distanceKm: 12),
      ], now);

      final best = progressOf(progress, 'best_distance');
      expect(best.achieved, isFalse, reason: '初回記録では自己ベスト更新にならないこと');
      expect(best.ratio, 0.0, reason: '二値未達の進捗比は 0.0 であること');
    });

    // テスト対象:
    // AchievementEvaluator.evaluate / bestDistanceUpdate
    //
    // テスト内容:
    // 2 件目で走行距離が過去最高を超えたとき best_distance を達成する。
    test('2 件目で距離更新なら best_distance を達成', () {
      final progress = AchievementEvaluator.evaluate([
        ride(recordedAt: DateTime(2026, 11, 5, 10), distanceKm: 5),
        ride(
          recordedAt: DateTime(2026, 11, 6, 10),
          id: '22222222-2222-4222-8222-222222222222',
          distanceKm: 6,
        ),
      ], now);

      final best = progressOf(progress, 'best_distance');
      expect(best.achieved, isTrue, reason: '2 件目の距離更新で達成すること');
      expect(best.ratio, 1.0, reason: '二値達成の進捗比は 1.0 であること');
    });

    // テスト対象:
    // AchievementEvaluator.evaluate / gapRestartDays
    //
    // テスト内容:
    // 隣接する運動日の差が 31 日なら gap_restart_30 を達成する。
    test('日間隔 31 なら gap_restart_30 を達成', () {
      final progress = AchievementEvaluator.evaluate([
        ride(recordedAt: DateTime(2026, 1, 1, 10)),
        ride(
          recordedAt: DateTime(2026, 2, 1, 10),
          id: '22222222-2222-4222-8222-222222222222',
        ),
      ], now);

      final gap = progressOf(progress, 'gap_restart_30');
      expect(gap.achieved, isTrue, reason: '間隔 31 日（30 日超）で達成すること');
      expect(gap.ratio, 1.0, reason: '二値達成の進捗比は 1.0 であること');
    });

    // テスト対象:
    // AchievementEvaluator.evaluate / yearEndNewYearSeason
    //
    // テスト内容:
    // 年末年始 6 日のうち 1 日欠けると進捗比は 5/6 で未達になる。
    test('年末年始で 1 日欠けると ratio は 5/6', () {
      final progress = AchievementEvaluator.evaluate([
        ride(recordedAt: DateTime(2025, 12, 29, 10)),
        ride(
          recordedAt: DateTime(2025, 12, 30, 10),
          id: '22222222-2222-4222-8222-222222222222',
        ),
        // 12/31 欠
        ride(
          recordedAt: DateTime(2026, 1, 1, 10),
          id: '33333333-3333-4333-8333-333333333333',
        ),
        ride(
          recordedAt: DateTime(2026, 1, 2, 10),
          id: '44444444-4444-4444-8444-444444444444',
        ),
        ride(
          recordedAt: DateTime(2026, 1, 3, 10),
          id: '55555555-5555-4555-8555-555555555555',
        ),
      ], now);

      final yearEnd = progressOf(progress, 'year_end_new_year');
      expect(yearEnd.current, 5, reason: 'シーズン内ヒット日数は 5 であること');
      expect(yearEnd.target, 6, reason: '目標は 6 日であること');
      expect(yearEnd.ratio, closeTo(5 / 6, 1e-9), reason: '進捗比は 5/6 であること');
      expect(yearEnd.achieved, isFalse, reason: '6 日未満は未達であること');
    });

    // テスト対象:
    // AchievementLocalDate.calendarDaysBetween
    //
    // テスト内容:
    // 絶対時刻差が 23 時間でも、年月日が 1 日進めば暦日差は 1 になる。
    test('暦日差は絶対時刻が 23 時間でも年月日差を返す', () {
      final dayBefore = DateTime(2026, 3, 7);
      final almostNextLocalMidnight = dayBefore.add(const Duration(hours: 23));
      expect(
        almostNextLocalMidnight.difference(dayBefore).inDays,
        0,
        reason: '前提: 23 時間差の inDays は 0 であること',
      );
      expect(
        AchievementLocalDate.calendarDaysBetween(
          dayBefore,
          DateTime(2026, 3, 8),
        ),
        1,
        reason: '隣接する年月日の暦日差は 1 であること',
      );
    });

    // テスト対象:
    // AchievementEvaluator.evaluate / leapDay
    //
    // テスト内容:
    // 2 月 29 日の記録があれば leap_day を達成し、無ければ未達の二値進捗になる。
    test('うるう日の記録があれば leap_day を達成', () {
      final withLeap = AchievementEvaluator.evaluate([
        ride(recordedAt: DateTime(2024, 2, 29, 10)),
      ], now);
      final withoutLeap = AchievementEvaluator.evaluate([
        ride(recordedAt: DateTime(2024, 2, 28, 10)),
      ], now);

      expect(
        progressOf(withLeap, 'leap_day').achieved,
        isTrue,
        reason: '2/29 の記録で leap_day を達成すること',
      );
      expect(
        progressOf(withLeap, 'leap_day').ratio,
        1.0,
        reason: '達成時の二値進捗比は 1.0 であること',
      );
      expect(
        progressOf(withoutLeap, 'leap_day').achieved,
        isFalse,
        reason: '2/28 だけでは leap_day 未達であること',
      );
      expect(
        progressOf(withoutLeap, 'leap_day').ratio,
        0.0,
        reason: '未達時の二値進捗比は 0.0 であること',
      );
    });
  });
}
