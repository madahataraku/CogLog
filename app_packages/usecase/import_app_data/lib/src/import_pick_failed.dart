part of 'import_pick_result.dart';

/// ファイル選択が失敗した。
///
/// Example:
/// ```dart
/// const ImportPickFailed(ImportAppDataError.permissionDenied);
/// ```
final class ImportPickFailed extends ImportPickResult {
  /// [error] で失敗種別を伝える。
  ///
  /// Example:
  /// ```dart
  /// const ImportPickFailed(ImportAppDataError.unexpected);
  /// ```
  const ImportPickFailed(this.error);

  /// 失敗の種別。
  final ImportAppDataError error;
}
