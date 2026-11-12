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
    healthWorkoutId: null,
  );
}

void main() {
  const builder = DefaultTopAdvicePromptBuilder();

  test('設定済み目標と連続日数・声と優先・150文字指示を含む', () {
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
    expect(prompt, contains('Speak as a calm guide'));
    expect(prompt, contains('Avoid doctor-like tone'));
    expect(
      prompt,
      contains('When locale=ja, write ADVICE in polite です・ます Japanese'),
    );
    expect(prompt, contains('relation to any set goals'));
    expect(prompt, contains('state the gap factually only'));
    expect(prompt, contains('aim for at most about 150 characters'));
    expect(prompt, contains('TONE='));
    expect(prompt, contains('ADVICE='));
  });
}
