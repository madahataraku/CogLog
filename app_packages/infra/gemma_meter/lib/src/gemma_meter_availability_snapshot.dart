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
  });

  /// アプリが使う準備状態。
  final GemmaMeterReadiness readiness;

  /// ネイティブ由来の status 名。
  final String status;

  /// ネイティブ由来の reason 名。
  final String reason;

  /// 人間が読める説明。
  final String message;
}
