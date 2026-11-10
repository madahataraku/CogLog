import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';
import 'package:usecase_generate_top_advice_impl/usecase_generate_top_advice_impl.dart';

ExerciseHistory ride({required DateTime recordedAt}) {
  const id = '11111111-1111-4111-8111-111111111111';
  return ExerciseHistory(
    id: id,
    savedAt: recordedAt,
    creationStartedAt: recordedAt,
    capturedAt: recordedAt,
    recordedAt: recordedAt,
    recordedAtManuallySet: false,
    distanceKm: 2,
    duration: const Duration(minutes: 20),
    caloriesKcal: 80,
    averageSpeedKmh: 6,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
  );
}

void main() {
  const builder = DefaultTopAdvicePromptBuilder();

  test('設定済み目標と連続日数・150文字指示を含む', () {
    final prompt = builder.build(
      histories: [ride(recordedAt: DateTime(2026, 11, 5, 12))],
      locale: 'ja',
      goal: const DailyGoal(duration: Duration(minutes: 30), caloriesKcal: 200),
      consecutiveExerciseDays: 4,
    );

    expect(prompt, contains('goalDurationMinutes=30'));
    expect(prompt, contains('goalCaloriesKcal=200.0'));
    expect(prompt, isNot(contains('goalDistanceKm=')));
    expect(prompt, contains('consecutiveExerciseDays=4'));
    expect(prompt, contains('Compare today totals with any set goals'));
    expect(prompt, contains('Praise the consecutive exercise-day streak'));
    expect(prompt, contains('at most about 150 characters'));
    expect(prompt, contains('TONE='));
    expect(prompt, contains('ADVICE='));
  });
}
