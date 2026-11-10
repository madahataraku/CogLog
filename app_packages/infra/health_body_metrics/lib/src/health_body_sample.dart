import 'health_body_metric_kind.dart';

/// 1 件の身体指標計測。
///
/// [value] は [kind] に応じて kg または %（0–100）。
///
/// Example:
/// ```dart
/// HealthBodySample(
///   kind: HealthBodyMetricKind.weightKg,
///   at: DateTime(2026, 11, 10, 8),
///   value: 70,
/// );
/// ```
final class HealthBodySample {
  /// 種類・計測日時・値を持つサンプルを作る。
  ///
  /// Example:
  /// ```dart
  /// HealthBodySample(
  ///   kind: HealthBodyMetricKind.bodyFatPercent,
  ///   at: DateTime(2026, 11, 10, 8),
  ///   value: 20,
  /// );
  /// ```
  const HealthBodySample({
    required this.kind,
    required this.at,
    required this.value,
  });

  /// 指標の種類。
  final HealthBodyMetricKind kind;

  /// 計測日時。
  final DateTime at;

  /// 正規化済みの値（kg または %）。
  final double value;
}
