import 'on_device_llm_readiness.dart';

/// 端末上 LLM の診断用詳細。
///
/// 業務経路では [OnDeviceLlmReadiness] だけを使い、デバッグ画面がこの型を読む。
///
/// Example:
/// ```dart
/// const OnDeviceLlmAvailabilitySnapshot(
///   readiness: OnDeviceLlmReadiness.ready,
///   status: 'available',
///   reason: 'ready',
///   message: 'ok',
/// );
/// ```
final class OnDeviceLlmAvailabilitySnapshot {
  /// 写した準備状態とネイティブ由来の文字列を持つ。
  ///
  /// Example:
  /// ```dart
  /// const OnDeviceLlmAvailabilitySnapshot(
  ///   readiness: OnDeviceLlmReadiness.ready,
  ///   status: 'available',
  ///   reason: 'ready',
  ///   message: 'ok',
  /// );
  /// ```
  const OnDeviceLlmAvailabilitySnapshot({
    required this.readiness,
    required this.status,
    required this.reason,
    required this.message,
    this.backend,
    this.platformNotes,
    this.error,
  });

  /// アプリが使う準備状態。
  final OnDeviceLlmReadiness readiness;

  /// ネイティブの status 名（available / downloadable など）。
  final String status;

  /// ネイティブの reason 名。
  final String reason;

  /// 人間が読める説明。
  final String message;

  /// バックエンド名（あれば）。
  final String? backend;

  /// プラットフォーム診断メモ（あれば）。
  final String? platformNotes;

  /// availability 取得自体が失敗したときの例外文字列。
  final String? error;
}
