import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:infra_local_notification/infra_local_notification.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// `flutter_local_notifications` による運動リマインド。
///
/// Example:
/// ```dart
/// FlutterLocalNotificationsGateway();
/// ```
final class FlutterLocalNotificationsGateway
    implements LocalNotificationGateway {
  /// 既定のプラグインで作る。
  ///
  /// Example:
  /// ```dart
  /// FlutterLocalNotificationsGateway();
  /// ```
  FlutterLocalNotificationsGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// 通知 ID。
  static const reminderId = 42001;

  /// タップ時 payload。
  static const homePayload = 'coglog.home';

  /// Android チャネル ID。
  static const channelId = 'exercise_reminder';

  final FlutterLocalNotificationsPlugin _plugin;

  void Function()? _onOpenHome;

  /// タイムゾーンが初期化できたか。
  bool _timezoneReady = false;

  /// プラグインを初期化し、タップでホームへ戻すコールバックを覚える。
  ///
  /// Example:
  /// ```dart
  /// await gateway.initialize(onNotificationOpenHome: () {});
  /// ```
  @override
  Future<void> initialize({
    required void Function() onNotificationOpenHome,
  }) async {
    _onOpenHome = onNotificationOpenHome;
    _timezoneReady = await _prepareTimezone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onResponse,
    );

    final launch = await _plugin.getNotificationAppLaunchDetails();
    final response = launch?.notificationResponse;
    if (launch?.didNotificationLaunchApp == true &&
        response?.payload == homePayload) {
      _onOpenHome?.call();
    }
  }

  /// OS の通知許可を求める。
  ///
  /// Example:
  /// ```dart
  /// await gateway.requestPermission();
  /// ```
  @override
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// いま通知が許可されているか。
  ///
  /// Example:
  /// ```dart
  /// await gateway.isPermissionGranted();
  /// ```
  @override
  Future<bool> isPermissionGranted() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final enabled = await android?.areNotificationsEnabled();
      return enabled ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final options = await ios?.checkPermissions();
      return options?.isEnabled ?? false;
    }
    return false;
  }

  /// タイムゾーン準備済みなら [when] に一回予約する。
  ///
  /// Example:
  /// ```dart
  /// await gateway.scheduleReminder(
  ///   when: DateTime.now().add(const Duration(hours: 1)),
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
    if (!_timezoneReady) {
      await cancelReminder();
      return;
    }
    final scheduled = tz.TZDateTime.from(when.toLocal(), tz.local);
    await _plugin.zonedSchedule(
      id: reminderId,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          '運動リマインド',
          channelDescription: 'そろそろ運動の時間であることを知らせる',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: homePayload,
    );
  }

  /// 予約を取り消す。
  ///
  /// Example:
  /// ```dart
  /// await gateway.cancelReminder();
  /// ```
  @override
  Future<void> cancelReminder() async {
    await _plugin.cancel(id: reminderId);
  }

  /// タイムゾーン DB とローカル Location を準備する。
  ///
  /// Example:
  /// ```dart
  /// await _prepareTimezone();
  /// ```
  Future<bool> _prepareTimezone() async {
    try {
      tz_data.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
      return true;
    } on Object {
      return false;
    }
  }

  /// payload がホームならコールバックする。
  ///
  /// Example:
  /// ```dart
  /// _onResponse(response);
  /// ```
  void _onResponse(NotificationResponse response) {
    if (response.payload == homePayload) {
      _onOpenHome?.call();
    }
  }
}
