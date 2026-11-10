import 'dart:async';
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
import 'package:screen_feature_meter_capture/src/view/meter_capture_screen_body.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/meter_capture_screen_view_model.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/state/meter_capture_camera_ui.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/state/meter_capture_screen_state.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/state/meter_capture_step.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';
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
  void openAppSettings() {}

  @override
  void openDebug() {}

  @override
  void openOssLicenses() {}

  @override
  void openOssLicenseDetail({required String packageName}) {}

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

final class _ControlCamera implements ControlMeterInAppCameraUsecase {
  final _controller = StreamController<MeterInAppCameraUiStatus>.broadcast();
  MeterInAppCameraUiStatus _current = const MeterInAppCameraUiIdle();

  @override
  Stream<MeterInAppCameraUiStatus> watch() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> start() async {
    _current = const MeterInAppCameraUiReady(aspectRatio: 0.75);
    _controller.add(_current);
  }

  @override
  Future<void> stop() async {
    _current = const MeterInAppCameraUiIdle();
    _controller.add(_current);
  }

  @override
  Widget buildPreview({Key? key}) => ColoredBox(
    key: key,
    color: const Color(0xFF336699),
    child: const SizedBox.expand(),
  );
}

List<Override> _baseOverrides() => [
  ObtainMeterPhotoUsecase.provider.overrideWith((ref) => _ObtainCancelled()),
  ReadMeterPanelUsecase.provider.overrideWith((ref) => _ReadEmpty()),
  SaveMeterCaptureUsecase.provider.overrideWith((ref) => _SaveNever()),
  OpenAppSettingsUsecase.provider.overrideWith((ref) => _OpenSettingsNever()),
  ControlMeterInAppCameraUsecase.provider.overrideWith(
    (ref) => _ControlCamera(),
  ),
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

Widget _wrap(Widget child) => ShellTabIndexScope(
  index: 1,
  child: MaterialApp(
    locale: const Locale('ja'),
    home: FTheme(
      data: FThemeData(touch: true, colors: FColors.neutralLight),
      child: child,
    ),
  ),
);

void main() {
  setUpAll(() {
    _pngBytes = File('test/fixtures/meter_panel.png').readAsBytesSync();
  });

  testWidgets('メーター記録 step1 ready / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    final container = ProviderContainer(overrides: _baseOverrides());
    addTearDown(container.dispose);

    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _wrap(
            const MeterCaptureScreenBody(debugCameraPlaceholder: true),
          ),
        ),
      );
      final viewModel = container.read(MeterCaptureScreenViewModel.provider);
      await viewModel.onEnterCamera();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byType(MeterCaptureScreenBody),
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
          child: _wrap(const MeterCaptureScreenBody()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MeterCaptureScreenBody),
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
          child: _wrap(const MeterCaptureScreenBody()),
        ),
      );
      final viewModel = container.read(MeterCaptureScreenViewModel.provider);
      await viewModel.state.updateWithLock((_, emitter) async {
        await emitter.emit(
          const MeterCaptureScreenState(
            step: MeterCaptureStep.photo,
            cameraUi: MeterCaptureCameraUi.permissionDenied,
            permissionDeniedKind: MeterPhotoPermissionKind.camera,
          ),
        );
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byType(MeterCaptureScreenBody),
        matchesGoldenFile('goldens/meter_capture_permission.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
