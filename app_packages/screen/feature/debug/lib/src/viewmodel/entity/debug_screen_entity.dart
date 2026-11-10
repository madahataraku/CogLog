/// デバッグ画面の表示用。
///
/// Example:
/// ```dart
/// const DebugScreenEntity(
///   running: false,
///   readiness: '-',
///   status: '-',
///   reason: '-',
///   message: '-',
///   backend: '-',
///   platformNotes: '-',
///   availabilityError: '-',
///   canGenerate: null,
///   sampleOutput: '-',
///   generateError: '-',
///   probeSkipped: '-',
///   logLines: [],
/// );
/// ```
final class DebugScreenEntity {
  /// 表示用の診断文字列とログ行を持つ。
  ///
  /// Example:
  /// ```dart
  /// const DebugScreenEntity(
  ///   running: true,
  ///   readiness: 'ready',
  ///   status: 'available',
  ///   reason: 'ready',
  ///   message: 'ok',
  ///   backend: 'androidMlKitGenAi',
  ///   platformNotes: 'notes',
  ///   availabilityError: '-',
  ///   canGenerate: true,
  ///   sampleOutput: 'hi',
  ///   generateError: '-',
  ///   probeSkipped: '-',
  ///   logLines: ['line'],
  /// );
  /// ```
  const DebugScreenEntity({
    required this.running,
    required this.readiness,
    required this.status,
    required this.reason,
    required this.message,
    required this.backend,
    required this.platformNotes,
    required this.availabilityError,
    required this.canGenerate,
    required this.sampleOutput,
    required this.generateError,
    required this.probeSkipped,
    required this.logLines,
  });

  /// 診断実行中。
  final bool running;

  /// readiness 表示。
  final String readiness;

  /// status 表示。
  final String status;

  /// reason 表示。
  final String reason;

  /// message 表示。
  final String message;

  /// backend 表示。
  final String backend;

  /// platform notes 表示。
  final String platformNotes;

  /// availability 例外表示。
  final String availabilityError;

  /// 生成可否。未診断は null。
  final bool? canGenerate;

  /// サンプル出力。
  final String sampleOutput;

  /// 生成例外。
  final String generateError;

  /// プローブ省略理由。
  final String probeSkipped;

  /// 新しい行が上になるログ文字列。
  final List<String> logLines;
}
