/// インポート失敗の種別。
///
/// Example:
/// ```dart
/// ImportAppDataError.corrupt;
/// ```
enum ImportAppDataError {
  /// アーカイブが壊れているか読めない。
  corrupt,

  /// 対応していない formatVersion。
  unsupportedVersion,

  /// 必須フィールドが欠ける・型が不正。
  missingRequired,

  /// ファイルへのアクセスが拒否された。
  permissionDenied,

  /// 保存先の容量が足りない。
  storageFull,

  /// 上記以外の失敗。
  unexpected,
}
