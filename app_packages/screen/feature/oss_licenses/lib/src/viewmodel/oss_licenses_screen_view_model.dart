import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_oss_licenses/usecase_load_oss_licenses.dart';

import 'delegate/on_back_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_open_detail_delegate.dart';
import 'delegate/oss_licenses_state_to_entity_delegate.dart';
import 'entity/oss_licenses_screen_entity.dart';
import 'state/oss_licenses_screen_state.dart';

part 'oss_licenses_screen_view_model.action.dart';

/// OSS ライセンス一覧の状態と操作。
///
/// Example:
/// ```dart
/// OssLicensesScreenViewModel.provider;
/// ```
@internal
final class OssLicensesScreenViewModel {
  /// 読込と遷移を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(OssLicensesScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<OssLicensesScreenViewModel>((
    ref,
  ) {
    final result = OssLicensesScreenViewModel._(
      state: MutableStateStream(OssLicensesScreenState.initial),
      loadUsecase: ref.watch(LoadOssLicensesUsecase.provider),
      navigation: ref.watch(screenNavigationProvider),
      stateToEntity: const OssLicensesStateToEntityDelegate(),
    );
    ref.onDispose(() {
      unawaited(result._close());
    });
    return result;
  }, dependencies: [LoadOssLicensesUsecase.provider, screenNavigationProvider]);

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<OssLicensesScreenState> state;

  /// ライセンス読込。
  @visibleForTesting
  final LoadOssLicensesUsecase loadUsecase;

  /// 画面遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State → Entity。
  @visibleForTesting
  final OssLicensesStateToEntityDelegate stateToEntity;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// OssLicensesScreenViewModel.provider;
  /// ```
  const OssLicensesScreenViewModel._({
    required this.state,
    required this.loadUsecase,
    required this.navigation,
    required this.stateToEntity,
  });

  /// 表示に使う文字列。
  StateStream<OssLicensesScreenEntity> get entity =>
      state.map(stateToEntity.execute);

  /// 状態の Stream を閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.provider;
  /// ```
  Future<void> _close() => state.close();
}
