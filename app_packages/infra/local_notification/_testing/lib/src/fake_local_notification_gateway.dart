import 'package:infra_local_notification/infra_local_notification.dart';

/// 呼び出しを記録するローカル通知 Fake。
///
/// Example:
/// ```dart
/// FakeLocalNotificationGateway();
/// ```
final class FakeLocalNotificationGateway implements LocalNotificationGateway {
  /// 許可状態の初期値を指定して作る。
  ///
  /// Example:
  /// ```dart
  /// FakeLocalNotificationGateway(permissionGranted: true);
  /// ```
  FakeLocalNotificationGateway({this.permissionGranted = false});

  /// いまの許可状態。
  bool permissionGranted;

  /// [initialize] が呼ばれた回数。
  int initializeCount = 0;

  /// 最後に渡されたホーム遷移コールバック。
  void Function()? onNotificationOpenHome;

  /// 予約内容。
  ({DateTime when, String title, String body})? scheduled;

  /// [cancelReminder] 回数。
  int cancelCount = 0;

  /// 初期化を記録する。
  ///
  /// Example:
  /// ```dart
  /// await gateway.initialize(onNotificationOpenHome: () {});
  /// ```
  @override
  Future<void> initialize({
    required void Function() onNotificationOpenHome,
  }) async {
    initializeCount += 1;
    this.onNotificationOpenHome = onNotificationOpenHome;
  }

  /// [permissionGranted] を true にして返す。
  ///
  /// Example:
  /// ```dart
  /// await gateway.requestPermission();
  /// ```
  @override
  Future<bool> requestPermission() async {
    permissionGranted = true;
    return permissionGranted;
  }

  /// いまの許可状態を返す。
  ///
  /// Example:
  /// ```dart
  /// await gateway.isPermissionGranted();
  /// ```
  @override
  Future<bool> isPermissionGranted() async => permissionGranted;

  /// 予約を記録する。
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
  Future<void> scheduleReminder({
    required DateTime when,
    required String title,
    required String body,
  }) async {
    scheduled = (when: when, title: title, body: body);
  }

  /// 予約を消し、キャンセル回数を増やす。
  ///
  /// Example:
  /// ```dart
  /// await gateway.cancelReminder();
  /// ```
  @override
  Future<void> cancelReminder() async {
    cancelCount += 1;
    scheduled = null;
  }
}
