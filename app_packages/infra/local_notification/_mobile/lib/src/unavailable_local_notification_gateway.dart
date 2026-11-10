import 'package:infra_local_notification/infra_local_notification.dart';

/// 非モバイル向けの何もしない実装。
///
/// Example:
/// ```dart
/// const UnavailableLocalNotificationGateway();
/// ```
final class UnavailableLocalNotificationGateway
    implements LocalNotificationGateway {
  /// 何もしない Gateway を作る。
  ///
  /// Example:
  /// ```dart
  /// const UnavailableLocalNotificationGateway();
  /// ```
  const UnavailableLocalNotificationGateway();

  /// 何もしない。
  ///
  /// Example:
  /// ```dart
  /// await gateway.initialize(onNotificationOpenHome: () {});
  /// ```
  @override
  Future<void> initialize({
    required void Function() onNotificationOpenHome,
  }) async {}

  /// 常に false。
  ///
  /// Example:
  /// ```dart
  /// await gateway.requestPermission();
  /// ```
  @override
  Future<bool> requestPermission() async => false;

  /// 常に false。
  ///
  /// Example:
  /// ```dart
  /// await gateway.isPermissionGranted();
  /// ```
  @override
  Future<bool> isPermissionGranted() async => false;

  /// 常に false。
  ///
  /// Example:
  /// ```dart
  /// await gateway.scheduleReminder(
  ///   when: DateTime.now(),
  ///   title: 't',
  ///   body: 'b',
  /// );
  /// ```
  @override
  Future<bool> scheduleReminder({
    required DateTime when,
    required String title,
    required String body,
  }) async => false;

  /// 何もしない。
  ///
  /// Example:
  /// ```dart
  /// await gateway.cancelReminder();
  /// ```
  @override
  Future<void> cancelReminder() async {}
}
