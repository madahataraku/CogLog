import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infra_local_notification/infra_local_notification.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';

/// 起動時にローカル通知を初期化し、リマインドを同期する。
///
/// Example:
/// ```dart
/// await ExerciseReminderBootstrap(
///   container: container,
///   navigation: navigation,
/// ).run();
/// ```
final class ExerciseReminderBootstrap {
  /// [container] と [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// ExerciseReminderBootstrap(
  ///   container: container,
  ///   navigation: navigation,
  /// );
  /// ```
  const ExerciseReminderBootstrap({
    required this.container,
    required this.navigation,
  });

  /// DI コンテナ。
  final ProviderContainer container;

  /// ホーム遷移に使う窓口。
  final ScreenNavigation navigation;

  /// 初期化と初回同期を行う。
  ///
  /// Example:
  /// ```dart
  /// await bootstrap.run();
  /// ```
  Future<void> run() async {
    final notifications = container.read(localNotificationGatewayProvider);
    final sync = container.read(SyncExerciseReminderUsecase.provider);

    await notifications.initialize(
      onNotificationOpenHome: () {
        navigation.goToHomeTab();
        unawaited(
          sync.execute(SyncExerciseReminderRequest(now: DateTime.now())),
        );
      },
    );

    await sync.execute(SyncExerciseReminderRequest(now: DateTime.now()));
  }
}
