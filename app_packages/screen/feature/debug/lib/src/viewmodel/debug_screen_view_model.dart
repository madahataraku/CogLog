import 'dart:async';

import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:foundation_debug_overrides/foundation_debug_overrides.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';

import 'delegate/debug_state_to_entity_delegate.dart';
import 'delegate/on_back_delegate.dart';
import 'delegate/on_clear_logs_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_refresh_logs_delegate.dart';
import 'delegate/on_toggle_force_spatial_ocr_delegate.dart';
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
      final forceSpatialOcr = ref.watch(forceSpatialOcrStoreProvider);
      final result = DebugScreenViewModel._(
        state: MutableStateStream(
          DebugScreenState(
            running: false,
            result: null,
            logs: [],
            forceSpatialOcr: forceSpatialOcr.enabled,
          ),
        ),
        diagnoseUsecase: ref.watch(DiagnoseOnDeviceLlmUsecase.provider),
        log: log,
        forceSpatialOcr: forceSpatialOcr,
        navigation: ref.watch(screenNavigationProvider),
        stateToEntity: const DebugStateToEntityDelegate(),
      );
      void onLogChanged() {
        unawaited(result.onRefreshLogs());
      }

      void onForceSpatialOcrChanged() {
        unawaited(
          result.state.updateWithLock((current, emitter) async {
            await emitter.emit(
              DebugScreenState(
                running: current.running,
                result: current.result,
                logs: current.logs,
                forceSpatialOcr: forceSpatialOcr.enabled,
              ),
            );
          }),
        );
      }

      log.addListener(onLogChanged);
      forceSpatialOcr.addListener(onForceSpatialOcrChanged);
      ref.onDispose(() {
        log.removeListener(onLogChanged);
        forceSpatialOcr.removeListener(onForceSpatialOcrChanged);
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      DiagnoseOnDeviceLlmUsecase.provider,
      appLogStoreProvider,
      forceSpatialOcrStoreProvider,
      screenNavigationProvider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<DebugScreenState> state;

  /// 診断 Usecase。
  @visibleForTesting
  final DiagnoseOnDeviceLlmUsecase diagnoseUsecase;

  /// アプリログ。
  @visibleForTesting
  final AppLogStore log;

  /// 空間 OCR 強制ストア。
  @visibleForTesting
  final ForceSpatialOcrStore forceSpatialOcr;

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
    required this.log,
    required this.forceSpatialOcr,
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
