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
import 'package:screen_feature_exercise_history_detail/screen_feature_exercise_history_detail.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day/usecase_load_exercise_histories_for_same_recorded_day.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';
import 'package:usecase_load_exercise_history_detail_impl/usecase_load_exercise_history_detail_impl.dart';

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

final class _FixedDetail implements LoadExerciseHistoryDetailUsecase {
  _FixedDetail(this.result);

  final LoadExerciseHistoryDetailResult result;

  @override
  Future<LoadExerciseHistoryDetailResult> execute(
    LoadExerciseHistoryDetailRequest request,
  ) async => result;
}

final class _FixedSameDay
    implements LoadExerciseHistoriesForSameRecordedDayUsecase {
  const _FixedSameDay(this.result);

  final LoadExerciseHistoriesForSameRecordedDayResult result;

  @override
  Future<LoadExerciseHistoriesForSameRecordedDayResult> execute(
    LoadExerciseHistoriesForSameRecordedDayRequest request,
  ) async => result;
}

ExerciseHistory _history({required String id}) {
  final at = DateTime(2026, 11, 5, 12, 30);
  return ExerciseHistory(
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
}

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

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('ja'),
  home: FTheme(
    data: FThemeData(touch: true, colors: FColors.neutralLight),
    child: child,
  ),
);

List<Override> _detailOverrides({
  required LoadExerciseHistoryDetailUsecase detail,
  required LoadExerciseHistoriesForSameRecordedDayUsecase sameDay,
}) => [
  LoadExerciseHistoryDetailUsecase.provider.overrideWith((ref) => detail),
  LoadExerciseHistoriesForSameRecordedDayUsecase.provider.overrideWith(
    (ref) => sameDay,
  ),
  screenNavigationProvider.overrideWithValue(_Nav()),
];

void main() {
  testWidgets('詳細の不在 / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    final histories = MemoryExerciseHistoryRepository();

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _detailOverrides(
            detail: LoadExerciseHistoryDetailUsecaseImpl(histories: histories),
            sameDay: const _FixedSameDay(
              LoadExerciseHistoriesForSameRecordedDayNotFound(),
            ),
          ),
          child: _wrap(const ExerciseHistoryDetailScreen(id: 'missing-id')),
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

  testWidgets('詳細の単件 / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    const id = '11111111-1111-4111-8111-111111111111';
    final history = _history(id: id);

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _detailOverrides(
            detail: _FixedDetail(
              LoadExerciseHistoryDetailSuccess(
                history: history,
                photoAbsolutePath: null,
              ),
            ),
            sameDay: const _FixedSameDay(
              LoadExerciseHistoriesForSameRecordedDaySuccess(
                ids: [id],
                initialIndex: 0,
              ),
            ),
          ),
          child: _wrap(const ExerciseHistoryDetailScreen(id: id)),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ExerciseHistoryDetailScreen),
        matchesGoldenFile('goldens/exercise_history_detail_single.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('詳細の同一日複数 / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    const id = '11111111-1111-4111-8111-111111111111';
    const otherA = '22222222-2222-4222-8222-222222222222';
    const otherB = '33333333-3333-4333-8333-333333333333';
    final history = _history(id: id);

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _detailOverrides(
            detail: _FixedDetail(
              LoadExerciseHistoryDetailSuccess(
                history: history,
                photoAbsolutePath: null,
              ),
            ),
            sameDay: const _FixedSameDay(
              LoadExerciseHistoriesForSameRecordedDaySuccess(
                ids: [otherA, id, otherB],
                initialIndex: 1,
              ),
            ),
          ),
          child: _wrap(const ExerciseHistoryDetailScreen(id: id)),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ExerciseHistoryDetailScreen),
        matchesGoldenFile('goldens/exercise_history_detail_multi.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
