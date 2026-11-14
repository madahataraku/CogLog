import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:state_stream/state_stream.dart';

import '../state/debug_screen_state.dart';

/// ログ表示だけをストア内容へ合わせる。
///
/// Example:
/// ```dart
/// OnRefreshLogsDelegate(state: state, log: log).execute();
/// ```
final class OnRefreshLogsDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnRefreshLogsDelegate(state: state, log: log);
  /// ```
  const OnRefreshLogsDelegate({required this.state, required this.log});

  /// 画面状態。
  final MutableStateStream<DebugScreenState> state;

  /// アプリログ。
  final AppLogStore log;

  /// ログ行を差し替える。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        DebugScreenState(
          running: current.running,
          result: current.result,
          gemmaResult: current.gemmaResult,
          logs: log.entries,
          preferGemmaOverOsLlm: current.preferGemmaOverOsLlm,
        ),
      );
    });
  }
}
