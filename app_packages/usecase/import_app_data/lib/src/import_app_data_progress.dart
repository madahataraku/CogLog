part of 'import_app_data_event.dart';

/// インポート適用の確定進捗。
///
/// Example:
/// ```dart
/// const ImportAppDataProgress(fraction: 0.4);
/// ```
final class ImportAppDataProgress extends ImportAppDataEvent {
  /// [fraction] は 0.0–1.0。
  ///
  /// Example:
  /// ```dart
  /// const ImportAppDataProgress(fraction: 0.6);
  /// ```
  const ImportAppDataProgress({required this.fraction});

  /// 0.0 以上 1.0 以下の進捗。
  final double fraction;
}
