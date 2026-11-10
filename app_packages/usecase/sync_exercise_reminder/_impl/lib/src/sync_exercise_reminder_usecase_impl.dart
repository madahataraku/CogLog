import 'dart:async';
import 'dart:io';

import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:infra_local_notification/infra_local_notification.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';

import 'exercise_reminder_copy.dart';

/// 設定・許可・履歴からリマインドを予約または取り消す。
///
/// Example:
/// ```dart
/// SyncExerciseReminderUsecaseImpl(
///   settings: settings,
///   histories: histories,
///   notifications: notifications,
/// );
/// ```
final class SyncExerciseReminderUsecaseImpl
    implements SyncExerciseReminderUsecase {
  /// 依存を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// SyncExerciseReminderUsecaseImpl(
  ///   settings: settings,
  ///   histories: histories,
  ///   notifications: notifications,
  /// );
  /// ```
  SyncExerciseReminderUsecaseImpl({
    required this.settings,
    required this.histories,
    required this.notifications,
  });

  /// 通知設定。
  final NotificationSettingsRepository settings;

  /// 運動履歴。
  final ExerciseHistoryRepository histories;

  /// ローカル通知。
  final LocalNotificationGateway notifications;

  /// 設定読取から予約／取消までの直列化キュー。
  Future<void> _chain = Future<void>.value();

  /// OFF・無許可・候補なしなら取り消し、あれば一回予約する。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(SyncExerciseReminderRequest(now: DateTime.now()));
  /// ```
  @override
  Future<SyncExerciseReminderResult> execute(
    SyncExerciseReminderRequest request,
  ) {
    final gate = Completer<void>();
    final previous = _chain;
    _chain = gate.future;
    return previous.then((_) => _run(request)).whenComplete(gate.complete);
  }

  /// 設定を読んで予約または取り消す。
  ///
  /// Example:
  /// ```dart
  /// await _run(request);
  /// ```
  Future<SyncExerciseReminderResult> _run(
    SyncExerciseReminderRequest request,
  ) async {
    final current = await settings.read();
    if (!current.enabled) {
      await notifications.cancelReminder();
      return const SyncExerciseReminderResult(scheduled: false);
    }

    final granted = await notifications.isPermissionGranted();
    if (!granted) {
      await notifications.cancelReminder();
      return const SyncExerciseReminderResult(scheduled: false);
    }

    final when = ExerciseReminderSchedule.compute(
      histories: await histories.list(),
      now: request.now,
    );
    if (when == null) {
      await notifications.cancelReminder();
      return const SyncExerciseReminderResult(scheduled: false);
    }

    final languageCode = Platform.localeName.split('_').first;
    final scheduled = await notifications.scheduleReminder(
      when: when,
      title: ExerciseReminderCopy.titleFor(languageCode),
      body: ExerciseReminderCopy.bodyFor(languageCode),
    );
    return SyncExerciseReminderResult(scheduled: scheduled);
  }
}
