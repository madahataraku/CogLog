import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:meta/meta.dart';
import 'package:usecase_diagnose_meter_vl/usecase_diagnose_meter_vl.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

/// 再ダウンロード開始拒否の理由キー（Entity で文言化する）。
///
/// [DebugRedownloadDisabledReason.conflict] は理由表示専用。
/// ボタン無効条件（[resolveRedownloadEnabled]）には含めない。
@internal
enum DebugRedownloadDisabledReason {
  /// LFM VL 非対応端末（ボタン無効）。
  unavailable,

  /// 診断実行中（ボタン無効）。
  diagnoseRunning,

  /// 再ダウンロード実行中（ボタン無効）。
  redownloadRunning,

  /// prepare / generate 競合（session.start が live 拒否）。
  /// 理由は出すがボタンは押せる（再試行可）。
  conflict,
}

/// デバッグ画面の状態。
///
/// Example:
/// ```dart
/// DebugScreenState.initial;
/// ```
final class DebugScreenState {
  /// 診断結果・実行中フラグ・ログ行・LFM VL 優先・再ダウンロード表示を持つ。
  ///
  /// Example:
  /// ```dart
  /// DebugScreenState.initial;
  /// ```
  const DebugScreenState({
    required this.running,
    required this.result,
    required this.meterVlResult,
    required this.logs,
    required this.preferLfmVlOverOsLlm,
    required this.redownloadPhase,
    required this.redownloadProgress,
    required this.redownloadFailureKind,
    required this.diagnoseRefreshPending,
    required this.redownloadDisabledReason,
  });

  /// 初期状態。
  static const initial = DebugScreenState(
    running: false,
    result: null,
    meterVlResult: null,
    logs: [],
    preferLfmVlOverOsLlm: false,
    redownloadPhase: MeterVlRedownloadPhase.idle,
    redownloadProgress: 0,
    redownloadFailureKind: null,
    diagnoseRefreshPending: false,
    redownloadDisabledReason: null,
  );

  /// 診断実行中なら true。
  final bool running;

  /// 直近の端末上 LLM 診断結果。
  final DiagnoseOnDeviceLlmResult? result;

  /// 直近の メーター VL診断結果。
  final DiagnoseMeterVlResult? meterVlResult;

  /// 表示するログ行（新しい順ではない、ストア順）。
  final List<AppLogEntry> logs;

  /// 同一プロセス内で メーター VL をメーター読み取りで優先するとき true。
  final bool preferLfmVlOverOsLlm;

  /// session から同期した相。診断・ログ操作では保持する。
  final MeterVlRedownloadPhase redownloadPhase;

  /// session から同期した進捗 0.0〜1.0。
  final double redownloadProgress;

  /// session から同期した失敗種別。
  final MeterVlPrepareFailureKind? redownloadFailureKind;

  /// session から同期した診断更新待ち。
  final bool diagnoseRefreshPending;

  /// 開始拒否理由の保持。
  ///
  /// [DebugRedownloadDisabledReason.conflict] は start false（busy）時にセットし、
  /// 理由表示に使う。ボタン無効の主条件には含めない（[resolveRedownloadEnabled]）。
  final DebugRedownloadDisabledReason? redownloadDisabledReason;

  /// 指定フィールドだけ差し替えたコピーを返す。
  ///
  /// `result` / `meterVlResult` / `redownloadFailureKind` /
  /// `redownloadDisabledReason` を null にするには、それぞれ
  /// `clearResult` / `clearMeterVlResult` / `clearRedownloadFailureKind` /
  /// `clearRedownloadDisabledReason` を true にする。
  /// 引数に null を渡すだけでは既存値が残る（`?? this.*`）。
  /// 省略した `redownload*` は必ず current から残る。
  ///
  /// Example:
  /// ```dart
  /// state.copyWith(running: true);
  /// state.copyWith(clearResult: true, clearMeterVlResult: true);
  /// state.copyWith(clearRedownloadDisabledReason: true);
  /// ```
  DebugScreenState copyWith({
    bool? running,
    DiagnoseOnDeviceLlmResult? result,
    DiagnoseMeterVlResult? meterVlResult,
    List<AppLogEntry>? logs,
    bool? preferLfmVlOverOsLlm,
    MeterVlRedownloadPhase? redownloadPhase,
    double? redownloadProgress,
    MeterVlPrepareFailureKind? redownloadFailureKind,
    bool? diagnoseRefreshPending,
    DebugRedownloadDisabledReason? redownloadDisabledReason,
    bool clearResult = false,
    bool clearMeterVlResult = false,
    bool clearRedownloadFailureKind = false,
    bool clearRedownloadDisabledReason = false,
  }) {
    return DebugScreenState(
      running: running ?? this.running,
      result: clearResult ? null : (result ?? this.result),
      meterVlResult: clearMeterVlResult
          ? null
          : (meterVlResult ?? this.meterVlResult),
      logs: logs ?? this.logs,
      preferLfmVlOverOsLlm: preferLfmVlOverOsLlm ?? this.preferLfmVlOverOsLlm,
      redownloadPhase: redownloadPhase ?? this.redownloadPhase,
      redownloadProgress: redownloadProgress ?? this.redownloadProgress,
      redownloadFailureKind: clearRedownloadFailureKind
          ? null
          : (redownloadFailureKind ?? this.redownloadFailureKind),
      diagnoseRefreshPending:
          diagnoseRefreshPending ?? this.diagnoseRefreshPending,
      redownloadDisabledReason: clearRedownloadDisabledReason
          ? null
          : (redownloadDisabledReason ?? this.redownloadDisabledReason),
    );
  }
}
