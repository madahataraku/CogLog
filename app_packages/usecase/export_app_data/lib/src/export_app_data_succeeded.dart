part of 'export_app_data_event.dart';

/// 保存ダイアログまで成功した。
///
/// Example:
/// ```dart
/// const ExportAppDataSucceeded(wasEmpty: false);
/// ```
final class ExportAppDataSucceeded extends ExportAppDataEvent {
  /// [wasEmpty] は運動履歴が 0 件だったか。
  ///
  /// Example:
  /// ```dart
  /// const ExportAppDataSucceeded(wasEmpty: true);
  /// ```
  const ExportAppDataSucceeded({required this.wasEmpty});

  /// エクスポート時点で運動履歴が空だったか。
  final bool wasEmpty;
}
