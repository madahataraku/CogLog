import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:usecase_diagnose_gemma_meter/usecase_diagnose_gemma_meter.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';

/// デバッグ画面の状態。
///
/// Example:
/// ```dart
/// DebugScreenState.initial;
/// ```
final class DebugScreenState {
  /// 診断結果・実行中フラグ・ログ行・Gemma 優先を持つ。
  ///
  /// Example:
  /// ```dart
  /// const DebugScreenState(
  ///   running: false,
  ///   result: null,
  ///   gemmaResult: null,
  ///   logs: [],
  ///   preferGemmaOverOsLlm: false,
  /// );
  /// ```
  const DebugScreenState({
    required this.running,
    required this.result,
    required this.gemmaResult,
    required this.logs,
    required this.preferGemmaOverOsLlm,
  });

  /// 初期状態。
  static const initial = DebugScreenState(
    running: false,
    result: null,
    gemmaResult: null,
    logs: [],
    preferGemmaOverOsLlm: false,
  );

  /// 診断実行中なら true。
  final bool running;

  /// 直近の端末上 LLM 診断結果。
  final DiagnoseOnDeviceLlmResult? result;

  /// 直近の Gemma メーター診断結果。
  final DiagnoseGemmaMeterResult? gemmaResult;

  /// 表示するログ行（新しい順ではない、ストア順）。
  final List<AppLogEntry> logs;

  /// 同一プロセス内で Gemma をメーター読み取りで優先するとき true。
  final bool preferGemmaOverOsLlm;
}
