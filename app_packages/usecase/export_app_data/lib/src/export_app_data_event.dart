import 'export_app_data_error.dart';

part 'export_app_data_cancelled.dart';
part 'export_app_data_failed.dart';
part 'export_app_data_progress.dart';
part 'export_app_data_succeeded.dart';

/// エクスポート処理の進捗と結果。
///
/// Example:
/// ```dart
/// const ExportAppDataProgress(fraction: 0.05);
/// ```
sealed class ExportAppDataEvent {
  /// イベントの基底。
  ///
  /// Example:
  /// ```dart
  /// const ExportAppDataProgress(fraction: 0.1);
  /// ```
  const ExportAppDataEvent();
}
