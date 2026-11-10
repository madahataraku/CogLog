import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_oss_licenses/usecase_load_oss_licenses.dart';

import 'delegate/on_back_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/oss_license_detail_state_to_entity_delegate.dart';
import 'entity/oss_license_detail_screen_entity.dart';
import 'state/oss_license_detail_screen_state.dart';

part 'oss_license_detail_screen_view_model.action.dart';

/// OSS ライセンス詳細の状態と操作。
///
/// Example:
/// ```dart
/// OssLicenseDetailScreenViewModel.provider;
/// ```
@internal
final class OssLicenseDetailScreenViewModel {
  /// 読込と遷移を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(OssLicenseDetailScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<OssLicenseDetailScreenViewModel>(
    (ref) {
      final result = OssLicenseDetailScreenViewModel._(
        state: MutableStateStream(
          OssLicenseDetailScreenState.initial(packageName: ''),
        ),
        loadUsecase: ref.watch(LoadOssLicensesUsecase.provider),
        navigation: ref.watch(screenNavigationProvider),
        stateToEntity: const OssLicenseDetailStateToEntityDelegate(),
      );
      ref.onDispose(() {
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [LoadOssLicensesUsecase.provider, screenNavigationProvider],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<OssLicenseDetailScreenState> state;

  /// ライセンス読込。
  @visibleForTesting
  final LoadOssLicensesUsecase loadUsecase;

  /// 画面遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State → Entity。
  @visibleForTesting
  final OssLicenseDetailStateToEntityDelegate stateToEntity;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// OssLicenseDetailScreenViewModel.provider;
  /// ```
  const OssLicenseDetailScreenViewModel._({
    required this.state,
    required this.loadUsecase,
    required this.navigation,
    required this.stateToEntity,
  });

  /// 表示に使う文字列。
  StateStream<OssLicenseDetailScreenEntity> get entity =>
      state.map(stateToEntity.execute);

  /// 状態の Stream を閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.provider;
  /// ```
  Future<void> _close() => state.close();
}
