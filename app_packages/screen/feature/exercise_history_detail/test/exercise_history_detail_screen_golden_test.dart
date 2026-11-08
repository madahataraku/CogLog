import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history_detail/screen_feature_exercise_history_detail.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';
import 'package:usecase_load_exercise_history_detail_impl/usecase_load_exercise_history_detail_impl.dart';

final class _Nav implements ScreenNavigation {
  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  void pop() {}

  @override
  void goToHomeTab() {}
}

void main() {
  testWidgets('詳細の不在 / ja / Android / light', (tester) async {
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

    final histories = MemoryExerciseHistoryRepository();

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            LoadExerciseHistoryDetailUsecase.provider.overrideWith(
              (ref) =>
                  LoadExerciseHistoryDetailUsecaseImpl(histories: histories),
            ),
            screenNavigationProvider.overrideWithValue(_Nav()),
          ],
          child: MaterialApp(
            locale: const Locale('ja'),
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: const ExerciseHistoryDetailScreen(id: 'missing-id'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ExerciseHistoryDetailScreen),
        matchesGoldenFile('goldens/exercise_history_detail_missing.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('詳細の写真無し / ja / Android / light', (tester) async {
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

    const id = '11111111-1111-4111-8111-111111111111';
    final at = DateTime(2026, 11, 5, 12, 30);
    final history = ExerciseHistory(
      id: id,
      savedAt: at,
      creationStartedAt: at,
      capturedAt: at,
      recordedAt: at,
      recordedAtManuallySet: true,
      distanceKm: 1.25,
      duration: const Duration(minutes: 30),
      caloriesKcal: 12.34,
      averageSpeedKmh: 2.5,
      photoRelativePath: 'exercise_histories/$id/meter.jpg',
    );

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            LoadExerciseHistoryDetailUsecase.provider.overrideWith(
              (ref) => _FixedDetail(
                LoadExerciseHistoryDetailSuccess(
                  history: history,
                  photoAbsolutePath: null,
                ),
              ),
            ),
            screenNavigationProvider.overrideWithValue(_Nav()),
          ],
          child: MaterialApp(
            locale: const Locale('ja'),
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: const ExerciseHistoryDetailScreen(id: id),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ExerciseHistoryDetailScreen),
        matchesGoldenFile('goldens/exercise_history_detail_no_photo.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

final class _FixedDetail implements LoadExerciseHistoryDetailUsecase {
  _FixedDetail(this.result);

  final LoadExerciseHistoryDetailResult result;

  @override
  Future<LoadExerciseHistoryDetailResult> execute(
    LoadExerciseHistoryDetailRequest request,
  ) async => result;
}
