import 'dart:async';

import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_diagnose_meter_vl/usecase_diagnose_meter_vl.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

import 'delegate/debug_state_to_entity_delegate.dart';
import 'delegate/on_acknowledge_redownload_diagnose_refresh_delegate.dart';
import 'delegate/on_back_delegate.dart';
import 'delegate/on_clear_logs_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_redownload_meter_vl_delegate.dart';
import 'delegate/on_redownload_session_sync_delegate.dart';
import 'delegate/on_refresh_logs_delegate.dart';
import 'delegate/on_toggle_prefer_lfm_vl_delegate.dart';
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
      final sessionPreference = ref.watch(
        meterReadingEngineSessionPreferenceProvider,
      );
      final redownloadSession = ref.watch(MeterVlRedownloadSession.provider);
      final redownloadUsecase = ref.watch(
        RedownloadMeterVlModelUsecase.provider,
      );
      final result = DebugScreenViewModel._(
        state: MutableStateStream(
          DebugScreenState.initial.copyWith(
            preferLfmVlOverOsLlm: sessionPreference.preferLfmVlOverOsLlm,
          ),
        ),
        diagnoseUsecase: ref.watch(DiagnoseOnDeviceLlmUsecase.provider),
        diagnoseMeterVlUsecase: ref.watch(DiagnoseMeterVlUsecase.provider),
        log: log,
        sessionPreference: sessionPreference,
        navigation: ref.watch(screenNavigationProvider),
        stateToEntity: const DebugStateToEntityDelegate(),
        redownloadSession: redownloadSession,
        redownloadUsecase: redownloadUsecase,
      );
      void onLogChanged() {
        unawaited(result.onRefreshLogs());
      }

      log.addListener(onLogChanged);
      unawaited(result.onRedownloadSessionSync(redownloadSession.state.state));
      final redownloadSub = redownloadSession.state.stream.listen((
        sessionState,
      ) {
        unawaited(result.onRedownloadSessionSync(sessionState));
      });
      ref.onDispose(() {
        log.removeListener(onLogChanged);
        unawaited(redownloadSub.cancel());
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      DiagnoseOnDeviceLlmUsecase.provider,
      DiagnoseMeterVlUsecase.provider,
      appLogStoreProvider,
      meterReadingEngineSessionPreferenceProvider,
      screenNavigationProvider,
      MeterVlRedownloadSession.provider,
      RedownloadMeterVlModelUsecase.provider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<DebugScreenState> state;

  /// 端末上 LLM 診断 Usecase。
  @visibleForTesting
  final DiagnoseOnDeviceLlmUsecase diagnoseUsecase;

  /// メーター VL診断 Usecase。
  @visibleForTesting
  final DiagnoseMeterVlUsecase diagnoseMeterVlUsecase;

  /// アプリログ。
  @visibleForTesting
  final AppLogStore log;

  /// セッション内の LFM VL 優先設定。
  @visibleForTesting
  final MeterReadingEngineSessionPreference sessionPreference;

  /// 画面遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State → Entity。
  @visibleForTesting
  final DebugStateToEntityDelegate stateToEntity;

  /// LFM VL 再ダウンロードのプロセス内セッション。
  @visibleForTesting
  final MeterVlRedownloadSession redownloadSession;

  /// 削除→再準備を実行する Usecase。
  @visibleForTesting
  final RedownloadMeterVlModelUsecase redownloadUsecase;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// DebugScreenViewModel.provider;
  /// ```
  const DebugScreenViewModel._({
    required this.state,
    required this.diagnoseUsecase,
    required this.diagnoseMeterVlUsecase,
    required this.log,
    required this.sessionPreference,
    required this.navigation,
    required this.stateToEntity,
    required this.redownloadSession,
    required this.redownloadUsecase,
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
