import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_app_runtime_info/usecase_load_app_runtime_info.dart';

import 'delegate/app_settings_state_to_entity_delegate.dart';
import 'delegate/on_back_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_open_debug_delegate.dart';
import 'delegate/on_open_notification_settings_delegate.dart';
import 'delegate/on_open_oss_licenses_delegate.dart';
import 'entity/app_settings_screen_entity.dart';
import 'state/app_settings_screen_state.dart';

part 'app_settings_screen_view_model.action.dart';

/// アプリ設定画面の状態と操作。
///
/// Example:
/// ```dart
/// AppSettingsScreenViewModel.provider;
/// ```
@internal
final class AppSettingsScreenViewModel {
  /// 読込と遷移を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(AppSettingsScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<AppSettingsScreenViewModel>(
    (ref) {
      final result = AppSettingsScreenViewModel._(
        state: MutableStateStream(AppSettingsScreenState.initial),
        loadUsecase: ref.watch(LoadAppRuntimeInfoUsecase.provider),
        navigation: ref.watch(screenNavigationProvider),
        stateToEntity: const AppSettingsStateToEntityDelegate(),
      );
      ref.onDispose(() {
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      LoadAppRuntimeInfoUsecase.provider,
      screenNavigationProvider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<AppSettingsScreenState> state;

  /// 実行情報の読込。
  @visibleForTesting
  final LoadAppRuntimeInfoUsecase loadUsecase;

  /// 画面遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State → Entity。
  @visibleForTesting
  final AppSettingsStateToEntityDelegate stateToEntity;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// AppSettingsScreenViewModel.provider;
  /// ```
  const AppSettingsScreenViewModel._({
    required this.state,
    required this.loadUsecase,
    required this.navigation,
    required this.stateToEntity,
  });

  /// 表示に使う文字列。
  StateStream<AppSettingsScreenEntity> get entity =>
      state.map(stateToEntity.execute);

  /// 状態の Stream を閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.provider;
  /// ```
  Future<void> _close() => state.close();
}
