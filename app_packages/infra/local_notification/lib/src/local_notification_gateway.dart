import 'package:riverpod/riverpod.dart';

/// 運動リマインドのローカル通知を扱う。
///
/// Usecase を知らない。タップ時のホーム遷移は呼び出し側のコールバックで行う。
///
/// Example:
/// ```dart
/// await gateway.initialize(onNotificationOpenHome: () {});
/// ```
abstract interface class LocalNotificationGateway {
  /// プラグインを初期化し、タップで [onNotificationOpenHome] を呼ぶ。
  ///
  /// Example:
  /// ```dart
  /// await gateway.initialize(onNotificationOpenHome: () {});
  /// ```
  Future<void> initialize({required void Function() onNotificationOpenHome});

  /// OS の通知許可を求める。許可されれば true。
  ///
  /// Example:
  /// ```dart
  /// await gateway.requestPermission();
  /// ```
  Future<bool> requestPermission();

  /// いま通知が許可されているか。
  ///
  /// Example:
  /// ```dart
  /// await gateway.isPermissionGranted();
  /// ```
  Future<bool> isPermissionGranted();

  /// [when] に一回だけリマインドを予約する。
  ///
  /// Example:
  /// ```dart
  /// await gateway.scheduleReminder(
  ///   when: DateTime.now().add(const Duration(hours: 1)),
  ///   title: 'title',
  ///   body: 'body',
  /// );
  /// ```
  Future<void> scheduleReminder({
    required DateTime when,
    required String title,
    required String body,
  });

  /// 予約済みリマインドを取り消す。
  ///
  /// Example:
  /// ```dart
  /// await gateway.cancelReminder();
  /// ```
  Future<void> cancelReminder();
}

/// ローカル通知の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// localNotificationGatewayProvider;
/// ```
final localNotificationGatewayProvider = Provider<LocalNotificationGateway>(
  (ref) => throw UnimplementedError('localNotificationGatewayProvider'),
);
