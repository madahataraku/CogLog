import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:foundation_debug_overrides/foundation_debug_overrides.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_debug/src/view/debug_screen_body.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';
import 'package:usecase_diagnose_on_device_llm_impl/usecase_diagnose_on_device_llm_impl.dart';

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

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            screenNavigationProvider.overrideWith((ref) => _Nav()),
            appLogStoreProvider.overrideWith((ref) => log),
            forceSpatialOcrStoreProvider.overrideWith(
              (ref) => ForceSpatialOcrStore(),
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
}
