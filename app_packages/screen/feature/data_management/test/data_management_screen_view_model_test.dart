import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
}

final class _FakeExport implements ExportAppDataUsecase {
  _FakeExport({required this.events});

  final List<ExportAppDataEvent> events;
  var calls = 0;

  @override
  Stream<ExportAppDataEvent> execute() async* {
    calls += 1;
    for (final event in events) {
      yield event;
    }
  }
}

final class _FakeImport implements ImportAppDataUsecase {
  _FakeImport({
    this.pickResult = const ImportPickCancelled(),
    this.applyEvents = const [],
  });

  ImportPickResult pickResult;
  List<ImportAppDataEvent> applyEvents;
  var pickCalls = 0;
  var applyCalls = 0;

  @override
  Future<ImportPickResult> pickForImport() async {
    pickCalls += 1;
    return pickResult;
  }

  @override
  Stream<ImportAppDataEvent> applyImport(Uint8List bytes) async* {
    applyCalls += 1;
    for (final event in applyEvents) {
      yield event;
    }
  }
}

ProviderContainer _container({
  required ExportAppDataUsecase export,
  required ImportAppDataUsecase import,
}) {
  return ProviderContainer(
    overrides: [
      screenNavigationProvider.overrideWith((ref) => _Nav()),
      ExportAppDataUsecase.provider.overrideWith((ref) => export),
      ImportAppDataUsecase.provider.overrideWith((ref) => import),
    ],
  );
}

DataManagementScreenViewModel _readAlive(ProviderContainer container) {
  final subscription = container.listen(
    DataManagementScreenViewModel.provider,
    (_, _) {},
  );
  addTearDown(subscription.close);
  return container.read(DataManagementScreenViewModel.provider);
}

void main() {
  test('export 中に再タップしても usecase は 1 回', () async {
    final gate = Completer<void>();
    final export = _FakeExport(
      events: [
        const ExportAppDataProgress(fraction: 0.5),
        const ExportAppDataSucceeded(wasEmpty: false),
      ],
    );
    // 進捗を遅らせて busy 中の再タップを検証するため、最初のイベント前に待つ。
    final slowExport = _SlowExport(inner: export, gate: gate);
    final import = _FakeImport();
    final container = _container(export: slowExport, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    final first = viewModel.onExport();
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.state.state.phase, DataManagementPhase.exporting);
    await viewModel.onExport();
    gate.complete();
    await first;
    expect(slowExport.calls, 1);
    expect(viewModel.state.state.phase, DataManagementPhase.successExport);
  });

  test('pick cancel → idle・エラーなし', () async {
    final export = _FakeExport(events: const []);
    final import = _FakeImport(pickResult: const ImportPickCancelled());
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onImportPick();
    expect(viewModel.state.state.phase, DataManagementPhase.idle);
    expect(viewModel.state.state.errorKind, isNull);
    expect(import.applyCalls, 0);
  });

  test('confirm cancel → idle・apply 未呼び出し', () async {
    final export = _FakeExport(events: const []);
    final import = _FakeImport(
      pickResult: ImportPickSucceeded(Uint8List.fromList([1, 2, 3])),
    );
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onImportPick();
    expect(viewModel.state.state.phase, DataManagementPhase.confirming);
    await viewModel.onCancelImportConfirm();
    expect(viewModel.state.state.phase, DataManagementPhase.idle);
    expect(import.applyCalls, 0);
  });

  test('photoMissingCount>0 → warning 付き success', () async {
    final export = _FakeExport(events: const []);
    final import = _FakeImport(
      pickResult: ImportPickSucceeded(Uint8List.fromList([1])),
      applyEvents: const [
        ImportAppDataProgress(fraction: 0.5),
        ImportAppDataSucceeded(
          photoMissingCount: 2,
          notificationPermissionDenied: false,
        ),
      ],
    );
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onImportPick();
    await viewModel.onConfirmImport();
    expect(
      viewModel.state.state.phase,
      DataManagementPhase.successImportWarning,
    );
    expect(viewModel.state.state.photoMissingCount, 2);
    expect(container.read(appDataImportRefreshProvider), 1);
  });

  test('notificationPermissionDenied → 案内 State', () async {
    final export = _FakeExport(events: const []);
    final import = _FakeImport(
      pickResult: ImportPickSucceeded(Uint8List.fromList([1])),
      applyEvents: const [
        ImportAppDataSucceeded(
          photoMissingCount: 0,
          notificationPermissionDenied: true,
        ),
      ],
    );
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onImportPick();
    await viewModel.onConfirmImport();
    expect(
      viewModel.state.state.phase,
      DataManagementPhase.successImportWarning,
    );
    expect(viewModel.state.state.notificationPermissionDenied, isTrue);
  });

  test('export 空履歴 → successExportEmpty', () async {
    final export = _FakeExport(
      events: const [ExportAppDataSucceeded(wasEmpty: true)],
    );
    final import = _FakeImport();
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onExport();
    expect(viewModel.state.state.phase, DataManagementPhase.successExportEmpty);
  });

  test('export cancel → idle', () async {
    final export = _FakeExport(events: const [ExportAppDataCancelled()]);
    final import = _FakeImport();
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onExport();
    expect(viewModel.state.state.phase, DataManagementPhase.idle);
  });

  test('export fail → error', () async {
    final export = _FakeExport(
      events: const [ExportAppDataFailed(ExportAppDataError.storageFull)],
    );
    final import = _FakeImport();
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onExport();
    expect(viewModel.state.state.phase, DataManagementPhase.error);
    expect(
      viewModel.state.state.errorKind,
      DataManagementErrorKind.storageFull,
    );
  });

  test('import 成功（警告なし）→ successImport・世代加算', () async {
    final export = _FakeExport(events: const []);
    final import = _FakeImport(
      pickResult: ImportPickSucceeded(Uint8List.fromList([1])),
      applyEvents: const [
        ImportAppDataSucceeded(
          photoMissingCount: 0,
          notificationPermissionDenied: false,
        ),
      ],
    );
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onImportPick();
    await viewModel.onConfirmImport();
    expect(viewModel.state.state.phase, DataManagementPhase.successImport);
    expect(container.read(appDataImportRefreshProvider), 1);
  });

  test('import apply fail → error', () async {
    final export = _FakeExport(events: const []);
    final import = _FakeImport(
      pickResult: ImportPickSucceeded(Uint8List.fromList([1])),
      applyEvents: const [ImportAppDataFailed(ImportAppDataError.corrupt)],
    );
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onImportPick();
    await viewModel.onConfirmImport();
    expect(viewModel.state.state.phase, DataManagementPhase.error);
    expect(viewModel.state.state.errorKind, DataManagementErrorKind.corrupt);
    expect(container.read(appDataImportRefreshProvider), 0);
  });

  test('export 例外 → unexpected', () async {
    final export = _ThrowingExport();
    final import = _FakeImport();
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onExport();
    expect(viewModel.state.state.phase, DataManagementPhase.error);
    expect(viewModel.state.state.errorKind, DataManagementErrorKind.unexpected);
  });

  test('pick 例外 → unexpected', () async {
    final export = _FakeExport(events: const []);
    final import = _ThrowingImport(throwOnPick: true);
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onImportPick();
    expect(viewModel.state.state.phase, DataManagementPhase.error);
    expect(viewModel.state.state.errorKind, DataManagementErrorKind.unexpected);
  });

  test('apply 例外 → unexpected', () async {
    final export = _FakeExport(events: const []);
    final import = _ThrowingImport(throwOnApply: true);
    final container = _container(export: export, import: import);
    addTearDown(container.dispose);

    final viewModel = _readAlive(container);
    await viewModel.onImportPick();
    await viewModel.onConfirmImport();
    expect(viewModel.state.state.phase, DataManagementPhase.error);
    expect(viewModel.state.state.errorKind, DataManagementErrorKind.unexpected);
    expect(container.read(appDataImportRefreshProvider), 0);
  });
}

final class _ThrowingExport implements ExportAppDataUsecase {
  @override
  Stream<ExportAppDataEvent> execute() async* {
    throw StateError('export boom');
  }
}

final class _ThrowingImport implements ImportAppDataUsecase {
  _ThrowingImport({this.throwOnPick = false, this.throwOnApply = false});

  final bool throwOnPick;
  final bool throwOnApply;

  @override
  Future<ImportPickResult> pickForImport() async {
    if (throwOnPick) {
      throw StateError('pick boom');
    }
    return ImportPickSucceeded(Uint8List.fromList([1]));
  }

  @override
  Stream<ImportAppDataEvent> applyImport(Uint8List bytes) async* {
    if (throwOnApply) {
      throw StateError('apply boom');
    }
  }
}

final class _SlowExport implements ExportAppDataUsecase {
  _SlowExport({required this.inner, required this.gate});

  final _FakeExport inner;
  final Completer<void> gate;
  int get calls => inner.calls;

  @override
  Stream<ExportAppDataEvent> execute() async* {
    inner.calls += 1;
    await gate.future;
    for (final event in inner.events) {
      yield event;
    }
  }
}
