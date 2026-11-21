import 'package:state_stream/state_stream.dart';

import '../state/data_management_screen_state.dart';

/// 全置換確認を取り消して idle に戻す。
///
/// Example:
/// ```dart
/// await OnCancelImportConfirmDelegate(state: state).execute();
/// ```
final class OnCancelImportConfirmDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnCancelImportConfirmDelegate(state: state);
  /// ```
  const OnCancelImportConfirmDelegate({required this.state});

  /// 画面状態。
  final MutableStateStream<DataManagementScreenState> state;

  /// 確認待ちでなければ何もしない。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((current, emitter) async {
      if (current.phase != DataManagementPhase.confirming) {
        return;
      }
      await emitter.emit(
        current.copyWith(
          phase: DataManagementPhase.idle,
          clearPendingImportBytes: true,
        ),
      );
    });
  }
}
