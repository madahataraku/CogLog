import 'dart:io';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_meter_capture/screen_feature_meter_capture.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/meter_capture_screen_view_model.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/state/meter_capture_screen_state.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/state/meter_capture_step.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';

/// テスト用のメーター写真バイト。
late final Uint8List _pngBytes;

final class _Nav implements ScreenNavigation {
  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  void pop() {}

  @override
  void goToHomeTab() {}
}

final class _ObtainCancelled implements ObtainMeterPhotoUsecase {
  @override
  Future<ObtainMeterPhotoResult> execute(
    ObtainMeterPhotoRequest request,
  ) async => const ObtainMeterPhotoCancelled();
}

final class _ReadEmpty implements ReadMeterPanelUsecase {
  @override
  Future<ReadMeterPanelResult> execute(ReadMeterPanelRequest request) async =>
      const ReadMeterPanelResult(
        values: MeterReadingValues(),
        averageSpeedFromPanel: false,
      );
}

final class _SaveNever implements SaveMeterCaptureUsecase {
  @override
  Future<SaveMeterCaptureResult> execute(
    SaveMeterCaptureRequest request,
  ) async =>
      const SaveMeterCaptureResult(outcome: SaveMeterCaptureOutcome.success);
}

final class _OpenSettingsNever implements OpenAppSettingsUsecase {
  @override
  Future<void> execute() async {}
}

List<Override> _baseOverrides() => [
  ObtainMeterPhotoUsecase.provider.overrideWith((ref) => _ObtainCancelled()),
  ReadMeterPanelUsecase.provider.overrideWith((ref) => _ReadEmpty()),
  SaveMeterCaptureUsecase.provider.overrideWith((ref) => _SaveNever()),
  OpenAppSettingsUsecase.provider.overrideWith((ref) => _OpenSettingsNever()),
  screenNavigationProvider.overrideWithValue(_Nav()),
];

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

void main() {
  setUpAll(() {
    _pngBytes = File('test/fixtures/meter_panel.png').readAsBytesSync();
  });

  testWidgets('メーター記録 step1 / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    final container = ProviderContainer(overrides: _baseOverrides());
    addTearDown(container.dispose);

    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('ja'),
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: const MeterCaptureScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MeterCaptureScreen),
        matchesGoldenFile('goldens/meter_capture_step1.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('メーター記録 step2 / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    final container = ProviderContainer(overrides: _baseOverrides());
    addTearDown(container.dispose);
    final at = DateTime(2026, 11, 8, 12);

    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('ja'),
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: const MeterCaptureScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final viewModel = container.read(MeterCaptureScreenViewModel.provider);
      await viewModel.state.updateWithLock((_, emitter) async {
        await emitter.emit(
          MeterCaptureScreenState(
            step: MeterCaptureStep.edit,
            photoBytes: _pngBytes,
            creationStartedAt: at,
            capturedAt: at,
            distanceKm: 1.5,
            duration: const Duration(minutes: 30),
            caloriesKcal: 100,
            averageSpeedKmh: 3,
            recordedAt: at,
          ),
        );
      });
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MeterCaptureScreen),
        matchesGoldenFile('goldens/meter_capture_step2.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('メーター記録 permission / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    final container = ProviderContainer(overrides: _baseOverrides());
    addTearDown(container.dispose);

    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('ja'),
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: const MeterCaptureScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final viewModel = container.read(MeterCaptureScreenViewModel.provider);
      await viewModel.state.updateWithLock((_, emitter) async {
        await emitter.emit(
          const MeterCaptureScreenState(
            step: MeterCaptureStep.photo,
            permissionDeniedKind: MeterPhotoPermissionKind.camera,
          ),
        );
      });
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MeterCaptureScreen),
        matchesGoldenFile('goldens/meter_capture_permission.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
