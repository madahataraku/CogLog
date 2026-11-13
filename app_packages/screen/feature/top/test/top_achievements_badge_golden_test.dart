import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_top/src/view/top_screen_body.dart';
import 'package:screen_feature_top/src/viewmodel/top_screen_view_model.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';
import 'package:usecase_load_top_screen/usecase_load_top_screen.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_save_top_screen_metric/usecase_save_top_screen_metric.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

final class _Nav implements ScreenNavigation {
  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  Future<ExerciseHistoryEditPopResult?> openExerciseHistoryEditAndWait({
    required String id,
  }) async => null;

  @override
  void openAppSettings() {}

  @override
  Future<void> openAchievements() async {}

  @override
  void openDebug() {}

  @override
  void openNotificationSettings() {}

  @override
  void openOssLicenses() {}

  @override
  void openOssLicenseDetail({required String packageName}) {}

  @override
  void pop() {}

  @override
  void popWithResult<T extends Object?>(T result) {}

  @override
  void goToHomeTab() {}
}

final class _LoadTop implements LoadTopScreenUsecase {
  _LoadTop({required this.hasNew});

  final bool hasNew;

  @override
  Future<LoadTopScreenResult> execute(LoadTopScreenRequest request) async {
    return LoadTopScreenResult(
      metric: PeriodTotalMetric.calories,
      today: PeriodAggregate.empty,
      week: PeriodAggregate.empty,
      month: PeriodAggregate.empty,
      goal: DailyGoal.unset,
      todayHistories: const [],
      consecutiveExerciseDays: 0,
      consecutiveGoalAchievementDays: 0,
      daysSincePreviousExerciseDay: null,
      hasNewAchievements: hasNew,
    );
  }
}

final class _SaveMetric implements SaveTopScreenMetricUsecase {
  @override
  Future<SaveTopScreenMetricResult> execute(
    SaveTopScreenMetricRequest request,
  ) async {
    return SaveTopScreenMetricResult(metric: request.metric);
  }
}

final class _Advice implements GenerateTopAdviceUsecase {
  @override
  Future<GenerateTopAdviceResult> execute(
    GenerateTopAdviceRequest request,
  ) async {
    return const GenerateTopAdviceResult(advice: '', tone: AdviceTone.fun);
  }
}

final class _Guidance implements EvaluateOnDeviceLlmGuidanceUsecase {
  @override
  Future<OnDeviceLlmGuidanceDecision> execute() async {
    return const OnDeviceLlmGuidanceDecision(shouldShow: false);
  }
}

final class _Prepare implements PrepareOnDeviceLlmModelUsecase {
  @override
  Future<void> execute() async {}
}

final class _NewIndicator implements LoadAchievementNewIndicatorUsecase {
  @override
  Future<bool> execute({required DateTime now}) async => false;
}

Future<void> _pumpTop(WidgetTester tester, {required bool hasNew}) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  tester.platformDispatcher.localesTestValue = const [Locale('ja')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await LocalizeStringDelegate.injectDelegateForTest(
    arbJson: StringsTestHelper.ja,
  );
  addTearDown(LocalizeStringDelegate.resetDelegateForTest);

  final container = ProviderContainer(
    overrides: [
      screenNavigationProvider.overrideWith((ref) => _Nav()),
      LoadTopScreenUsecase.provider.overrideWith(
        (ref) => _LoadTop(hasNew: hasNew),
      ),
      SaveTopScreenMetricUsecase.provider.overrideWith((ref) => _SaveMetric()),
      GenerateTopAdviceUsecase.provider.overrideWith((ref) => _Advice()),
      EvaluateOnDeviceLlmGuidanceUsecase.provider.overrideWith(
        (ref) => _Guidance(),
      ),
      PrepareOnDeviceLlmModelUsecase.provider.overrideWith((ref) => _Prepare()),
      LoadAchievementNewIndicatorUsecase.provider.overrideWith(
        (ref) => _NewIndicator(),
      ),
      ModelDownloadGuidanceProviders.session.overrideWith(
        (ref) => OnDeviceLlmGuidanceSession(),
      ),
    ],
  );
  addTearDown(container.dispose);

  final viewModel = container.read(TopScreenViewModel.provider);
  await viewModel.onInitialize(
    locale: 'ja',
    noExercise: const AdviceTemplate(text: 'a', tone: AdviceTone.realized),
    fallbackTemplates: const [AdviceTemplate(text: 'b', tone: AdviceTone.fun)],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('ja'),
        home: FTheme(
          data: FThemeData(touch: true, colors: FColors.neutralLight),
          child: const TopScreenBody(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ホーム trophy 新規なし / ja / Android / light', (tester) async {
    try {
      await _pumpTop(tester, hasNew: false);
      await expectLater(
        find.byType(TopScreenBody),
        matchesGoldenFile('goldens/top_achievements_badge_off.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('ホーム trophy 新規あり / ja / Android / light', (tester) async {
    try {
      await _pumpTop(tester, hasNew: true);
      await expectLater(
        find.byType(TopScreenBody),
        matchesGoldenFile('goldens/top_achievements_badge_on.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
