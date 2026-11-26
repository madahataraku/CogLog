import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infra_meter_vl_testing/infra_meter_vl_testing.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_debug/src/view/debug_screen_body.dart';
import 'package:screen_feature_debug/src/viewmodel/debug_screen_view_model.dart';
import 'package:screen_feature_debug/src/viewmodel/state/debug_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_diagnose_meter_vl/usecase_diagnose_meter_vl.dart';
import 'package:usecase_diagnose_meter_vl_impl/usecase_diagnose_meter_vl_impl.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';
import 'package:usecase_diagnose_on_device_llm_impl/usecase_diagnose_on_device_llm_impl.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

import 'fake_redownload_meter_vl_model_usecase.dart';

Future<void> _pumpDebugBody(
  WidgetTester tester, {
  required AppLogStore log,
  MeterVlRedownloadSession? redownloadSession,
  FakeRedownloadMeterVlModelUsecase? redownloadUsecase,
}) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.platformDispatcher.localesTestValue = const [Locale('ja')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

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
  final usecase = redownloadUsecase ?? FakeRedownloadMeterVlModelUsecase();

  try {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          screenNavigationProvider.overrideWith((ref) => _Nav()),
          appLogStoreProvider.overrideWith((ref) => log),
          MeterVlRedownloadSession.provider.overrideWithValue(session),
          RedownloadMeterVlModelUsecase.provider.overrideWithValue(usecase),
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
            child: const DebugScreenBody(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

Future<void> _scrollToRedownload(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('LFM VL を再ダウンロード'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

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

void main() {
  group('syncLogText', () {
    testWidgets('末尾追記では selection を維持する', (tester) async {
      final logController = TextEditingController(text: 'ab');
      logController.selection = const TextSelection(
        baseOffset: 1,
        extentOffset: 2,
      );
      final scrollController = ScrollController();
      addTearDown(logController.dispose);
      addTearDown(scrollController.dispose);

      syncLogText(logController, scrollController, 'abc');

      expect(logController.text, 'abc');
      expect(logController.selection.baseOffset, 1);
      expect(logController.selection.extentOffset, 2);
    });

    testWidgets('同じ文字列のときは更新しない', (tester) async {
      final logController = TextEditingController(text: 'same');
      final scrollController = ScrollController();
      addTearDown(logController.dispose);
      addTearDown(scrollController.dispose);
      var listenerCount = 0;
      logController.addListener(() => listenerCount++);

      syncLogText(logController, scrollController, 'same');

      expect(listenerCount, 0);
    });
  });

  group('mapLogSelection', () {
    test('先頭破棄では残存部分へ選択を移す', () {
      final mapped = mapLogSelection(
        previousText: 'A\nB\nC',
        nextText: 'B\nC\nD',
        previousSelection: const TextSelection(baseOffset: 2, extentOffset: 3),
      );
      expect(mapped.baseOffset, 0);
      expect(mapped.extentOffset, 1);
      expect('B\nC\nD'.substring(mapped.start, mapped.end), 'B');
    });

    test('対応できない置換では選択を解除する', () {
      final mapped = mapLogSelection(
        previousText: 'abc',
        nextText: 'xyz',
        previousSelection: const TextSelection(baseOffset: 1, extentOffset: 2),
      );
      expect(mapped.isCollapsed, isTrue);
      expect(mapped.baseOffset, 0);
    });

    test('空テキストへの置換では選択を解除する', () {
      final mapped = mapLogSelection(
        previousText: 'abc',
        nextText: '',
        previousSelection: const TextSelection(baseOffset: 1, extentOffset: 2),
      );
      expect(mapped.isCollapsed, isTrue);
      expect(mapped.baseOffset, 0);
    });
  });

  testWidgets('ログ空でも空状態文言は出さず readOnly の FTextField を示す', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
    addTearDown(LocalizeStringDelegate.resetDelegateForTest);

    final log = AppLogStore(clock: () => DateTime.utc(2026, 11, 10, 6, 0, 0));
    final redownloadSession = MeterVlRedownloadSession(
      meterVl: FakeMeterVlVision(),
    );
    addTearDown(() async {
      await redownloadSession.close();
    });

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            screenNavigationProvider.overrideWith((ref) => _Nav()),
            appLogStoreProvider.overrideWith((ref) => log),
            MeterVlRedownloadSession.provider.overrideWithValue(
              redownloadSession,
            ),
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
              child: const DebugScreenBody(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ログはまだありません'), findsNothing);
      await tester.scrollUntilVisible(
        find.byType(FTextField),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.byType(FTextField), findsOneWidget);
      final field = tester.widget<FTextField>(find.byType(FTextField));
      expect(field.readOnly, isTrue);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  group('LFM VL 再ダウンロード', () {
    testWidgets('説明文言を出す', (tester) async {
      final log = AppLogStore(clock: () => DateTime.utc(2026, 11, 10, 6, 0, 0));
      await _pumpDebugBody(tester, log: log);
      await _scrollToRedownload(tester);
      expect(find.text('保持中のモデルを削除してから再取得します'), findsOneWidget);
    });

    testWidgets('確認キャンセルでは session を開始しない', (tester) async {
      final log = AppLogStore(clock: () => DateTime.utc(2026, 11, 10, 6, 0, 0));
      final usecase = FakeRedownloadMeterVlModelUsecase();
      await _pumpDebugBody(tester, log: log, redownloadUsecase: usecase);
      await _scrollToRedownload(tester);
      await tester.tap(find.text('LFM VL を再ダウンロード'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();
      expect(usecase.executeCallCount, 0);
    });

    testWidgets('無効時は onPress が null', (tester) async {
      final log = AppLogStore(clock: () => DateTime.utc(2026, 11, 10, 6, 0, 0));
      final session = MeterVlRedownloadSession(
        meterVl: FakeMeterVlVision(),
        state: MutableStateStream(
          const MeterVlRedownloadSessionState(
            phase: MeterVlRedownloadPhase.running,
            progress: 0.1,
            failureKind: null,
            diagnoseRefreshPending: false,
          ),
        ),
      );
      await _pumpDebugBody(tester, log: log, redownloadSession: session);
      await _scrollToRedownload(tester);
      final button = tester.widget<FButton>(
        find.widgetWithText(FButton, 'LFM VL を再ダウンロード'),
      );
      expect(button.onPress, isNull);
    });

    testWidgets('conflict 文言は出しつつボタンは有効', (tester) async {
      final log = AppLogStore(clock: () => DateTime.utc(2026, 11, 10, 6, 0, 0));
      await _pumpDebugBody(tester, log: log);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(DebugScreenBody)),
      );
      final vm = container.read(DebugScreenViewModel.provider);
      await vm.state.updateWithLock((current, emitter) async {
        await emitter.emit(
          current.copyWith(
            redownloadDisabledReason: DebugRedownloadDisabledReason.conflict,
          ),
        );
      });
      await tester.pumpAndSettle();
      await _scrollToRedownload(tester);
      expect(find.text('メーター読み取りまたはモデル準備の完了を待ってから再度お試しください。'), findsOneWidget);
      final button = tester.widget<FButton>(
        find.widgetWithText(FButton, 'LFM VL を再ダウンロード'),
      );
      expect(button.onPress, isNotNull);
    });

    testWidgets('ステータスは redownloadStatusText のみ表示', (tester) async {
      final log = AppLogStore(clock: () => DateTime.utc(2026, 11, 10, 6, 0, 0));
      final session = MeterVlRedownloadSession(
        meterVl: FakeMeterVlVision(),
        state: MutableStateStream(
          const MeterVlRedownloadSessionState(
            phase: MeterVlRedownloadPhase.running,
            progress: 0.5,
            failureKind: null,
            diagnoseRefreshPending: false,
          ),
        ),
      );
      await _pumpDebugBody(tester, log: log, redownloadSession: session);
      await _scrollToRedownload(tester);
      expect(find.text('LFM VL を再ダウンロード中…'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('diagnoseRefreshPending で再診断後 acknowledge する', (tester) async {
      final log = AppLogStore(clock: () => DateTime.utc(2026, 11, 10, 6, 0, 0));
      final session = MeterVlRedownloadSession(
        meterVl: FakeMeterVlVision(),
        state: MutableStateStream(
          const MeterVlRedownloadSessionState(
            phase: MeterVlRedownloadPhase.success,
            progress: 1,
            failureKind: null,
            diagnoseRefreshPending: true,
          ),
        ),
      );
      await _pumpDebugBody(tester, log: log, redownloadSession: session);
      await tester.pumpAndSettle();
      expect(session.state.state.diagnoseRefreshPending, isFalse);
    });
  });
}
