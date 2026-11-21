import 'package:state_stream/state_stream.dart';
import 'package:usecase_import_app_data/usecase_import_app_data.dart';

import '../state/data_management_screen_state.dart';
import 'emit_unexpected_error.dart';
import 'map_import_app_data_error.dart';

/// ファイル選択し、確認待ちまたはキャンセル／エラーへ遷移する。
///
/// Example:
/// ```dart
/// await OnImportPickDelegate(
///   state: state,
///   importUsecase: importUsecase,
/// ).execute();
/// ```
final class OnImportPickDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnImportPickDelegate(state: state, importUsecase: importUsecase);
  /// ```
  const OnImportPickDelegate({
    required this.state,
    required this.importUsecase,
  });

  /// 画面状態。
  final MutableStateStream<DataManagementScreenState> state;

  /// インポート。
  final ImportAppDataUsecase importUsecase;

  /// 選択結果を State に反映する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    final started = await state.updateWithLock((current, emitter) async {
      if (current.isBusy) {
        return false;
      }
      await emitter.emit(
        current.copyWith(
          phase: DataManagementPhase.picking,
          progressFraction: 0,
          clearErrorKind: true,
          photoMissingCount: 0,
          notificationPermissionDenied: false,
          clearPendingImportBytes: true,
        ),
      );
      return true;
    });
    if (!started) {
      return;
    }

    try {
      final result = await importUsecase.pickForImport();
      switch (result) {
        case ImportPickCancelled():
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(
              current.copyWith(
                phase: DataManagementPhase.idle,
                clearPendingImportBytes: true,
              ),
            );
          });
        case ImportPickFailed(:final error):
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(
              current.copyWith(
                phase: DataManagementPhase.error,
                errorKind: mapImportAppDataErrorKind(error),
                clearPendingImportBytes: true,
              ),
            );
          });
        case ImportPickSucceeded(:final bytes):
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(
              current.copyWith(
                phase: DataManagementPhase.confirming,
                pendingImportBytes: bytes,
              ),
            );
          });
      }
    } on Object {
      await emitUnexpectedDataManagementError(state);
    }
  }
}
