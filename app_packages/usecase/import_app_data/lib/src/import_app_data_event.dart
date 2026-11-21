import 'import_app_data_error.dart';

part 'import_app_data_failed.dart';
part 'import_app_data_progress.dart';
part 'import_app_data_succeeded.dart';

/// インポート適用の進捗と結果。
///
/// Example:
/// ```dart
/// const ImportAppDataProgress(fraction: 0.1);
/// ```
sealed class ImportAppDataEvent {
  /// イベントの基底。
  ///
  /// Example:
  /// ```dart
  /// const ImportAppDataProgress(fraction: 0.2);
  /// ```
  const ImportAppDataEvent();
}
