part of 'export_app_data_event.dart';

/// エクスポートの確定進捗。
///
/// Example:
/// ```dart
/// const ExportAppDataProgress(fraction: 0.5);
/// ```
final class ExportAppDataProgress extends ExportAppDataEvent {
  /// [fraction] は 0.0–1.0。
  ///
  /// Example:
  /// ```dart
  /// const ExportAppDataProgress(fraction: 0.8);
  /// ```
  const ExportAppDataProgress({required this.fraction});

  /// 0.0 以上 1.0 以下の進捗。
  final double fraction;
}
