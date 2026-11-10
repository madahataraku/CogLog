import 'app_log_level.dart';

/// 1 行のアプリログ。
///
/// Example:
/// ```dart
/// AppLogEntry(
///   at: DateTime.utc(2026, 1, 1),
///   level: AppLogLevel.info,
///   tag: 'llm',
///   message: 'ready',
/// );
/// ```
final class AppLogEntry {
  /// 時刻・重要度・タグ・本文を持つ 1 行を作る。
  ///
  /// Example:
  /// ```dart
  /// AppLogEntry(
  ///   at: DateTime.utc(2026, 1, 1),
  ///   level: AppLogLevel.info,
  ///   tag: 'llm',
  ///   message: 'ready',
  /// );
  /// ```
  const AppLogEntry({
    required this.at,
    required this.level,
    required this.tag,
    required this.message,
  });

  /// 記録時刻。
  final DateTime at;

  /// 重要度。
  final AppLogLevel level;

  /// 分類用の短いタグ。
  final String tag;

  /// 本文。
  final String message;
}
