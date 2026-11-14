import 'dart:async';

import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_diagnose_gemma_meter/usecase_diagnose_gemma_meter.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';

import 'delegate/debug_state_to_entity_delegate.dart';
import 'delegate/on_back_delegate.dart';
import 'delegate/on_clear_logs_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_refresh_logs_delegate.dart';
import 'entity/debug_screen_entity.dart';
import 'state/debug_screen_state.dart';

part 'debug_screen_view_model.action.dart';

/// デバッグ画面の状態と操作。
///
/// Example:
/// ```dart
/// DebugScreenViewModel.provider;
/// ```
@internal
final class DebugScreenViewModel {
  /// 診断・ログ・遷移を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(DebugScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<DebugScreenViewModel>(
    (ref) {
      final log = ref.watch(appLogStoreProvider);
      final result = DebugScreenViewModel._(
        state: MutableStateStream(
          DebugScreenState(
            running: false,
            result: null,
            gemmaResult: null,
            logs: [],
          ),
        ),
        diagnoseUsecase: ref.watch(DiagnoseOnDeviceLlmUsecase.provider),
        diagnoseGemmaUsecase: ref.watch(DiagnoseGemmaMeterUsecase.provider),
        log: log,
        navigation: ref.watch(screenNavigationProvider),
        stateToEntity: const DebugStateToEntityDelegate(),
      );
      void onLogChanged() {
        unawaited(result.onRefreshLogs());
      }

      log.addListener(onLogChanged);
      ref.onDispose(() {
        log.removeListener(onLogChanged);
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      DiagnoseOnDeviceLlmUsecase.provider,
      DiagnoseGemmaMeterUsecase.provider,
      appLogStoreProvider,
      screenNavigationProvider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<DebugScreenState> state;

  /// 端末上 LLM 診断 Usecase。
  @visibleForTesting
  final DiagnoseOnDeviceLlmUsecase diagnoseUsecase;

  /// Gemma メーター診断 Usecase。
  @visibleForTesting
  final DiagnoseGemmaMeterUsecase diagnoseGemmaUsecase;

  /// アプリログ。
  @visibleForTesting
  final AppLogStore log;

  /// 画面遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State → Entity。
  @visibleForTesting
  final DebugStateToEntityDelegate stateToEntity;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// DebugScreenViewModel.provider;
  /// ```
  const DebugScreenViewModel._({
    required this.state,
    required this.diagnoseUsecase,
    required this.diagnoseGemmaUsecase,
    required this.log,
    required this.navigation,
    required this.stateToEntity,
  });

  /// 表示に使う文字列。
  StateStream<DebugScreenEntity> get entity => state.map(stateToEntity.execute);

  /// 状態の Stream を閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.provider;
  /// ```
  Future<void> _close() => state.close();
}
