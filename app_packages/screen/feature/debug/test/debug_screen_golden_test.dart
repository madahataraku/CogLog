import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_meter_vl_testing/infra_meter_vl_testing.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_debug/screen_feature_debug.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_diagnose_meter_vl/usecase_diagnose_meter_vl.dart';
import 'package:usecase_diagnose_meter_vl_impl/usecase_diagnose_meter_vl_impl.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';
import 'package:usecase_diagnose_on_device_llm_impl/usecase_diagnose_on_device_llm_impl.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

import 'fake_redownload_meter_vl_model_usecase.dart';

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
  void openDataManagement() {}

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

  @override
  void goToGoalSettingsTab() {}

  @override
  void goToMeterCaptureTab() {}
}

Future<void> _pumpDebugGolden(
  WidgetTester tester, {
  required AppLogStore log,
  MeterVlRedownloadSession? redownloadSession,
}) async {
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

  final session =
      redownloadSession ??
      MeterVlRedownloadSession(meterVl: FakeMeterVlVision());
  addTearDown(() async {
    await session.close();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        screenNavigationProvider.overrideWith((ref) => _Nav()),
        appLogStoreProvider.overrideWith((ref) => log),
        MeterVlRedownloadSession.provider.overrideWithValue(session),
        RedownloadMeterVlModelUsecase.provider.overrideWithValue(
          FakeRedownloadMeterVlModelUsecase(),
        ),
        DiagnoseOnDeviceLlmUsecase.provider.overrideWith(
          (ref) => DiagnoseOnDeviceLlmUsecaseImpl(
            llm: FakeOnDeviceLlm(
              response: 'probe-ok',
              availabilitySnapshot: const OnDeviceLlmAvailabilitySnapshot(
                readiness: OnDeviceLlmReadiness.ready,
                status: 'available',
                reason: 'ready',
                message: 'Gemini Nano is ready.',
                backend: 'androidMlKitGenAi',
                platformNotes: 'AICore installed: true',
              ),
            ),
            log: log,
          ),
        ),
        DiagnoseMeterVlUsecase.provider.overrideWith(
          (ref) => DiagnoseMeterVlUsecaseImpl(
            meterVl: FakeMeterVlVision(response: 'ok'),
            log: log,
          ),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('ja'),
        home: FTheme(
          data: FThemeData(touch: true, colors: FColors.neutralLight),
          child: const DebugScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('デバッグ診断結果 / ja / Android / light', (tester) async {
    final log = AppLogStore(clock: () => DateTime.utc(2026, 11, 10, 6, 0, 0));
    log.append(tag: 'test', message: 'sample log line');

    try {
      await _pumpDebugGolden(tester, log: log);
      await expectLater(
        find.byType(DebugScreen),
        matchesGoldenFile('goldens/debug_screen.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('再ダウンロード実行中 / ja / Android / light', (tester) async {
    final log = AppLogStore(clock: () => DateTime.utc(2026, 11, 10, 6, 0, 0));
    log.append(tag: 'test', message: 'sample log line');
    final session = MeterVlRedownloadSession(
      meterVl: FakeMeterVlVision(),
      state: MutableStateStream(
        const MeterVlRedownloadSessionState(
          phase: MeterVlRedownloadPhase.running,
          progress: 0.4,
          failureKind: null,
          diagnoseRefreshPending: false,
        ),
      ),
    );

    try {
      await _pumpDebugGolden(tester, log: log, redownloadSession: session);
      await expectLater(
        find.byType(DebugScreen),
        matchesGoldenFile('goldens/debug_screen_redownload_running.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('再ダウンロード失敗 / ja / Android / light', (tester) async {
    final log = AppLogStore(clock: () => DateTime.utc(2026, 11, 10, 6, 0, 0));
    log.append(tag: 'test', message: 'sample log line');
    final session = MeterVlRedownloadSession(
      meterVl: FakeMeterVlVision(),
      state: MutableStateStream(
        const MeterVlRedownloadSessionState(
          phase: MeterVlRedownloadPhase.failure,
          progress: 0.2,
          failureKind: MeterVlPrepareFailureKind.insufficientStorage,
          diagnoseRefreshPending: true,
        ),
      ),
    );

    try {
      await _pumpDebugGolden(tester, log: log, redownloadSession: session);
      await expectLater(
        find.byType(DebugScreen),
        matchesGoldenFile('goldens/debug_screen_redownload_failed.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}