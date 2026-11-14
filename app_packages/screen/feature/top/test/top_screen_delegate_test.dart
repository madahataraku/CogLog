import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/on_acknowledge_gemma_meter_guidance_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/on_acknowledge_model_download_guidance_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/on_evaluate_gemma_meter_guidance_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/on_initialize_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/on_select_metric_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/top_screen_state_to_entity_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/state/top_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_gemma_meter_guidance/usecase_gemma_meter_guidance.dart';
import 'package:usecase_load_top_screen/usecase_load_top_screen.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_save_top_screen_metric/usecase_save_top_screen_metric.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

final class _Load implements LoadTopScreenUsecase {
  _Load(this.result);

  final LoadTopScreenResult result;
  var calls = 0;
  LoadTopScreenRequest? lastRequest;

  @override
  Future<LoadTopScreenResult> execute(LoadTopScreenRequest request) async {
    calls += 1;
    lastRequest = request;
    return result;
  }
}

final class _Advice implements GenerateTopAdviceUsecase {
  _Advice({this.advice = '定型', this.tone = AdviceTone.fun});

  final String advice;
  final AdviceTone tone;
  var calls = 0;
  GenerateTopAdviceRequest? lastRequest;

  @override
  Future<GenerateTopAdviceResult> execute(
    GenerateTopAdviceRequest request,
  ) async {
    calls += 1;
    lastRequest = request;
    return GenerateTopAdviceResult(advice: advice, tone: tone);
  }
}

final class _Save implements SaveTopScreenMetricUsecase {
  _Save({this.error});

  final Object? error;
  var calls = 0;

  @override
  Future<SaveTopScreenMetricResult> execute(
    SaveTopScreenMetricRequest request,
  ) async {
    calls += 1;
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return SaveTopScreenMetricResult(metric: request.metric);
  }
}

final class _Evaluate implements EvaluateOnDeviceLlmGuidanceUsecase {
  _Evaluate({this.shouldShow = false, this.delay = Duration.zero});

  final bool shouldShow;
  final Duration delay;
  var calls = 0;

  @override
  Future<OnDeviceLlmGuidanceDecision> execute() async {
    calls += 1;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return OnDeviceLlmGuidanceDecision(shouldShow: shouldShow);
  }
}

final class _EvaluateGemma implements EvaluateGemmaMeterGuidanceUsecase {
  _EvaluateGemma({this.shouldShow = false});

  final bool shouldShow;
  var calls = 0;

  @override
  Future<GemmaMeterGuidanceDecision> execute() async {
    calls += 1;
    return GemmaMeterGuidanceDecision(shouldShow: shouldShow);
  }
}

const _noExercise = AdviceTemplate(
  text: '今日はまだ運動していません',
  tone: AdviceTone.realized,
);
const _fallbackTemplates = [
  AdviceTemplate(text: 'a', tone: AdviceTone.fun),
  AdviceTemplate(text: 'b', tone: AdviceTone.happy),
  AdviceTemplate(text: 'c', tone: AdviceTone.fun),
];

final _conditionalCatalog = ConditionalAdviceCatalog(
  over300: const [AdviceTemplate(text: 'over', tone: AdviceTone.realized)],
);

const _metricLabels = {
  ConditionalAdviceMetric.distance: '走行距離',
  ConditionalAdviceMetric.calories: '消費カロリー',
  ConditionalAdviceMetric.duration: '運動時間',
};

const _loadResult = LoadTopScreenResult(
  metric: PeriodTotalMetric.calories,
  today: PeriodAggregate(
    count: 1,
    distanceKm: 1.25,
    caloriesKcal: 1.25,
    duration: Duration(minutes: 1),
  ),
  week: PeriodAggregate.empty,
  month: PeriodAggregate.empty,
  goal: DailyGoal.unset,
  todayHistories: [],
  consecutiveExerciseDays: 0,
  consecutiveGoalAchievementDays: 0,
  daysSincePreviousExerciseDay: null,
  hasNewAchievements: false,
);

Future<void> _runInitialize({
  required MutableStateStream<TopScreenState> state,
  LoadTopScreenUsecase? load,
  GenerateTopAdviceUsecase? advice,
  EvaluateOnDeviceLlmGuidanceUsecase? evaluateA,
  EvaluateGemmaMeterGuidanceUsecase? evaluateB,
  OnDeviceLlmGuidanceSession? guidanceSession,
  GemmaMeterGuidanceSession? gemmaSession,
}) {
  return OnInitializeDelegate(
    state: state,
    loadTopScreenUsecase: load ?? _Load(_loadResult),
    generateTopAdviceUsecase: advice ?? _Advice(),
    evaluateOnDeviceLlmGuidanceUsecase: evaluateA ?? _Evaluate(),
    evaluateGemmaMeterGuidanceUsecase: evaluateB ?? _EvaluateGemma(),
    guidanceSession: guidanceSession ?? OnDeviceLlmGuidanceSession(),
    gemmaSession: gemmaSession ?? GemmaMeterGuidanceSession(),
  ).execute(
    locale: 'ja',
    noExercise: _noExercise,
    fallbackTemplates: _fallbackTemplates,
    conditionalCatalog: _conditionalCatalog,
    metricLabels: _metricLabels,
  );
}

void main() {
  late MutableStateStream<TopScreenState> state;

  setUp(() {
    state = MutableStateStream(TopScreenState.initial);
  });

  tearDown(() async {
    await state.close();
  });

  test('初期化で合計とアドバイスを入れ、loaded にする', () async {
    final load = _Load(_loadResult);
    final advice = _Advice(advice: '今日はまだ運動していません', tone: AdviceTone.happy);
    await _runInitialize(state: state, load: load, advice: advice);

    expect(state.state.loaded, isTrue);
    expect(state.state.today.count, 1);
    expect(state.state.goal, DailyGoal.unset);
    expect(state.state.adviceText, '今日はまだ運動していません');
    expect(state.state.adviceTone, AdviceTone.happy);
    expect(state.state.pendingModelDownloadGuidance, isFalse);
    expect(state.state.pendingGemmaMeterGuidance, isFalse);
    expect(load.calls, 1);
    expect(advice.calls, 1);
    expect(advice.lastRequest?.locale, 'ja');
    expect(
      advice.lastRequest?.consecutiveGoalAchievementDays,
      _loadResult.consecutiveGoalAchievementDays,
    );
    expect(
      advice.lastRequest?.daysSincePreviousExerciseDay,
      _loadResult.daysSincePreviousExerciseDay,
    );
    expect(advice.lastRequest?.conditionalCatalog, _conditionalCatalog);
    expect(advice.lastRequest?.metricLabels, _metricLabels);
  });

  test('Load と Advice で同じ now を渡す', () async {
    final load = _Load(_loadResult);
    final advice = _Advice();
    await _runInitialize(state: state, load: load, advice: advice);

    expect(load.lastRequest?.now, advice.lastRequest?.now);
  });

  test('OnInitialize を 2 回呼ぶと Generate も 2 回', () async {
    final load = _Load(_loadResult);
    final advice = _Advice();
    await _runInitialize(state: state, load: load, advice: advice);
    await _runInitialize(state: state, load: load, advice: advice);

    expect(load.calls, 2);
    expect(advice.calls, 2);
  });

  test('未ダウンロードかつ未提示なら pending true', () async {
    await _runInitialize(state: state, evaluateA: _Evaluate(shouldShow: true));
    expect(state.state.loaded, isTrue);
    expect(state.state.pendingModelDownloadGuidance, isTrue);
    expect(state.state.pendingGemmaMeterGuidance, isFalse);
  });

  test('期間合計は誘導判定より先に loaded になる', () async {
    final evaluate = _Evaluate(
      shouldShow: true,
      delay: const Duration(milliseconds: 50),
    );
    final future = _runInitialize(state: state, evaluateA: evaluate);

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(state.state.loaded, isTrue);
    expect(state.state.adviceText, '定型');
    expect(state.state.pendingModelDownloadGuidance, isFalse);
    expect(evaluate.calls, 1);

    await future;
    expect(state.state.pendingModelDownloadGuidance, isTrue);
  });

  test('markPresented 済みなら pending false かつ評価しない', () async {
    final session = OnDeviceLlmGuidanceSession()..markPresented();
    final evaluate = _Evaluate(shouldShow: true);
    final evaluateGemma = _EvaluateGemma(shouldShow: true);
    await _runInitialize(
      state: state,
      evaluateA: evaluate,
      evaluateB: evaluateGemma,
      guidanceSession: session,
    );
    expect(state.state.pendingModelDownloadGuidance, isFalse);
    expect(evaluate.calls, 0);
    expect(state.state.pendingGemmaMeterGuidance, isTrue);
    expect(evaluateGemma.calls, 1);
  });

  test('誘導不要なら pending false', () async {
    await _runInitialize(state: state);
    expect(state.state.pendingModelDownloadGuidance, isFalse);
    expect(state.state.pendingGemmaMeterGuidance, isFalse);
  });

  test('(A) を出さないとき (B) が pending になる', () async {
    final evaluateGemma = _EvaluateGemma(shouldShow: true);
    await _runInitialize(state: state, evaluateB: evaluateGemma);
    expect(state.state.pendingModelDownloadGuidance, isFalse);
    expect(state.state.pendingGemmaMeterGuidance, isTrue);
    expect(evaluateGemma.calls, 1);
  });

  test('(A) pending のとき initialize では (B) を評価しない', () async {
    final evaluateGemma = _EvaluateGemma(shouldShow: true);
    await _runInitialize(
      state: state,
      evaluateA: _Evaluate(shouldShow: true),
      evaluateB: evaluateGemma,
    );
    expect(state.state.pendingModelDownloadGuidance, isTrue);
    expect(state.state.pendingGemmaMeterGuidance, isFalse);
    expect(evaluateGemma.calls, 0);
  });

  test('(A) 後の evaluate で (B) pending になる', () async {
    final evaluateGemma = _EvaluateGemma(shouldShow: true);
    final gemmaSession = GemmaMeterGuidanceSession();
    await OnEvaluateGemmaMeterGuidanceDelegate(
      state: state,
      evaluateGemmaMeterGuidanceUsecase: evaluateGemma,
      gemmaSession: gemmaSession,
    ).execute();
    expect(state.state.pendingGemmaMeterGuidance, isTrue);
    expect(evaluateGemma.calls, 1);
  });

  test('gemma markPresented 済みなら (B) を評価しない', () async {
    final evaluateGemma = _EvaluateGemma(shouldShow: true);
    final gemmaSession = GemmaMeterGuidanceSession()..markPresented();
    await _runInitialize(
      state: state,
      evaluateB: evaluateGemma,
      gemmaSession: gemmaSession,
    );
    expect(state.state.pendingGemmaMeterGuidance, isFalse);
    expect(evaluateGemma.calls, 0);
  });

  test('acknowledge 後は pending false かつ hasPresented', () async {
    state = MutableStateStream(
      const TopScreenState(
        loaded: true,
        metric: PeriodTotalMetric.calories,
        today: PeriodAggregate.empty,
        week: PeriodAggregate.empty,
        month: PeriodAggregate.empty,
        goal: DailyGoal.unset,
        adviceText: '',
        adviceTone: AdviceTone.fun,
        pendingModelDownloadGuidance: true,
        pendingGemmaMeterGuidance: false,
        hasNewAchievements: true,
      ),
    );
    final session = OnDeviceLlmGuidanceSession();
    await OnAcknowledgeModelDownloadGuidanceDelegate(
      state: state,
      session: session,
    ).execute();
    expect(state.state.pendingModelDownloadGuidance, isFalse);
    expect(state.state.hasNewAchievements, isTrue);
    expect(session.hasPresented, isTrue);
  });

  test('gemma acknowledge 後は pending false かつ hasPresented', () async {
    state = MutableStateStream(
      const TopScreenState(
        loaded: true,
        metric: PeriodTotalMetric.calories,
        today: PeriodAggregate.empty,
        week: PeriodAggregate.empty,
        month: PeriodAggregate.empty,
        goal: DailyGoal.unset,
        adviceText: '',
        adviceTone: AdviceTone.fun,
        pendingModelDownloadGuidance: false,
        pendingGemmaMeterGuidance: true,
        hasNewAchievements: true,
      ),
    );
    final session = GemmaMeterGuidanceSession();
    await OnAcknowledgeGemmaMeterGuidanceDelegate(
      state: state,
      session: session,
    ).execute();
    expect(state.state.pendingGemmaMeterGuidance, isFalse);
    expect(state.state.hasNewAchievements, isTrue);
    expect(session.hasPresented, isTrue);
  });

  test('未読込の指標選択は状態を変えない', () async {
    final save = _Save();
    await OnSelectMetricDelegate(
      state: state,
      saveTopScreenMetricUsecase: save,
    ).execute(PeriodTotalMetric.distance);

    expect(state.state.metric, PeriodTotalMetric.calories);
    expect(save.calls, 0);
  });

  test('指標選択は合計を読み直さない', () async {
    state = MutableStateStream(
      const TopScreenState(
        loaded: true,
        metric: PeriodTotalMetric.calories,
        today: PeriodAggregate(
          count: 1,
          distanceKm: 1.25,
          caloriesKcal: 4,
          duration: Duration(minutes: 1),
        ),
        week: PeriodAggregate.empty,
        month: PeriodAggregate.empty,
        goal: DailyGoal(caloriesKcal: 200),
        adviceText: '助言',
        adviceTone: AdviceTone.confused,
        pendingModelDownloadGuidance: false,
        pendingGemmaMeterGuidance: false,
        hasNewAchievements: false,
      ),
    );
    final save = _Save();
    await OnSelectMetricDelegate(
      state: state,
      saveTopScreenMetricUsecase: save,
    ).execute(PeriodTotalMetric.distance);

    expect(state.state.metric, PeriodTotalMetric.distance);
    expect(state.state.today.distanceKm, 1.25);
    expect(state.state.goal.caloriesKcal, 200);
    expect(state.state.adviceText, '助言');
    expect(state.state.adviceTone, AdviceTone.confused);
    expect(save.calls, 1);
  });

  test('保存が失敗したときは指標を変えない', () async {
    state = MutableStateStream(
      const TopScreenState(
        loaded: true,
        metric: PeriodTotalMetric.calories,
        today: PeriodAggregate.empty,
        week: PeriodAggregate.empty,
        month: PeriodAggregate.empty,
        goal: DailyGoal.unset,
        adviceText: '',
        adviceTone: AdviceTone.fun,
        pendingModelDownloadGuidance: false,
        pendingGemmaMeterGuidance: false,
        hasNewAchievements: false,
      ),
    );
    await expectLater(
      OnSelectMetricDelegate(
        state: state,
        saveTopScreenMetricUsecase: _Save(error: StateError('save')),
      ).execute(PeriodTotalMetric.distance),
      throwsStateError,
    );
    expect(state.state.metric, PeriodTotalMetric.calories);
  });

  test('空の合計は -- で、1.25 kcal は 1.3', () {
    const delegate = TopScreenStateToEntityDelegate();
    expect(delegate.execute(TopScreenState.initial).todayText, '--');
    final entity = delegate.execute(
      const TopScreenState(
        loaded: true,
        metric: PeriodTotalMetric.calories,
        today: PeriodAggregate(
          count: 1,
          distanceKm: 1,
          caloriesKcal: 1.25,
          duration: Duration(minutes: 1),
        ),
        week: PeriodAggregate.empty,
        month: PeriodAggregate.empty,
        goal: DailyGoal.unset,
        adviceText: '定型',
        adviceTone: AdviceTone.realized,
        pendingModelDownloadGuidance: false,
        pendingGemmaMeterGuidance: false,
        hasNewAchievements: false,
      ),
    );
    expect(entity.todayText, '1.3');
    expect(entity.weekText, '--');
    expect(entity.adviceText, '定型');
    expect(entity.adviceTone, AdviceTone.realized);
    expect(entity.pendingModelDownloadGuidance, isFalse);
    expect(entity.pendingGemmaMeterGuidance, isFalse);
    expect(entity.calories.isUnset, isTrue);
  });

  test('達成率 150% の Entity は lap とパーセントを持つ', () {
    final entity = const TopScreenStateToEntityDelegate().execute(
      const TopScreenState(
        loaded: true,
        metric: PeriodTotalMetric.calories,
        today: PeriodAggregate(
          count: 1,
          distanceKm: 0,
          caloriesKcal: 300,
          duration: Duration.zero,
        ),
        week: PeriodAggregate.empty,
        month: PeriodAggregate.empty,
        goal: DailyGoal(caloriesKcal: 200),
        adviceText: '',
        adviceTone: AdviceTone.fun,
        pendingModelDownloadGuidance: false,
        pendingGemmaMeterGuidance: false,
        hasNewAchievements: false,
      ),
    );
    expect(entity.calories.percentText, '150%');
    expect(entity.calories.lap1, 1);
    expect(entity.calories.lap2, 0.5);
    expect(entity.calories.actualText, '300.0');
    expect(entity.calories.goalText, '200.0');
  });

  test('目標 0 は進捗ゼロ', () {
    final entity = const TopScreenStateToEntityDelegate().execute(
      const TopScreenState(
        loaded: true,
        metric: PeriodTotalMetric.calories,
        today: PeriodAggregate(
          count: 1,
          distanceKm: 1,
          caloriesKcal: 50,
          duration: Duration(minutes: 10),
        ),
        week: PeriodAggregate.empty,
        month: PeriodAggregate.empty,
        goal: DailyGoal(
          duration: Duration.zero,
          caloriesKcal: 0,
          distanceKm: 0,
        ),
        adviceText: '',
        adviceTone: AdviceTone.fun,
        pendingModelDownloadGuidance: false,
        pendingGemmaMeterGuidance: false,
        hasNewAchievements: false,
      ),
    );
    expect(entity.duration.percentText, '0%');
    expect(entity.duration.lap1, 0);
    expect(entity.duration.lap2, 0);
    expect(entity.calories.percentText, '0%');
    expect(entity.distance.percentText, '0%');
  });
}
