import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_data_management/screen_feature_data_management.dart';
import 'package:screen_feature_data_management/src/viewmodel/data_management_screen_view_model.dart';
import 'package:screen_feature_data_management/src/viewmodel/state/data_management_screen_state.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_export_app_data/usecase_export_app_data.dart';
import 'package:usecase_import_app_data/usecase_import_app_data.dart';

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

final class _IdleExport implements ExportAppDataUsecase {
  @override
  Stream<ExportAppDataEvent> execute() async* {}
}

final class _IdleImport implements ImportAppDataUsecase {
  @override
  Future<ImportPickResult> pickForImport() async => const ImportPickCancelled();

  @override
  Stream<ImportAppDataEvent> applyImport(Uint8List bytes) async* {}
}

Future<void> _pump({
  required WidgetTester tester,
  required String golden,
  required DataManagementScreenState seed,
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

  final container = ProviderContainer(
    overrides: [
      screenNavigationProvider.overrideWith((ref) => _Nav()),
      ExportAppDataUsecase.provider.overrideWith((ref) => _IdleExport()),
      ImportAppDataUsecase.provider.overrideWith((ref) => _IdleImport()),
    ],
  );
  addTearDown(container.dispose);

  final viewModel = container.read(DataManagementScreenViewModel.provider);
  await viewModel.state.updateWithLock((_, emitter) async {
    await emitter.emit(seed);
  });

  try {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('ja'),
          home: FTheme(
            data: FThemeData(touch: true, colors: FColors.neutralLight),
            child: const DataManagementScreen(),
          ),
        ),
      ),
    );
    // 進捗インジケータのアニメで settle しない場合がある。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await expectLater(
      find.byType(DataManagementScreen),
      matchesGoldenFile(golden),
    );
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

void main() {
  testWidgets('データ管理 idle', (tester) async {
    await _pump(
      tester: tester,
      seed: DataManagementScreenState.initial,
      golden: 'goldens/data_management_idle.png',
    );
  });

  testWidgets('データ管理 progress', (tester) async {
    await _pump(
      tester: tester,
      seed: const DataManagementScreenState(
        phase: DataManagementPhase.exporting,
        progressFraction: 0.4,
        errorKind: null,
        photoMissingCount: 0,
        notificationPermissionDenied: false,
        pendingImportBytes: null,
      ),
      golden: 'goldens/data_management_progress.png',
    );
  });

  testWidgets('データ管理 error', (tester) async {
    await _pump(
      tester: tester,
      seed: const DataManagementScreenState(
        phase: DataManagementPhase.error,
        progressFraction: 0,
        errorKind: DataManagementErrorKind.corrupt,
        photoMissingCount: 0,
        notificationPermissionDenied: false,
        pendingImportBytes: null,
      ),
      golden: 'goldens/data_management_error.png',
    );
  });
}
