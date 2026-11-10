import 'dart:async';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_load_top_screen/usecase_load_top_screen.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_save_top_screen_metric/usecase_save_top_screen_metric.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import 'delegate/on_acknowledge_model_download_guidance_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_prepare_model_download_guidance_delegate.dart';
import 'delegate/on_select_metric_delegate.dart';
import 'delegate/top_screen_state_to_entity_delegate.dart';
import 'entity/top_screen_entity.dart';
import 'state/top_screen_state.dart';

part 'top_screen_view_model.action.dart';

/// トップ画面の状態と表示。
///
/// 可変な値は [state] だけが持つ。
///
/// Example:
/// ```dart
/// TopScreenViewModel.provider;
/// ```
@internal
final class TopScreenViewModel {
  /// 読み込みと保存・アドバイス生成・誘導の Usecase を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(TopScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<TopScreenViewModel>(
    (ref) {
      final result = TopScreenViewModel._(
        state: MutableStateStream(TopScreenState.initial),
        loadTopScreenUsecase: ref.watch(LoadTopScreenUsecase.provider),
        saveTopScreenMetricUsecase: ref.watch(
          SaveTopScreenMetricUsecase.provider,
        ),
        generateTopAdviceUsecase: ref.watch(GenerateTopAdviceUsecase.provider),
        evaluateOnDeviceLlmGuidanceUsecase: ref.watch(
          EvaluateOnDeviceLlmGuidanceUsecase.provider,
        ),
        prepareOnDeviceLlmModelUsecase: ref.watch(
          PrepareOnDeviceLlmModelUsecase.provider,
        ),
        guidanceSession: ref.watch(ModelDownloadGuidanceProviders.session),
        stateToEntity: const TopScreenStateToEntityDelegate(),
      );
      ref.onDispose(() {
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      LoadTopScreenUsecase.provider,
      SaveTopScreenMetricUsecase.provider,
      GenerateTopAdviceUsecase.provider,
      EvaluateOnDeviceLlmGuidanceUsecase.provider,
      PrepareOnDeviceLlmModelUsecase.provider,
      ModelDownloadGuidanceProviders.session,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<TopScreenState> state;

  /// 期間合計の読み込み。
  @visibleForTesting
  final LoadTopScreenUsecase loadTopScreenUsecase;

  /// 指標の保存。
  @visibleForTesting
  final SaveTopScreenMetricUsecase saveTopScreenMetricUsecase;

  /// ワンポイントアドバイスの生成。
  @visibleForTesting
  final GenerateTopAdviceUsecase generateTopAdviceUsecase;

  /// モデル未ダウンロード誘導の要否。
  @visibleForTesting
  final EvaluateOnDeviceLlmGuidanceUsecase evaluateOnDeviceLlmGuidanceUsecase;

  /// モデル準備。
  @visibleForTesting
  final PrepareOnDeviceLlmModelUsecase prepareOnDeviceLlmModelUsecase;

  /// プロセス内の誘導再表示抑制。
  @visibleForTesting
  final OnDeviceLlmGuidanceSession guidanceSession;

  /// State から表示文字列への変換。
  @visibleForTesting
  final TopScreenStateToEntityDelegate stateToEntity;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// TopScreenViewModel.provider;
  /// ```
  const TopScreenViewModel._({
    required this.state,
    required this.loadTopScreenUsecase,
    required this.saveTopScreenMetricUsecase,
    required this.generateTopAdviceUsecase,
    required this.evaluateOnDeviceLlmGuidanceUsecase,
    required this.prepareOnDeviceLlmModelUsecase,
    required this.guidanceSession,
    required this.stateToEntity,
  });

  /// 表示に使う文字列。
  StateStream<TopScreenEntity> get entity => state.map(stateToEntity.execute);

  /// 状態の Stream を閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.provider;
  /// ```
  Future<void> _close() => state.close();
}
