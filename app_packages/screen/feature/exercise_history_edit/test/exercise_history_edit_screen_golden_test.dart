import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history_edit/screen_feature_exercise_history_edit.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_update_exercise_history/usecase_update_exercise_history.dart';

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

final class _FixedDetail implements LoadExerciseHistoryDetailUsecase {
  _FixedDetail(this.result);

  final LoadExerciseHistoryDetailResult result;

  @override
  Future<LoadExerciseHistoryDetailResult> execute(
    LoadExerciseHistoryDetailRequest request,
  ) async => result;
}

final class _NoopObtain implements ObtainMeterPhotoUsecase {
  @override
  Future<ObtainMeterPhotoResult> execute(
    ObtainMeterPhotoRequest request,
  ) async => const ObtainMeterPhotoCancelled();
}

final class _NoopRead implements ReadMeterPanelUsecase {
  @override
  Future<ReadMeterPanelResult> execute(ReadMeterPanelRequest request) async =>
      const ReadMeterPanelResult(
        values: MeterReadingValues(),
        averageSpeedFromPanel: false,
      );
}

final class _NoopUpdate implements UpdateExerciseHistoryUsecase {
  @override
  Future<UpdateExerciseHistoryResult> execute(
    UpdateExerciseHistoryRequest request,
  ) async => const UpdateExerciseHistoryResult(
    outcome: UpdateExerciseHistoryOutcome.success,
  );
}

final class _NoopOpenSettings implements OpenAppSettingsUsecase {
  @override
  Future<void> execute() async {}
}

ExerciseHistory _history({required String id}) {
  final at = DateTime(2026, 11, 5, 12, 30);
  return ExerciseHistory(
    id: id,
    savedAt: at,
    creationStartedAt: at,
    capturedAt: at,
    recordedAt: at,
    recordedAtManuallySet: false,
    distanceKm: 1.25,
    duration: const Duration(minutes: 30),
    caloriesKcal: 12.34,
    averageSpeedKmh: 2.5,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
    healthWorkoutId: null,
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

List<Override> _editOverrides({
  required LoadExerciseHistoryDetailUsecase detail,
}) => [
  LoadExerciseHistoryDetailUsecase.provider.overrideWith((ref) => detail),
  ObtainMeterPhotoUsecase.provider.overrideWith((ref) => _NoopObtain()),
  ReadMeterPanelUsecase.provider.overrideWith((ref) => _NoopRead()),
  UpdateExerciseHistoryUsecase.provider.overrideWith((ref) => _NoopUpdate()),
  OpenAppSettingsUsecase.provider.overrideWith((ref) => _NoopOpenSettings()),
  screenNavigationProvider.overrideWithValue(_Nav()),
];

void main() {
  testWidgets('編集の初期 / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    const id = '11111111-1111-4111-8111-111111111111';
    final history = _history(id: id);

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _editOverrides(
            detail: _FixedDetail(
              LoadExerciseHistoryDetailSuccess(
                history: history,
                photoAbsolutePath: null,
              ),
            ),
          ),
          child: _wrap(const ExerciseHistoryEditScreen(id: id)),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ExerciseHistoryEditScreen),
        matchesGoldenFile('goldens/exercise_history_edit_initial.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
