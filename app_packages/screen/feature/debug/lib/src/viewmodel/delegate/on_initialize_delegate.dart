import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_diagnose_gemma_meter/usecase_diagnose_gemma_meter.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';

import '../state/debug_screen_state.dart';

/// 初回診断を走らせ、ログを同期する。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   diagnoseUsecase: diagnoseUsecase,
///   diagnoseGemmaUsecase: diagnoseGemmaUsecase,
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
  ///   diagnoseGemmaUsecase: diagnoseGemmaUsecase,
  ///   log: log,
  /// );
  /// ```
  const OnInitializeDelegate({
    required this.state,
    required this.diagnoseUsecase,
    required this.diagnoseGemmaUsecase,
    required this.log,
  });

  /// 画面状態。
  final MutableStateStream<DebugScreenState> state;

  /// 端末上 LLM 診断 Usecase。
  final DiagnoseOnDeviceLlmUsecase diagnoseUsecase;

  /// Gemma メーター診断 Usecase。
  final DiagnoseGemmaMeterUsecase diagnoseGemmaUsecase;

  /// アプリログ。
  final AppLogStore log;

  /// 両経路の診断を順に実行する。
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
          gemmaResult: null,
          logs: log.entries,
        ),
      );
    });
    final result = await diagnoseUsecase.execute();
    final gemmaResult = await diagnoseGemmaUsecase.execute();
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        DebugScreenState(
          running: false,
          result: result,
          gemmaResult: gemmaResult,
          logs: log.entries,
        ),
      );
    });
  }
}
