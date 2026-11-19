import 'gemma_meter_readiness.dart';

/// Gemma 経路の診断向けスナップショット（本文・測定値なし）。
///
/// Example:
/// ```dart
/// const GemmaMeterAvailabilitySnapshot(
///   readiness: GemmaMeterReadiness.ready,
///   status: 'available',
///   reason: 'ready',
///   message: 'ok',
///   backend: 'gpu',
///   visionBackend: 'cpu',
/// );
/// ```
final class GemmaMeterAvailabilitySnapshot {
  /// 準備状態と短い診断文言を持つ。
  ///
  /// Example:
  /// ```dart
  /// const GemmaMeterAvailabilitySnapshot(
  ///   readiness: GemmaMeterReadiness.ready,
  ///   status: 'available',
  ///   reason: 'ready',
  ///   message: 'ok',
  /// );
  /// ```
  const GemmaMeterAvailabilitySnapshot({
    required this.readiness,
    required this.status,
    required this.reason,
    required this.message,
    this.backend = '',
    this.visionBackend = '',
  });

  /// アプリが使う準備状態。
  final GemmaMeterReadiness readiness;

  /// ネイティブ由来の status 名。
  final String status;

  /// ネイティブ由来の reason 名。
  final String reason;

  /// 人間が読める説明。
  final String message;

  /// 実行 backend（例: Android LiteRT `gpu` / `cpu`、iOS Core ML `ane`）。未設定は空。
  final String backend;

  /// Vision 実行 backend（例: Android LiteRT `gpu` / `cpu`、iOS Core ML `ane`）。未設定は空。
  final String visionBackend;
}
