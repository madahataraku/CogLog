import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:state_stream/state_stream.dart';

import 'delegate/on_select_group_delegate.dart';
import 'delegate/on_select_period_delegate.dart';
import 'delegate/trends_state_to_entity_delegate.dart';
import 'entity/trends_screen_entity.dart';
import 'state/trends_screen_state.dart';

part 'trends_screen_view_model.action.dart';

/// 推移画面の選択状態。
///
/// Example:
/// ```dart
/// TrendsScreenViewModel.provider;
/// ```
@internal
final class TrendsScreenViewModel {
  /// 依存無しで ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(TrendsScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<TrendsScreenViewModel>((ref) {
    final result = TrendsScreenViewModel._(
      state: MutableStateStream(TrendsScreenState.initial),
      stateToEntity: const TrendsStateToEntityDelegate(),
    );
    ref.onDispose(() {
      unawaited(result._close());
    });
    return result;
  });

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<TrendsScreenState> state;

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
    required this.stateToEntity,
  });

  /// 表示に使う選択状態。
  StateStream<TrendsScreenEntity> get entity =>
      state.map(stateToEntity.execute);

  /// 状態の Stream を閉じる。
  Future<void> _close() => state.close();
}
