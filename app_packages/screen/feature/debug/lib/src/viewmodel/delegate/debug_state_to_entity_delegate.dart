import 'package:meta/meta.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

import '../../strings.dart';
import '../entity/debug_screen_entity.dart';
import '../state/debug_screen_state.dart';

/// 再ダウンロードボタンを押せるかを決める。
///
/// false になるのは phase==running / 診断実行中 / readiness unavailable
/// のみ。[DebugRedownloadDisabledReason.conflict] は理由表示用なのでここでは無視する（再試行可）。
///
/// Example:
/// ```dart
/// resolveRedownloadEnabled(DebugScreenState.initial);
/// ```
@visibleForTesting
bool resolveRedownloadEnabled(DebugScreenState state) {
  if (state.redownloadPhase == MeterVlRedownloadPhase.running) {
    return false;
  }
  if (state.running) {
    return false;
  }
  final readinessName = state.meterVlResult?.snapshot.readiness.name;
  if (readinessName == 'unavailable') {
    return false;
  }
  return true;
}

/// State から再ダウンロードの拒否理由（表示用）を決める。
///
/// ハード無効（running / diagnose / unavailable）を先に見る。
/// それらが無いときだけ [DebugRedownloadDisabledReason.conflict]（session.start の live 拒否）を返す。
/// conflict は [resolveRedownloadEnabled] には影響しない。
///
/// Example:
/// ```dart
/// resolveRedownloadDisabledReason(DebugScreenState.initial);
/// ```
@visibleForTesting
DebugRedownloadDisabledReason? resolveRedownloadDisabledReason(
  DebugScreenState state,
) {
  if (state.redownloadPhase == MeterVlRedownloadPhase.running) {
    return DebugRedownloadDisabledReason.redownloadRunning;
  }
  if (state.running) {
    return DebugRedownloadDisabledReason.diagnoseRunning;
  }
  final readinessName = state.meterVlResult?.snapshot.readiness.name;
  if (readinessName == 'unavailable') {
    return DebugRedownloadDisabledReason.unavailable;
  }
  if (state.redownloadDisabledReason ==
      DebugRedownloadDisabledReason.conflict) {
    return DebugRedownloadDisabledReason.conflict;
  }
  return state.redownloadDisabledReason;
}

/// 再ダウンロード開始拒否理由をデバッグ画面の文言へ写す。
///
/// null のときは空文字（`-` は使わない）。
///
/// Example:
/// ```dart
/// mapDisabledReason(DebugRedownloadDisabledReason.conflict);
/// ```
@visibleForTesting
String mapDisabledReason(DebugRedownloadDisabledReason? reason) {
  return switch (reason) {
    DebugRedownloadDisabledReason.unavailable =>
      strings.screen_feature_debug_redownload_disabled_unavailable,
    DebugRedownloadDisabledReason.diagnoseRunning =>
      strings.screen_feature_debug_redownload_disabled_busy,
    DebugRedownloadDisabledReason.redownloadRunning =>
      strings.screen_feature_debug_redownload_disabled_running,
    DebugRedownloadDisabledReason.conflict =>
      strings.screen_feature_debug_redownload_disabled_busy,
    null => '',
  };
}

/// 再ダウンロード失敗種別をデバッグ画面の文言へ写す。
///
/// Wi-Fi / 容量 / 通信は個別文言。その他と null は共通失敗文言。
///
/// Example:
/// ```dart
/// mapMeterVlRedownloadError(MeterVlPrepareFailureKind.wifiRequired);
/// ```
@visibleForTesting
String mapMeterVlRedownloadError(MeterVlPrepareFailureKind? kind) {
  return switch (kind) {
    MeterVlPrepareFailureKind.wifiRequired =>
      strings.screen_feature_debug_redownload_failed_wifi,
    MeterVlPrepareFailureKind.insufficientStorage =>
      strings.screen_feature_debug_redownload_failed_storage,
    MeterVlPrepareFailureKind.network =>
      strings.screen_feature_debug_redownload_failed_network,
    MeterVlPrepareFailureKind.generic ||
    null => strings.screen_feature_debug_redownload_failed,
  };
}

/// 再ダウンロードの相をステータス文言へ写す。
///
/// running / success は専用文言。failure は [mapMeterVlRedownloadError]。
/// idle は空文字。
///
/// Example:
/// ```dart
/// mapStatusText(DebugScreenState.initial);
/// ```
@visibleForTesting
String mapStatusText(DebugScreenState state) {
  return switch (state.redownloadPhase) {
    MeterVlRedownloadPhase.idle => '',
    MeterVlRedownloadPhase.running =>
      strings.screen_feature_debug_redownload_running,
    MeterVlRedownloadPhase.success =>
      strings.screen_feature_debug_redownload_success,
    MeterVlRedownloadPhase.failure => mapMeterVlRedownloadError(
      state.redownloadFailureKind,
    ),
  };
}

/// State を表示用 Entity へ写す。
///
/// Example:
/// ```dart
/// const DebugStateToEntityDelegate();
/// ```
final class DebugStateToEntityDelegate {
  /// 状態を持たず、どの [DebugScreenState] にも使い回せる。
  ///
  /// Example:
  /// ```dart
  /// const DebugStateToEntityDelegate();
  /// ```
  const DebugStateToEntityDelegate();

  /// [state] を表示用 [DebugScreenEntity] に写す。
  ///
  /// null・空文字の診断文字列は `'-'` に置き換える。
  /// ログ行は時刻・レベル・タグ付きの 1 行文字列へ整形し、[DebugScreenState.logs] の順を保つ。
  ///
  /// Example:
  /// ```dart
  /// const DebugStateToEntityDelegate().execute(DebugScreenState.initial);
  /// ```
  DebugScreenEntity execute(DebugScreenState state) {
    final result = state.result;
    final snapshot = result?.snapshot;
    final meterVl = state.meterVlResult;
    final meterVlSnapshot = meterVl?.snapshot;
    final disabled = resolveRedownloadDisabledReason(state);
    // ラベル行の未取得表示を画面全体で揃える。
    String dash(String? value) {
      if (value == null || value.isEmpty) {
        return '-';
      }
      return value;
    }

    final logLines = state.logs
        .map((entry) {
          final time =
              '${entry.at.hour.toString().padLeft(2, '0')}:'
              '${entry.at.minute.toString().padLeft(2, '0')}:'
              '${entry.at.second.toString().padLeft(2, '0')}';
          return '[$time] ${entry.level.name}/${entry.tag}: ${entry.message}';
        })
        .toList(growable: false);

    return DebugScreenEntity(
      running: state.running,
      readiness: snapshot?.readiness.name ?? '-',
      status: dash(snapshot?.status),
      reason: dash(snapshot?.reason),
      message: dash(snapshot?.message),
      backend: dash(snapshot?.backend),
      platformNotes: dash(snapshot?.platformNotes),
      availabilityError: dash(snapshot?.error),
      canGenerate: result?.canGenerate,
      sampleOutput: dash(result?.sampleOutput),
      generateError: dash(result?.generateError),
      prepareError: dash(result?.prepareError),
      probeSkipped: dash(result?.probeSkippedReason),
      meterVlReadiness: meterVlSnapshot?.readiness.name ?? '-',
      meterVlStatus: dash(meterVlSnapshot?.status),
      meterVlReason: dash(meterVlSnapshot?.reason),
      meterVlMessage: dash(meterVlSnapshot?.message),
      meterVlBackend: dash(meterVlSnapshot?.backend),
      meterVlVisionBackend: dash(meterVlSnapshot?.visionBackend),
      meterVlAvailabilityError: dash(meterVl?.availabilityError),
      meterVlCanGenerate: meterVl?.canGenerate,
      meterVlProbeOutputLength: meterVl?.probeOutputLength?.toString() ?? '-',
      meterVlGenerateError: dash(meterVl?.generateError),
      meterVlPrepareError: dash(meterVl?.prepareError),
      meterVlProbeSkipped: dash(meterVl?.probeSkippedReason),
      preferLfmVlOverOsLlm: state.preferLfmVlOverOsLlm,
      logLines: logLines,
      redownloadEnabled: resolveRedownloadEnabled(state),
      redownloadDisabledReason: mapDisabledReason(disabled),
      redownloadPhase: state.redownloadPhase,
      redownloadProgress: state.redownloadProgress,
      redownloadFailureKind: state.redownloadFailureKind,
      diagnoseRefreshPending: state.diagnoseRefreshPending,
      redownloadStatusText: mapStatusText(state),
    );
  }
}
