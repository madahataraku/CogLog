import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:state_stream/state_stream.dart';

import '../state/debug_screen_state.dart';

/// アプリログを消去する。
///
/// Example:
/// ```dart
/// OnClearLogsDelegate(state: state, log: log).execute();
/// ```
final class OnClearLogsDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnClearLogsDelegate(state: state, log: log);
  /// ```
  const OnClearLogsDelegate({required this.state, required this.log});

  /// 画面状態。
  final MutableStateStream<DebugScreenState> state;

  /// アプリログ。
  final AppLogStore log;

  /// ログを消し State を更新する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    log.clear();
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        DebugScreenState(
          running: current.running,
          result: current.result,
          gemmaResult: current.gemmaResult,
          logs: log.entries,
        ),
      );
    });
  }
}
