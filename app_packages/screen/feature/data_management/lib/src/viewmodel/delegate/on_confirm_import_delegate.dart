import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_import_app_data/usecase_import_app_data.dart';

import '../state/data_management_screen_state.dart';
import 'emit_unexpected_error.dart';
import 'map_import_app_data_error.dart';

/// 確認後に適用し、成功時は世代カウンタを進める。
///
/// Example:
/// ```dart
/// await OnConfirmImportDelegate(
///   state: state,
///   importUsecase: importUsecase,
///   ref: ref,
/// ).execute();
/// ```
final class OnConfirmImportDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnConfirmImportDelegate(
  ///   state: state,
  ///   importUsecase: importUsecase,
  ///   ref: ref,
  /// );
  /// ```
  const OnConfirmImportDelegate({
    required this.state,
    required this.importUsecase,
    required this.ref,
  });

  /// 画面状態。
  final MutableStateStream<DataManagementScreenState> state;

  /// インポート。
  final ImportAppDataUsecase importUsecase;

  /// 世代カウンタ更新用。
  final Ref ref;

  /// 保留バイトを適用する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    final bytes = await state.updateWithLock((current, emitter) async {
      if (current.phase != DataManagementPhase.confirming ||
          current.pendingImportBytes == null) {
        return null;
      }
      final pending = current.pendingImportBytes!;
      await emitter.emit(
        current.copyWith(
          phase: DataManagementPhase.importing,
          progressFraction: 0,
          clearPendingImportBytes: true,
        ),
      );
      return pending;
    });
    if (bytes == null) {
      return;
    }

    try {
      await for (final event in importUsecase.applyImport(bytes)) {
        switch (event) {
          case ImportAppDataProgress(:final fraction):
            await state.updateWithLock((current, emitter) async {
              if (current.phase != DataManagementPhase.importing) {
                return;
              }
              await emitter.emit(current.copyWith(progressFraction: fraction));
            });
          case ImportAppDataSucceeded(
            :final photoMissingCount,
            :final notificationPermissionDenied,
          ):
            final hasWarning =
                photoMissingCount > 0 || notificationPermissionDenied;
            await state.updateWithLock((current, emitter) async {
              await emitter.emit(
                current.copyWith(
                  phase: hasWarning
                      ? DataManagementPhase.successImportWarning
                      : DataManagementPhase.successImport,
                  progressFraction: 1,
                  photoMissingCount: photoMissingCount,
                  notificationPermissionDenied: notificationPermissionDenied,
                ),
              );
            });
            ref.read(appDataImportRefreshProvider.notifier).state++;
          case ImportAppDataFailed(:final error):
            await state.updateWithLock((current, emitter) async {
              await emitter.emit(
                current.copyWith(
                  phase: DataManagementPhase.error,
                  errorKind: mapImportAppDataErrorKind(error),
                ),
              );
            });
        }
      }
    } on Object {
      await emitUnexpectedDataManagementError(
        state,
        clearPendingImportBytes: false,
      );
    }
  }
}
