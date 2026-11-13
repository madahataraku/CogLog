import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
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

const _templateA = AdviceTemplate(text: '定型A', tone: AdviceTone.fun);
const _templateB = AdviceTemplate(text: '定型B', tone: AdviceTone.happy);
const _templateC = AdviceTemplate(text: '定型C', tone: AdviceTone.fun);

GenerateTopAdviceRequest request({
  List<ExerciseHistory> histories = const [],
  DailyGoal goal = DailyGoal.unset,
  int consecutiveExerciseDays = 0,
  DateTime? now,
  int consecutiveGoalAchievementDays = 0,
  int? daysSincePreviousExerciseDay,
}) => GenerateTopAdviceRequest(
  histories: histories,
  locale: 'ja',
  now: now ?? DateTime(2026, 11, 5, 12),
  goal: goal,
  consecutiveExerciseDays: consecutiveExerciseDays,
  consecutiveGoalAchievementDays: consecutiveGoalAchievementDays,
  daysSincePreviousExerciseDay: daysSincePreviousExerciseDay,
  noExercise: const AdviceTemplate(
    text: '今日はまだ運動していません',
    tone: AdviceTone.realized,
  ),
  conditionalCatalog: ConditionalAdviceCatalog(),
  metricLabels: const {
    ConditionalAdviceMetric.distance: '距離',
    ConditionalAdviceMetric.calories: 'カロリー',
    ConditionalAdviceMetric.duration: '時間',
  },
  fallbackTemplates: const [_templateA, _templateB, _templateC],
);

void main() {
  test('履歴が空のときは未運動定型で LLM を呼ばない', () async {
    final llm = FakeOnDeviceLlm(response: '生成文');
    final result = await GenerateTopAdviceUsecaseImpl(
      llm: llm,
      picker: const FixedAdviceTemplatePicker(),
    ).execute(request());

    expect(result.advice, '今日はまだ運動していません');
    expect(result.tone, AdviceTone.realized);
    expect(llm.generateCallCount, 0);
  });

  test('LLM 成功時は TONE/ADVICE 形式を解析して返す', () async {
    final llm = FakeOnDeviceLlm(response: 'TONE=happy\nADVICE=よく動けた');
    final result =
        await GenerateTopAdviceUsecaseImpl(
          llm: llm,
          picker: const FixedAdviceTemplatePicker(),
        ).execute(
          request(
            histories: [ride(recordedAt: DateTime(2026, 11, 5, 12))],
            goal: const DailyGoal(caloriesKcal: 200, distanceKm: 5),
            consecutiveExerciseDays: 3,
          ),
        );

    expect(result.advice, 'よく動けた');
    expect(result.tone, AdviceTone.happy);
    expect(llm.generateCallCount, 1);
    expect(llm.lastPrompt, contains('locale=ja'));
    expect(llm.lastPrompt, contains('distanceKm=2.0'));
    expect(llm.lastPrompt, contains('caloriesKcal=80.0'));
    expect(llm.lastPrompt, contains('goalCaloriesKcal=200.0'));
    expect(llm.lastPrompt, contains('goalDistanceKm=5.0'));
    expect(llm.lastPrompt, isNot(contains('goalDurationMinutes=')));
    expect(llm.lastPrompt, contains('consecutiveExerciseDays=3'));
    expect(llm.lastPrompt, contains('Speak as a calm guide'));
    expect(
      llm.lastPrompt,
      contains('When locale=ja, write ADVICE in polite です・ます Japanese'),
    );
    expect(llm.lastPrompt, contains('state the gap factually only'));
    expect(llm.lastPrompt, contains('aim for at most about 150 characters'));
    expect(llm.lastPrompt, contains('fun, confused, happy, realized'));
    expect(llm.lastPrompt, contains('TONE='));
    expect(
      llm.lastPrompt,
      isNot(contains('Reply in the language of locale=ja')),
    );
  });

  test('目標未設定のとき goal=unset を送る', () async {
    final llm = FakeOnDeviceLlm(response: 'TONE=fun\nADVICE=ok');
    await GenerateTopAdviceUsecaseImpl(
      llm: llm,
      picker: const FixedAdviceTemplatePicker(),
    ).execute(
      request(histories: [ride(recordedAt: DateTime(2026, 11, 5, 12))]),
    );
    expect(llm.lastPrompt, contains('goal=unset'));
    expect(llm.lastPrompt, contains('consecutiveExerciseDays=0'));
  });

  test('LLM 失敗時は定型を返す', () async {
    final llm = FakeOnDeviceLlm(throwOnGenerate: true);
    final result =
        await GenerateTopAdviceUsecaseImpl(
          llm: llm,
          picker: const FixedAdviceTemplatePicker(index: 1),
        ).execute(
          request(histories: [ride(recordedAt: DateTime(2026, 11, 5, 12))]),
        );

    expect(result.advice, '定型B');
    expect(result.tone, AdviceTone.happy);
    expect(llm.generateCallCount, 1);
  });

  test('LLM 利用不可のときは定型で generate しない', () async {
    final llm = FakeOnDeviceLlm(available: false);
    final result =
        await GenerateTopAdviceUsecaseImpl(
          llm: llm,
          picker: const FixedAdviceTemplatePicker(),
        ).execute(
          request(histories: [ride(recordedAt: DateTime(2026, 11, 5, 12))]),
        );

    expect(result.advice, '定型A');
    expect(result.tone, AdviceTone.fun);
    expect(llm.generateCallCount, 0);
  });

  test('isAvailable 失敗時は定型へフォールバックする', () async {
    final llm = FakeOnDeviceLlm(throwOnIsAvailable: true);
    final result =
        await GenerateTopAdviceUsecaseImpl(
          llm: llm,
          picker: const FixedAdviceTemplatePicker(),
        ).execute(
          request(histories: [ride(recordedAt: DateTime(2026, 11, 5, 12))]),
        );

    expect(result.advice, '定型A');
    expect(result.tone, AdviceTone.fun);
    expect(llm.generateCallCount, 0);
  });

  test('generate タイムアウト時は定型へフォールバックする', () async {
    final llm = FakeOnDeviceLlm(hangOnGenerate: true);
    final result =
        await GenerateTopAdviceUsecaseImpl(
          llm: llm,
          picker: const FixedAdviceTemplatePicker(index: 2),
          generateTimeout: const Duration(milliseconds: 20),
        ).execute(
          request(histories: [ride(recordedAt: DateTime(2026, 11, 5, 12))]),
        );

    expect(result.advice, '定型C');
    expect(result.tone, AdviceTone.fun);
    expect(llm.generateCallCount, 1);
  });

  test('解析後本文が空のときは定型へフォールバックする', () async {
    final llm = FakeOnDeviceLlm(response: 'TONE=happy\nADVICE=');
    final result =
        await GenerateTopAdviceUsecaseImpl(
          llm: llm,
          picker: const FixedAdviceTemplatePicker(),
        ).execute(
          request(histories: [ride(recordedAt: DateTime(2026, 11, 5, 12))]),
        );

    expect(result.advice, '定型A');
    expect(result.tone, AdviceTone.fun);
  });
}
