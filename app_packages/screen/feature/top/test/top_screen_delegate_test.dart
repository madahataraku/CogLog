import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/on_acknowledge_model_download_guidance_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/on_initialize_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/on_select_metric_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/top_screen_state_to_entity_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/state/top_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_load_top_screen/usecase_load_top_screen.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_save_top_screen_metric/usecase_save_top_screen_metric.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

final class _Load implements LoadTopScreenUsecase {
  _Load(this.result);

  final LoadTopScreenResult result;
  var calls = 0;

  @override
  Future<LoadTopScreenResult> execute(LoadTopScreenRequest request) async {
    calls += 1;
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
  _Evaluate({this.shouldShow = false});

  final bool shouldShow;
  var calls = 0;

  @override
  Future<OnDeviceLlmGuidanceDecision> execute() async {
    calls += 1;
    return OnDeviceLlmGuidanceDecision(shouldShow: shouldShow);
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
);

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
    await OnInitializeDelegate(
      state: state,
      loadTopScreenUsecase: load,
      generateTopAdviceUsecase: advice,
      evaluateOnDeviceLlmGuidanceUsecase: _Evaluate(),
      guidanceSession: OnDeviceLlmGuidanceSession(),
    ).execute(
      locale: 'ja',
      noExercise: _noExercise,
      fallbackTemplates: _fallbackTemplates,
    );

    expect(state.state.loaded, isTrue);
    expect(state.state.today.count, 1);
    expect(state.state.goal, DailyGoal.unset);
    expect(state.state.adviceText, '今日はまだ運動していません');
    expect(state.state.adviceTone, AdviceTone.happy);
    expect(state.state.pendingModelDownloadGuidance, isFalse);
    expect(load.calls, 1);
    expect(advice.calls, 1);
    expect(advice.lastRequest?.locale, 'ja');
  });

  test('OnInitialize を 2 回呼ぶと Generate も 2 回', () async {
    final load = _Load(_loadResult);
    final advice = _Advice();
    final delegate = OnInitializeDelegate(
      state: state,
      loadTopScreenUsecase: load,
      generateTopAdviceUsecase: advice,
      evaluateOnDeviceLlmGuidanceUsecase: _Evaluate(),
      guidanceSession: OnDeviceLlmGuidanceSession(),
    );
    await delegate.execute(
      locale: 'ja',
      noExercise: _noExercise,
      fallbackTemplates: _fallbackTemplates,
    );
    await delegate.execute(
      locale: 'ja',
      noExercise: _noExercise,
      fallbackTemplates: _fallbackTemplates,
    );

    expect(load.calls, 2);
    expect(advice.calls, 2);
  });

  test('未ダウンロードかつ未提示なら pending true', () async {
    await OnInitializeDelegate(
      state: state,
      loadTopScreenUsecase: _Load(_loadResult),
      generateTopAdviceUsecase: _Advice(),
      evaluateOnDeviceLlmGuidanceUsecase: _Evaluate(shouldShow: true),
      guidanceSession: OnDeviceLlmGuidanceSession(),
    ).execute(
      locale: 'ja',
      noExercise: _noExercise,
      fallbackTemplates: _fallbackTemplates,
    );
    expect(state.state.pendingModelDownloadGuidance, isTrue);
  });

  test('markPresented 済みなら pending false', () async {
    final session = OnDeviceLlmGuidanceSession()..markPresented();
    await OnInitializeDelegate(
      state: state,
      loadTopScreenUsecase: _Load(_loadResult),
      generateTopAdviceUsecase: _Advice(),
      evaluateOnDeviceLlmGuidanceUsecase: _Evaluate(shouldShow: true),
      guidanceSession: session,
    ).execute(
      locale: 'ja',
      noExercise: _noExercise,
      fallbackTemplates: _fallbackTemplates,
    );
    expect(state.state.pendingModelDownloadGuidance, isFalse);
  });

  test('誘導不要なら pending false', () async {
    await OnInitializeDelegate(
      state: state,
      loadTopScreenUsecase: _Load(_loadResult),
      generateTopAdviceUsecase: _Advice(),
      evaluateOnDeviceLlmGuidanceUsecase: _Evaluate(),
      guidanceSession: OnDeviceLlmGuidanceSession(),
    ).execute(
      locale: 'ja',
      noExercise: _noExercise,
      fallbackTemplates: _fallbackTemplates,
    );
    expect(state.state.pendingModelDownloadGuidance, isFalse);
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
      ),
    );
    final session = OnDeviceLlmGuidanceSession();
    await OnAcknowledgeModelDownloadGuidanceDelegate(
      state: state,
      session: session,
    ).execute();
    expect(state.state.pendingModelDownloadGuidance, isFalse);
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
      ),
    );
    expect(entity.todayText, '1.3');
    expect(entity.weekText, '--');
    expect(entity.adviceText, '定型');
    expect(entity.adviceTone, AdviceTone.realized);
    expect(entity.pendingModelDownloadGuidance, isFalse);
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
      ),
    );
    expect(entity.duration.percentText, '0%');
    expect(entity.duration.lap1, 0);
    expect(entity.duration.lap2, 0);
    expect(entity.calories.percentText, '0%');
    expect(entity.distance.percentText, '0%');
  });
}
