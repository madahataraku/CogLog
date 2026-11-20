part of 'import_app_data_event.dart';

/// インポートが失敗した。
///
/// Example:
/// ```dart
/// const ImportAppDataFailed(ImportAppDataError.corrupt);
/// ```
final class ImportAppDataFailed extends ImportAppDataEvent {
  /// [error] で失敗種別を伝える。
  ///
  /// Example:
  /// ```dart
  /// const ImportAppDataFailed(ImportAppDataError.missingRequired);
  /// ```
  const ImportAppDataFailed(this.error);

  /// 失敗の種別。
  final ImportAppDataError error;
}
