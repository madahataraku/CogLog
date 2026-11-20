/// エクスポート失敗の種別。
///
/// Example:
/// ```dart
/// ExportAppDataError.unexpected;
/// ```
enum ExportAppDataError {
  /// 保存先へのアクセスが拒否された。
  permissionDenied,

  /// 保存先の容量が足りない。
  storageFull,

  /// 上記以外の失敗。
  unexpected,
}
