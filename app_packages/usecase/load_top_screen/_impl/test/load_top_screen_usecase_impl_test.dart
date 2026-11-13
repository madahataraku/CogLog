import 'package:data_repository_daily_goal_testing/data_repository_daily_goal_testing.dart';
import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:data_repository_top_screen_metric_testing/data_repository_top_screen_metric_testing.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';
import 'package:usecase_load_top_screen/usecase_load_top_screen.dart';
import 'package:usecase_load_top_screen_impl/usecase_load_top_screen_impl.dart';

ExerciseHistory ride({
  required DateTime recordedAt,
  double distanceKm = 1,
  double caloriesKcal = 1,
  String id = '11111111-1111-4111-8111-111111111111',
}) {
  return ExerciseHistory(
    id: id,
    savedAt: recordedAt,
    creationStartedAt: recordedAt,
    capturedAt: recordedAt,
    recordedAt: recordedAt,
    recordedAtManuallySet: false,
    distanceKm: distanceKm,
    duration: const Duration(minutes: 1),
    caloriesKcal: caloriesKcal,
    averageSpeedKmh: 1,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
    healthWorkoutId: null,
  );
}

final class _FixedNewIndicator implements LoadAchievementNewIndicatorUsecase {
  const _FixedNewIndicator([this.value = false]);
  final bool value;
  @override
  Future<bool> execute({required DateTime now}) async => value;
}

void main() {
  final now = DateTime(2026, 11, 5, 15);

  test('履歴が無いときは消費カロリーで、3期間とも履歴が無い', () async {
    final result = await LoadTopScreenUsecaseImpl(
      histories: const FixedExerciseHistoryRepository([]),
      metrics: MemoryTopScreenMetricRepository(),
      goals: MemoryDailyGoalRepository(),
      newIndicator: const _FixedNewIndicator(),
    ).execute(LoadTopScreenRequest(now: now));

    expect(result.metric, PeriodTotalMetric.calories);
    expect(result.today.hasHistory, isFalse);
    expect(result.week.hasHistory, isFalse);
    expect(result.month.hasHistory, isFalse);
    expect(result.goal.duration, isNull);
    expect(result.todayHistories, isEmpty);
    expect(result.consecutiveExerciseDays, 0);
    expect(result.consecutiveGoalAchievementDays, 0);
    expect(result.daysSincePreviousExerciseDay, isNull);
  });

  test('11月5日、11月1日、10月31日をそれぞれの期間へ入れる', () async {
    final result = await LoadTopScreenUsecaseImpl(
      histories: FixedExerciseHistoryRepository([
        ride(recordedAt: DateTime(2026, 11, 5, 12)),
        ride(
          recordedAt: DateTime(2026, 11, 1, 12),
          id: '22222222-2222-4222-8222-222222222222',
        ),
        ride(
          recordedAt: DateTime(2026, 10, 31, 12),
          id: '33333333-3333-4333-8333-333333333333',
        ),
      ]),
      metrics: MemoryTopScreenMetricRepository(),
      goals: MemoryDailyGoalRepository(),
      newIndicator: const _FixedNewIndicator(),
    ).execute(LoadTopScreenRequest(now: now));

    expect(result.today.count, 1);
    expect(result.week.count, 1);
    expect(result.month.count, 2);
    expect(result.todayHistories, hasLength(1));
    expect(result.todayHistories.single.recordedAt, DateTime(2026, 11, 5, 12));
    expect(result.consecutiveExerciseDays, 1);
  });

  test('連続した日の履歴は consecutiveExerciseDays に数える', () async {
    final result = await LoadTopScreenUsecaseImpl(
      histories: FixedExerciseHistoryRepository([
        ride(recordedAt: DateTime(2026, 11, 5, 12)),
        ride(
          recordedAt: DateTime(2026, 11, 4, 12),
          id: '22222222-2222-4222-8222-222222222222',
        ),
        ride(
          recordedAt: DateTime(2026, 11, 2, 12),
          id: '33333333-3333-4333-8333-333333333333',
        ),
      ]),
      metrics: MemoryTopScreenMetricRepository(),
      goals: MemoryDailyGoalRepository(),
      newIndicator: const _FixedNewIndicator(),
    ).execute(LoadTopScreenRequest(now: now));

    expect(result.consecutiveExerciseDays, 2);
  });

  test('連続目標達成日数を返す', () async {
    final goals = MemoryDailyGoalRepository();
    await goals.write(const DailyGoal(caloriesKcal: 100));
    final result = await LoadTopScreenUsecaseImpl(
      histories: FixedExerciseHistoryRepository([
        ride(recordedAt: DateTime(2026, 11, 5, 10), caloriesKcal: 100),
        ride(
          recordedAt: DateTime(2026, 11, 4, 10),
          caloriesKcal: 100,
          id: '22222222-2222-4222-8222-222222222222',
        ),
      ]),
      metrics: MemoryTopScreenMetricRepository(),
      goals: goals,
      newIndicator: const _FixedNewIndicator(),
    ).execute(LoadTopScreenRequest(now: now));

    expect(result.consecutiveGoalAchievementDays, 2);
  });

  test('直前運動日からの暦日差を返す', () async {
    final result = await LoadTopScreenUsecaseImpl(
      histories: FixedExerciseHistoryRepository([
        ride(recordedAt: DateTime(2026, 10, 29, 12)),
      ]),
      metrics: MemoryTopScreenMetricRepository(),
      goals: MemoryDailyGoalRepository(),
      newIndicator: const _FixedNewIndicator(),
    ).execute(LoadTopScreenRequest(now: now));

    expect(result.daysSincePreviousExerciseDay, 7);
  });

  test('1.14 km が 2 件の表記は 2.3', () async {
    final result = await LoadTopScreenUsecaseImpl(
      histories: FixedExerciseHistoryRepository([
        ride(recordedAt: DateTime(2026, 11, 5, 10), distanceKm: 1.14),
        ride(
          recordedAt: DateTime(2026, 11, 5, 11),
          distanceKm: 1.14,
          id: '22222222-2222-4222-8222-222222222222',
        ),
      ]),
      metrics: MemoryTopScreenMetricRepository(),
      goals: MemoryDailyGoalRepository(),
      newIndicator: const _FixedNewIndicator(),
    ).execute(LoadTopScreenRequest(now: now));

    expect(result.today.distanceKm, closeTo(2.28, 1e-9));
    expect(
      PeriodTotalText.of(
        aggregate: result.today,
        metric: PeriodTotalMetric.distance,
      ),
      '2.3',
    );
    expect(result.todayHistories, hasLength(2));
  });

  test('保存した指標で再び読む', () async {
    final metrics = MemoryTopScreenMetricRepository();
    await metrics.write(PeriodTotalMetric.duration);
    final result = await LoadTopScreenUsecaseImpl(
      histories: const FixedExerciseHistoryRepository([]),
      metrics: metrics,
      goals: MemoryDailyGoalRepository(),
      newIndicator: const _FixedNewIndicator(),
    ).execute(LoadTopScreenRequest(now: now));

    expect(result.metric, PeriodTotalMetric.duration);
  });

  test('目標が未設定のとき goal は unset', () async {
    final result = await LoadTopScreenUsecaseImpl(
      histories: const FixedExerciseHistoryRepository([]),
      metrics: MemoryTopScreenMetricRepository(),
      goals: MemoryDailyGoalRepository(),
      newIndicator: const _FixedNewIndicator(),
    ).execute(LoadTopScreenRequest(now: now));

    expect(result.goal.hasDuration, isFalse);
    expect(result.goal.hasCalories, isFalse);
    expect(result.goal.hasDistance, isFalse);
  });

  test('保存した目標を返す', () async {
    final goals = MemoryDailyGoalRepository();
    const saved = DailyGoal(
      duration: Duration(minutes: 30),
      caloriesKcal: 200,
      distanceKm: 5,
    );
    await goals.write(saved);

    final result = await LoadTopScreenUsecaseImpl(
      histories: const FixedExerciseHistoryRepository([]),
      metrics: MemoryTopScreenMetricRepository(),
      goals: goals,
      newIndicator: const _FixedNewIndicator(),
    ).execute(LoadTopScreenRequest(now: now));

    expect(result.goal.duration, const Duration(minutes: 30));
    expect(result.goal.caloriesKcal, 200);
    expect(result.goal.distanceKm, 5);
  });

  test('withMetric は goal と todayHistories を保つ', () async {
    final goals = MemoryDailyGoalRepository();
    const saved = DailyGoal(caloriesKcal: 100);
    await goals.write(saved);
    final todayRide = ride(recordedAt: DateTime(2026, 11, 5, 10));
    final result = await LoadTopScreenUsecaseImpl(
      histories: FixedExerciseHistoryRepository([todayRide]),
      metrics: MemoryTopScreenMetricRepository(),
      goals: goals,
      newIndicator: const _FixedNewIndicator(),
    ).execute(LoadTopScreenRequest(now: now));

    final swapped = result.withMetric(PeriodTotalMetric.distance);
    expect(swapped.metric, PeriodTotalMetric.distance);
    expect(swapped.goal.caloriesKcal, 100);
    expect(swapped.todayHistories, hasLength(1));
    expect(swapped.today, result.today);
    expect(swapped.consecutiveExerciseDays, result.consecutiveExerciseDays);
    expect(
      swapped.consecutiveGoalAchievementDays,
      result.consecutiveGoalAchievementDays,
    );
    expect(
      swapped.daysSincePreviousExerciseDay,
      result.daysSincePreviousExerciseDay,
    );
    expect(swapped.hasNewAchievements, result.hasNewAchievements);
  });

  test('newIndicator が true なら hasNewAchievements true', () async {
    final result = await LoadTopScreenUsecaseImpl(
      histories: const FixedExerciseHistoryRepository([]),
      metrics: MemoryTopScreenMetricRepository(),
      goals: MemoryDailyGoalRepository(),
      newIndicator: const _FixedNewIndicator(true),
    ).execute(LoadTopScreenRequest(now: now));
    expect(result.hasNewAchievements, isTrue);
  });
}
