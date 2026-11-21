import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_data_management/src/viewmodel/delegate/data_management_state_to_entity_delegate.dart';
import 'package:screen_feature_data_management/src/viewmodel/state/data_management_screen_state.dart';

void main() {
  const delegate = DataManagementStateToEntityDelegate();

  test('idle は操作可・進捗なし', () {
    final entity = delegate.convert(DataManagementScreenState.initial);
    expect(entity.interactive, isTrue);
    expect(entity.showProgress, isFalse);
    expect(entity.awaitingImportConfirm, isFalse);
  });

  test('exporting は操作不可・進捗あり', () {
    final entity = delegate.convert(
      const DataManagementScreenState(
        phase: DataManagementPhase.exporting,
        progressFraction: 0.4,
        errorKind: null,
        photoMissingCount: 0,
        notificationPermissionDenied: false,
        pendingImportBytes: null,
      ),
    );
    expect(entity.interactive, isFalse);
    expect(entity.showProgress, isTrue);
    expect(entity.progressFraction, 0.4);
  });

  test('confirming は確認待ち・操作不可', () {
    final entity = delegate.convert(
      const DataManagementScreenState(
        phase: DataManagementPhase.confirming,
        progressFraction: 0,
        errorKind: null,
        photoMissingCount: 0,
        notificationPermissionDenied: false,
        pendingImportBytes: null,
      ),
    );
    expect(entity.interactive, isFalse);
    expect(entity.awaitingImportConfirm, isTrue);
    expect(entity.showProgress, isFalse);
  });

  test('error は種別を渡す', () {
    final entity = delegate.convert(
      const DataManagementScreenState(
        phase: DataManagementPhase.error,
        progressFraction: 0,
        errorKind: DataManagementErrorKind.corrupt,
        photoMissingCount: 0,
        notificationPermissionDenied: false,
        pendingImportBytes: null,
      ),
    );
    expect(entity.phase, DataManagementPhase.error);
    expect(entity.errorKind, DataManagementErrorKind.corrupt);
    expect(entity.interactive, isTrue);
  });
}
