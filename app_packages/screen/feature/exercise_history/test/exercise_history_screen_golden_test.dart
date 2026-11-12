import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history/screen_feature_exercise_history.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/exercise_history_screen_view_model.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';
import 'package:usecase_load_exercise_history_month_impl/usecase_load_exercise_history_month_impl.dart';

final class _Nav implements ScreenNavigation {
  @override
  void openExerciseHistoryDetail({required String id}) {}

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
  void goToHomeTab() {}
}

final class _FailingLoadMonth implements LoadExerciseHistoryMonthUsecase {
  @override
  Future<LoadExerciseHistoryMonthResult> execute(
    LoadExerciseHistoryMonthRequest request,
  ) async => throw StateError('fail');
}

ExerciseHistory _history({required String id, required DateTime recordedAt}) =>
    ExerciseHistory(
      id: id,
      savedAt: recordedAt,
      creationStartedAt: recordedAt,
      capturedAt: recordedAt,
      recordedAt: recordedAt,
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 30),
      caloriesKcal: 10,
      averageSpeedKmh: 2,
      photoRelativePath: 'exercise_histories/$id/meter.jpg',
      healthWorkoutId: null,
    );

Future<void> _prepareSurface(WidgetTester tester) async {
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
}

Widget _wrap(Widget child) => ShellTabIndexScope(
  index: 3,
  child: MaterialApp(
    locale: const Locale('ja'),
    home: FTheme(
      data: FThemeData(touch: true, colors: FColors.neutralLight),
      child: child,
    ),
  ),
);

List<Override> _monthOverrides(FixedExerciseHistoryRepository histories) => [
  LoadExerciseHistoryMonthUsecase.provider.overrideWith(
    (ref) => LoadExerciseHistoryMonthUsecaseImpl(histories: histories),
  ),
  screenNavigationProvider.overrideWithValue(_Nav()),
];

void main() {
  testWidgets('運動履歴カレンダー空月 / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    final container = ProviderContainer(
      overrides: _monthOverrides(const FixedExerciseHistoryRepository([])),
    );
    addTearDown(container.dispose);
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _wrap(const ExerciseHistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();
      final viewModel = container.read(ExerciseHistoryScreenViewModel.provider);
      await viewModel.onSelectMonth(year: 2026, month: 11);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ExerciseHistoryScreen),
        matchesGoldenFile('goldens/exercise_history_calendar_empty_month.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('運動履歴カレンダースタンプ / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    final histories = FixedExerciseHistoryRepository([
      _history(id: 'a', recordedAt: DateTime(2026, 11, 5, 10)),
      _history(id: 'b', recordedAt: DateTime(2026, 11, 5, 12)),
      _history(id: 'c', recordedAt: DateTime(2026, 11, 10)),
    ]);
    final container = ProviderContainer(overrides: _monthOverrides(histories));
    addTearDown(container.dispose);
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _wrap(const ExerciseHistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();
      final viewModel = container.read(ExerciseHistoryScreenViewModel.provider);
      await viewModel.onSelectMonth(year: 2026, month: 11);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ExerciseHistoryScreen),
        matchesGoldenFile('goldens/exercise_history_calendar_stamps.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('運動履歴カレンダーエラー / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    final container = ProviderContainer(
      overrides: [
        LoadExerciseHistoryMonthUsecase.provider.overrideWith(
          (ref) => _FailingLoadMonth(),
        ),
        screenNavigationProvider.overrideWithValue(_Nav()),
      ],
    );
    addTearDown(container.dispose);
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _wrap(const ExerciseHistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();
      final viewModel = container.read(ExerciseHistoryScreenViewModel.provider);
      await viewModel.onSelectMonth(year: 2026, month: 11);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ExerciseHistoryScreen),
        matchesGoldenFile('goldens/exercise_history_calendar_error.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
