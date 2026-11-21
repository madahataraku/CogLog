import 'package:state_stream/state_stream.dart';
import 'package:usecase_export_app_data/usecase_export_app_data.dart';

import '../state/data_management_screen_state.dart';

/// エクスポート Usecase を進め、進捗と結果を State に反映する。
///
/// Example:
/// ```dart
/// await OnExportDelegate(
///   state: state,
///   exportUsecase: exportUsecase,
/// ).execute();
/// ```
final class OnExportDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnExportDelegate(state: state, exportUsecase: exportUsecase);
  /// ```
  const OnExportDelegate({required this.state, required this.exportUsecase});

  /// 画面状態。
  final MutableStateStream<DataManagementScreenState> state;

  /// エクスポート。
  final ExportAppDataUsecase exportUsecase;

  /// 二重起動を防ぎつつストリームを消費する。
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
          phase: DataManagementPhase.exporting,
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
      await for (final event in exportUsecase.execute()) {
        switch (event) {
          case ExportAppDataProgress(:final fraction):
            await state.updateWithLock((current, emitter) async {
              if (current.phase != DataManagementPhase.exporting) {
                return;
              }
              await emitter.emit(current.copyWith(progressFraction: fraction));
            });
          case ExportAppDataSucceeded(:final wasEmpty):
            await state.updateWithLock((current, emitter) async {
              await emitter.emit(
                current.copyWith(
                  phase: wasEmpty
                      ? DataManagementPhase.successExportEmpty
                      : DataManagementPhase.successExport,
                  progressFraction: 1,
                  clearPendingImportBytes: true,
                ),
              );
            });
          case ExportAppDataCancelled():
            await state.updateWithLock((current, emitter) async {
              await emitter.emit(
                current.copyWith(
                  phase: DataManagementPhase.idle,
                  progressFraction: 0,
                  clearPendingImportBytes: true,
                ),
              );
            });
          case ExportAppDataFailed(:final error):
            await state.updateWithLock((current, emitter) async {
              await emitter.emit(
                current.copyWith(
                  phase: DataManagementPhase.error,
                  errorKind: _mapExportError(error),
                  clearPendingImportBytes: true,
                ),
              );
            });
        }
      }
    } on Object {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          current.copyWith(
            phase: DataManagementPhase.error,
            errorKind: DataManagementErrorKind.unexpected,
            clearPendingImportBytes: true,
          ),
        );
      });
    }
  }

  /// Usecase のエラーを画面種別へ写す。
  ///
  /// Example:
  /// ```dart
  /// OnExportDelegate._mapExportError(ExportAppDataError.storageFull);
  /// ```
  static DataManagementErrorKind _mapExportError(ExportAppDataError error) {
    return switch (error) {
      ExportAppDataError.permissionDenied =>
        DataManagementErrorKind.permissionDenied,
      ExportAppDataError.storageFull => DataManagementErrorKind.storageFull,
      ExportAppDataError.unexpected => DataManagementErrorKind.unexpected,
    };
  }
}
