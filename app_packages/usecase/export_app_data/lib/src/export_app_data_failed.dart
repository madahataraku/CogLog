part of 'export_app_data_event.dart';

/// エクスポートが失敗した。
///
/// Example:
/// ```dart
/// const ExportAppDataFailed(ExportAppDataError.unexpected);
/// ```
final class ExportAppDataFailed extends ExportAppDataEvent {
  /// [error] で失敗種別を伝える。
  ///
  /// Example:
  /// ```dart
  /// const ExportAppDataFailed(ExportAppDataError.storageFull);
  /// ```
  const ExportAppDataFailed(this.error);

  /// 失敗の種別。
  final ExportAppDataError error;
}
