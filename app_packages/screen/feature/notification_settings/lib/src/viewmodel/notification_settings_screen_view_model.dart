import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_notification_settings/usecase_load_notification_settings.dart';
import 'package:usecase_save_notification_settings/usecase_save_notification_settings.dart';

import 'delegate/notification_settings_state_to_entity_delegate.dart';
import 'delegate/on_back_delegate.dart';
import 'entity/notification_settings_screen_entity.dart';
import 'state/notification_settings_screen_state.dart';

part 'notification_settings_screen_view_model.action.dart';

/// 通知設定画面の状態と操作。
///
/// Example:
/// ```dart
/// NotificationSettingsScreenViewModel.provider;
/// ```
@internal
final class NotificationSettingsScreenViewModel {
  /// Usecase と遷移を注入する。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(NotificationSettingsScreenViewModel.provider);
  /// ```
  static final provider =
      Provider.autoDispose<NotificationSettingsScreenViewModel>(
        (ref) {
          final result = NotificationSettingsScreenViewModel._(
            state: MutableStateStream(NotificationSettingsScreenState.initial),
            loadUsecase: ref.watch(LoadNotificationSettingsUsecase.provider),
            saveUsecase: ref.watch(SaveNotificationSettingsUsecase.provider),
            navigation: ref.watch(screenNavigationProvider),
            stateToEntity: const NotificationSettingsStateToEntityDelegate(),
          );
          ref.onDispose(() {
            unawaited(result._close());
          });
          return result;
        },
        dependencies: [
          LoadNotificationSettingsUsecase.provider,
          SaveNotificationSettingsUsecase.provider,
          screenNavigationProvider,
        ],
      );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<NotificationSettingsScreenState> state;

  /// 読み込み。
  @visibleForTesting
  final LoadNotificationSettingsUsecase loadUsecase;

  /// 保存。
  @visibleForTesting
  final SaveNotificationSettingsUsecase saveUsecase;

  /// 遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State → Entity。
  @visibleForTesting
  final NotificationSettingsStateToEntityDelegate stateToEntity;

  NotificationSettingsScreenViewModel._({
    required this.state,
    required this.loadUsecase,
    required this.saveUsecase,
    required this.navigation,
    required this.stateToEntity,
  });

  Future<void> _close() => state.close();
}
