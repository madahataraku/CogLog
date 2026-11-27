import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import 'delegate/achievement_state_to_entity_delegate.dart';
import 'delegate/on_acknowledge_tutorial_delegate.dart';
import 'delegate/on_back_delegate.dart';
import 'delegate/on_dismiss_tutorial_delegate.dart';
import 'delegate/on_evaluate_tutorial_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_retry_delegate.dart';
import 'entity/achievement_screen_entity.dart';
import 'state/achievement_screen_state.dart';

part 'achievement_screen_view_model.action.dart';

/// アチーブメント画面の状態と操作。
///
/// Example:
/// ```dart
/// AchievementScreenViewModel.provider;
/// ```
@internal
final class AchievementScreenViewModel {
  /// 読込と遷移を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(AchievementScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<AchievementScreenViewModel>(
    (ref) {
      ref.watch(appDataImportRefreshProvider);
      final result = AchievementScreenViewModel._(
        state: MutableStateStream(AchievementScreenState.initial),
        loadUsecase: ref.watch(LoadAchievementsUsecase.provider),
        markViewed: ref.watch(MarkAchievementsViewedUsecase.provider),
        evaluateTutorial: ref.watch(EvaluateTutorialContextUsecase.provider),
        markTutorialSeen: ref.watch(MarkTutorialContextSeenUsecase.provider),
        tutorialSession: ref.watch(tutorialRuntimeSessionProvider),
        navigation: ref.watch(screenNavigationProvider),
        stateToEntity: const AchievementStateToEntityDelegate(),
        now: () => DateTime.now(),
      );
      ref.onDispose(() {
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      appDataImportRefreshProvider,
      LoadAchievementsUsecase.provider,
      MarkAchievementsViewedUsecase.provider,
      EvaluateTutorialContextUsecase.provider,
      MarkTutorialContextSeenUsecase.provider,
      tutorialRuntimeSessionProvider,
      screenNavigationProvider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<AchievementScreenState> state;

  /// 一覧の読込。
  @visibleForTesting
  final LoadAchievementsUsecase loadUsecase;

  /// Ready 後の最終閲覧更新。
  @visibleForTesting
  final MarkAchievementsViewedUsecase markViewed;

  /// 文脈表示要否。
  @visibleForTesting
  final EvaluateTutorialContextUsecase evaluateTutorial;

  /// 文脈表示済み。
  @visibleForTesting
  final MarkTutorialContextSeenUsecase markTutorialSeen;

  /// プロセス内のチュートリアル実行状態。
  @visibleForTesting
  final TutorialRuntimeSession tutorialSession;

  /// 画面遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State → Entity。
  @visibleForTesting
  final AchievementStateToEntityDelegate stateToEntity;

  /// 進捗評価の基準時刻。
  @visibleForTesting
  final DateTime Function() now;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// AchievementScreenViewModel.provider;
  /// ```
  const AchievementScreenViewModel._({
    required this.state,
    required this.loadUsecase,
    required this.markViewed,
    required this.evaluateTutorial,
    required this.markTutorialSeen,
    required this.tutorialSession,
    required this.navigation,
    required this.stateToEntity,
    required this.now,
  });

  /// 表示に使う文字列。
  StateStream<AchievementScreenEntity> get entity =>
      state.map(stateToEntity.execute);

  /// 状態の Stream を閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.provider;
  /// ```
  Future<void> _close() => state.close();
}
