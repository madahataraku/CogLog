import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';

/// デバッグ画面の状態。
///
/// Example:
/// ```dart
/// DebugScreenState.initial;
/// ```
final class DebugScreenState {
  /// 診断結果・実行中フラグ・ログ行を持つ。
  ///
  /// Example:
  /// ```dart
  /// const DebugScreenState(
  ///   running: false,
  ///   result: null,
  ///   logs: [],
  /// );
  /// ```
  const DebugScreenState({
    required this.running,
    required this.result,
    required this.logs,
  });

  /// 初期状態。
  static const initial = DebugScreenState(
    running: false,
    result: null,
    logs: [],
  );

  /// 診断実行中なら true。
  final bool running;

  /// 直近の診断結果。
  final DiagnoseOnDeviceLlmResult? result;

  /// 表示するログ行（新しい順ではない、ストア順）。
  final List<AppLogEntry> logs;
}
