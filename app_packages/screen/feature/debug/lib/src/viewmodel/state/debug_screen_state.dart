import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:usecase_diagnose_meter_vl/usecase_diagnose_meter_vl.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';

/// デバッグ画面の状態。
///
/// Example:
/// ```dart
/// DebugScreenState.initial;
/// ```
final class DebugScreenState {
  /// 診断結果・実行中フラグ・ログ行・LFM VL 優先を持つ。
  ///
  /// Example:
  /// ```dart
  /// const DebugScreenState(
  ///   running: false,
  ///   result: null,
  ///   meterVlResult: null,
  ///   logs: [],
  ///   preferLfmVlOverOsLlm: false,
  /// );
  /// ```
  const DebugScreenState({
    required this.running,
    required this.result,
    required this.meterVlResult,
    required this.logs,
    required this.preferLfmVlOverOsLlm,
  });

  /// 初期状態。
  static const initial = DebugScreenState(
    running: false,
    result: null,
    meterVlResult: null,
    logs: [],
    preferLfmVlOverOsLlm: false,
  );

  /// 診断実行中なら true。
  final bool running;

  /// 直近の端末上 LLM 診断結果。
  final DiagnoseOnDeviceLlmResult? result;

  /// 直近の メーター VL診断結果。
  final DiagnoseMeterVlResult? meterVlResult;

  /// 表示するログ行（新しい順ではない、ストア順）。
  final List<AppLogEntry> logs;

  /// 同一プロセス内で メーター VL をメーター読み取りで優先するとき true。
  final bool preferLfmVlOverOsLlm;
}
