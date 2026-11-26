import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_diagnose_meter_vl/usecase_diagnose_meter_vl.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';

import '../state/debug_screen_state.dart';

/// 初回診断を走らせ、ログを同期する。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   diagnoseUsecase: diagnoseUsecase,
///   diagnoseMeterVlUsecase: diagnoseMeterVlUsecase,
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
  ///   diagnoseMeterVlUsecase: diagnoseMeterVlUsecase,
  ///   log: log,
  /// );
  /// ```
  const OnInitializeDelegate({
    required this.state,
    required this.diagnoseUsecase,
    required this.diagnoseMeterVlUsecase,
    required this.log,
  });

  /// 画面状態。
  final MutableStateStream<DebugScreenState> state;

  /// 端末上 LLM 診断 Usecase。
  final DiagnoseOnDeviceLlmUsecase diagnoseUsecase;

  /// メーター VL診断 Usecase。
  final DiagnoseMeterVlUsecase diagnoseMeterVlUsecase;

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
        current.copyWith(
          running: true,
          clearResult: true,
          clearMeterVlResult: true,
          logs: log.entries,
        ),
      );
    });
    final result = await diagnoseUsecase.execute();
    final meterVlResult = await diagnoseMeterVlUsecase.execute();
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          running: false,
          result: result,
          meterVlResult: meterVlResult,
          logs: log.entries,
        ),
      );
    });
  }
}
