/// アプリログの重要度。
///
/// Example:
/// ```dart
/// AppLogLevel.info;
/// ```
enum AppLogLevel {
  /// 通常の診断・経過。
  info,

  /// 業務フォールバックなど注意。
  warn,

  /// 例外や失敗。
  error,
}
