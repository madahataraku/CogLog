import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';

import '../state/debug_screen_state.dart';

/// 初回診断を走らせ、ログを同期する。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   diagnoseUsecase: diagnoseUsecase,
///   log: log,
/// );
/// ```
final class OnInitializeDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnInitializeDelegate(
  ///   state: state,
  ///   diagnoseUsecase: diagnoseUsecase,
  ///   log: log,
  /// );
  /// ```
  const OnInitializeDelegate({
    required this.state,
    required this.diagnoseUsecase,
    required this.log,
  });

  /// 画面状態。
  final MutableStateStream<DebugScreenState> state;

  /// 診断 Usecase。
  final DiagnoseOnDeviceLlmUsecase diagnoseUsecase;

  /// アプリログ。
  final AppLogStore log;

  /// 診断を実行する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        DebugScreenState(
          running: true,
          result: null,
          logs: log.entries,
          forceSpatialOcr: current.forceSpatialOcr,
        ),
      );
    });
    final result = await diagnoseUsecase.execute();
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        DebugScreenState(
          running: false,
          result: result,
          logs: log.entries,
          forceSpatialOcr: current.forceSpatialOcr,
        ),
      );
    });
  }
}
