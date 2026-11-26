import 'package:infra_meter_vl/infra_meter_vl.dart';

/// 再ダウンロードセッションの相。
enum MeterVlRedownloadPhase {
  /// 未実行、または結果表示を消したあと。
  idle,

  /// 削除〜prepare 実行中。
  running,

  /// 再準備完了。
  success,

  /// 失敗（[MeterVlRedownloadSessionState.failureKind] を参照）。
  failure,
}

/// プロセス内セッションの表示用状態。
///
/// Example:
/// ```dart
/// const MeterVlRedownloadSessionState(
///   phase: MeterVlRedownloadPhase.idle,
///   progress: 0,
///   failureKind: null,
///   diagnoseRefreshPending: false,
/// );
/// ```
final class MeterVlRedownloadSessionState {
  /// 相・進捗・失敗種別・診断更新待ちを持つ。
  ///
  /// Example:
  /// ```dart
  /// const MeterVlRedownloadSessionState(
  ///   phase: MeterVlRedownloadPhase.idle,
  ///   progress: 0,
  ///   failureKind: null,
  ///   diagnoseRefreshPending: false,
  /// );
  /// ```
  const MeterVlRedownloadSessionState({
    required this.phase,
    required this.progress,
    required this.failureKind,
    required this.diagnoseRefreshPending,
  });

  /// 未実行かつ診断更新待ちなしの開始スナップショット。
  static const initial = MeterVlRedownloadSessionState(
    phase: MeterVlRedownloadPhase.idle,
    progress: 0,
    failureKind: null,
    diagnoseRefreshPending: false,
  );

  /// 削除〜prepare の進行段階（idle / running / success / failure）。
  final MeterVlRedownloadPhase phase;

  /// prepare 進捗 0.0〜1.0（UI ゲージ用。running 以外は最終値または 0）。
  final double progress;

  /// failure 時のみ設定する準備失敗種別。他相では null。
  final MeterVlPrepareFailureKind? failureKind;

  /// 成功／失敗確定後、デバッグ画面がまだ再診断していないとき true。
  final bool diagnoseRefreshPending;
}
