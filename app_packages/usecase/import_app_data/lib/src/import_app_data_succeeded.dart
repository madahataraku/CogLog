part of 'import_app_data_event.dart';

/// コミットまで成功した。
///
/// Example:
/// ```dart
/// const ImportAppDataSucceeded(
///   photoMissingCount: 0,
///   notificationPermissionDenied: false,
/// );
/// ```
final class ImportAppDataSucceeded extends ImportAppDataEvent {
  /// 写真欠落と通知許可の案内用フラグを持つ。
  ///
  /// Example:
  /// ```dart
  /// const ImportAppDataSucceeded(
  ///   photoMissingCount: 1,
  ///   notificationPermissionDenied: true,
  /// );
  /// ```
  const ImportAppDataSucceeded({
    required this.photoMissingCount,
    required this.notificationPermissionDenied,
  });

  /// アーカイブに写真が無かった履歴件数。
  final int photoMissingCount;

  /// 通知 ON だが OS 許可が無いとき true。
  final bool notificationPermissionDenied;
}
