import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';
import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';
import 'package:usecase_request_health_body_permission/usecase_request_health_body_permission.dart';

import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_open_app_settings_delegate.dart';
import 'delegate/on_reload_delegate.dart';
import 'delegate/on_request_health_permission_delegate.dart';
import 'delegate/on_select_comparison_delegate.dart';
import 'delegate/on_select_period_delegate.dart';
import 'delegate/trends_state_to_entity_delegate.dart';
import 'entity/trends_screen_entity.dart';
import 'state/trends_comparison.dart';
import 'state/trends_screen_state.dart';

part 'trends_screen_view_model.action.dart';

/// 推移画面の選択・系列・許可操作。
///
/// Example:
/// ```dart
/// TrendsScreenViewModel.provider;
/// ```
@internal
final class TrendsScreenViewModel {
  /// 読込・許可・設定 Usecase を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(TrendsScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<TrendsScreenViewModel>(
    (ref) {
      final result = TrendsScreenViewModel._(
        state: MutableStateStream(TrendsScreenState.initial),
        loadTrendsUsecase: ref.watch(LoadTrendsUsecase.provider),
        requestHealthPermissionUsecase: ref.watch(
          RequestHealthBodyPermissionUsecase.provider,
        ),
        openAppSettingsUsecase: ref.watch(OpenAppSettingsUsecase.provider),
        stateToEntity: const TrendsStateToEntityDelegate(),
      );
      ref.onDispose(() {
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      LoadTrendsUsecase.provider,
      RequestHealthBodyPermissionUsecase.provider,
      OpenAppSettingsUsecase.provider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<TrendsScreenState> state;

  /// 系列の読み込み。
  @visibleForTesting
  final LoadTrendsUsecase loadTrendsUsecase;

  /// 身体指標の許可リクエスト。
  @visibleForTesting
  final RequestHealthBodyPermissionUsecase requestHealthPermissionUsecase;

  /// OS 設定を開く。
  @visibleForTesting
  final OpenAppSettingsUsecase openAppSettingsUsecase;

  /// State から表示用 Entity への変換。
  @visibleForTesting
  final TrendsStateToEntityDelegate stateToEntity;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// TrendsScreenViewModel.provider;
  /// ```
  const TrendsScreenViewModel._({
    required this.state,
    required this.loadTrendsUsecase,
    required this.requestHealthPermissionUsecase,
    required this.openAppSettingsUsecase,
    required this.stateToEntity,
  });

  /// 表示に使う選択・フラグ・系列。
  StateStream<TrendsScreenEntity> get entity =>
      state.map(stateToEntity.execute);

  /// Widget が監視する画面状態。
  StateStream<TrendsScreenState> get screenState => state;

  /// 状態の Stream を閉じる。
  Future<void> _close() => state.close();
}
