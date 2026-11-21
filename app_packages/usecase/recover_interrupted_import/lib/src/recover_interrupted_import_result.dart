/// 中断インポート復旧の結果。
///
/// Example:
/// ```dart
/// RecoverInterruptedImportResult.noop;
/// ```
enum RecoverInterruptedImportResult {
  /// marker が無く何もしなかった。
  noop,

  /// 完全な snapshot から復元した。
  restored,

  /// marker はあるが snapshot が不完全なので破棄した。
  discardedIncomplete,

  /// 復元に失敗したがバックアップは消し、起動は継続する。
  restoreFailed,
}
