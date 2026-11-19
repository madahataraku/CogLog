import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

ExerciseHistory ride({
  required DateTime recordedAt,
  required double caloriesKcal,
  String id = '11111111-1111-4111-8111-111111111111',
}) {
  return ExerciseHistory(
    id: id,
    savedAt: recordedAt,
    creationStartedAt: recordedAt,
    capturedAt: recordedAt,
    recordedAt: recordedAt,
    recordedAtManuallySet: false,
    distanceKm: 1,
    duration: const Duration(minutes: 30),
    caloriesKcal: caloriesKcal,
    averageSpeedKmh: 1,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
    healthWorkoutId: null,
  );
}

void main() {
  const goal = DailyGoal(caloriesKcal: 100);
  final now = DateTime(2026, 11, 5, 15);

  test('本日未達なら 0', () {
    expect(
      ConsecutiveGoalAchievementDays.of(
        [ride(recordedAt: DateTime(2026, 11, 5, 10), caloriesKcal: 50)],
        goal,
        now,
        null,
      ),
      0,
    );
  });

  test('本日達・昨日未達なら 1', () {
    expect(
      ConsecutiveGoalAchievementDays.of(
        [
          ride(recordedAt: DateTime(2026, 11, 5, 10), caloriesKcal: 100),
          ride(
            recordedAt: DateTime(2026, 11, 4, 10),
            caloriesKcal: 50,
            id: '22222222-2222-4222-8222-222222222222',
          ),
        ],
        goal,
        now,
        null,
      ),
      1,
    );
  });

  test('3 日連続達成', () {
    expect(
      ConsecutiveGoalAchievementDays.of(
        [
          ride(recordedAt: DateTime(2026, 11, 5, 10), caloriesKcal: 100),
          ride(
            recordedAt: DateTime(2026, 11, 4, 10),
            caloriesKcal: 100,
            id: '22222222-2222-4222-8222-222222222222',
          ),
          ride(
            recordedAt: DateTime(2026, 11, 3, 10),
            caloriesKcal: 100,
            id: '33333333-3333-4333-8333-333333333333',
          ),
        ],
        goal,
        now,
        null,
      ),
      3,
    );
  });

  test('countFrom より前は数えない', () {
    expect(
      ConsecutiveGoalAchievementDays.of(
        [
          ride(recordedAt: DateTime(2026, 11, 5, 10), caloriesKcal: 100),
          ride(
            recordedAt: DateTime(2026, 11, 4, 10),
            caloriesKcal: 100,
            id: '22222222-2222-4222-8222-222222222222',
          ),
          ride(
            recordedAt: DateTime(2026, 11, 3, 10),
            caloriesKcal: 100,
            id: '33333333-3333-4333-8333-333333333333',
          ),
        ],
        goal,
        now,
        DateTime(2026, 11, 4),
      ),
      2,
    );
  });

  test('日内複数回で合計達成', () {
    expect(
      ConsecutiveGoalAchievementDays.of(
        [
          ride(recordedAt: DateTime(2026, 11, 5, 10), caloriesKcal: 40),
          ride(
            recordedAt: DateTime(2026, 11, 5, 18),
            caloriesKcal: 60,
            id: '22222222-2222-4222-8222-222222222222',
          ),
        ],
        goal,
        now,
        null,
      ),
      1,
    );
  });

  test('m=5 で月〜金達成・土日休みでも連続は 5', () {
    final histories = <ExerciseHistory>[
      for (final (day, id) in [
        (9, '11111111-1111-4111-8111-111111111111'),
        (10, '22222222-2222-4222-8222-222222222222'),
        (11, '33333333-3333-4333-8333-333333333333'),
        (12, '44444444-4444-4444-8444-444444444444'),
        (13, '55555555-5555-4555-8555-555555555555'),
      ])
        ride(
          recordedAt: DateTime(2026, 11, day, 10),
          caloriesKcal: 100,
          id: id,
        ),
    ];
    expect(
      ConsecutiveGoalAchievementDays.of(
        histories,
        goal,
        DateTime(2026, 11, 13, 15),
        null,
        weeklyAchievementDays: 5,
      ),
      5,
    );
  });

  test('m=2 で前週2日＋今週1日なら連続は 3', () {
    final histories = [
      ride(
        recordedAt: DateTime(2026, 11, 2, 10),
        caloriesKcal: 100,
        id: '11111111-1111-4111-8111-111111111111',
      ),
      ride(
        recordedAt: DateTime(2026, 11, 4, 10),
        caloriesKcal: 100,
        id: '22222222-2222-4222-8222-222222222222',
      ),
      ride(
        recordedAt: DateTime(2026, 11, 9, 10),
        caloriesKcal: 100,
        id: '33333333-3333-4333-8333-333333333333',
      ),
    ];
    expect(
      ConsecutiveGoalAchievementDays.of(
        histories,
        goal,
        DateTime(2026, 11, 9, 15),
        null,
        weeklyAchievementDays: 2,
      ),
      3,
    );
  });

  test('前週が m 未満なら遡れない', () {
    final histories = [
      ride(
        recordedAt: DateTime(2026, 11, 3, 10),
        caloriesKcal: 100,
        id: '11111111-1111-4111-8111-111111111111',
      ),
      ride(
        recordedAt: DateTime(2026, 11, 9, 10),
        caloriesKcal: 100,
        id: '22222222-2222-4222-8222-222222222222',
      ),
    ];
    expect(
      ConsecutiveGoalAchievementDays.of(
        histories,
        goal,
        DateTime(2026, 11, 9, 15),
        null,
        weeklyAchievementDays: 3,
      ),
      1,
    );
  });

  test('週途中で到達不能なら 0', () {
    expect(
      ConsecutiveGoalAchievementDays.of(
        const [],
        goal,
        DateTime(2026, 11, 11, 15),
        null,
        weeklyAchievementDays: 5,
      ),
      0,
    );
  });

  test('休み枠を超える未達成で途切れる', () {
    final histories = [
      ride(
        recordedAt: DateTime(2026, 11, 9, 10),
        caloriesKcal: 100,
        id: '11111111-1111-4111-8111-111111111111',
      ),
    ];
    // m=6 → restBudget=1。火で1スキップ、水で超過→当日起点で連続 0。
    expect(
      ConsecutiveGoalAchievementDays.of(
        histories,
        goal,
        DateTime(2026, 11, 11, 15),
        null,
        weeklyAchievementDays: 6,
      ),
      0,
    );
  });
}
