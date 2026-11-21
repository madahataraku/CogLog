import 'package:state_stream/state_stream.dart';

import '../state/data_management_screen_state.dart';

/// 予期しない失敗へ遷移する。
///
/// Example:
/// ```dart
/// await emitUnexpectedDataManagementError(state);
/// ```
Future<void> emitUnexpectedDataManagementError(
  MutableStateStream<DataManagementScreenState> state, {
  bool clearPendingImportBytes = true,
}) {
  return state.updateWithLock((current, emitter) async {
    await emitter.emit(
      current.copyWith(
        phase: DataManagementPhase.error,
        errorKind: DataManagementErrorKind.unexpected,
        clearPendingImportBytes: clearPendingImportBytes,
      ),
    );
  });
}
