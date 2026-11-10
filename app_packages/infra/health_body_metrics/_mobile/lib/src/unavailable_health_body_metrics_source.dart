import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';

/// 非 iOS/Android 向けの未接続身体指標ソース。
///
/// 許可は常に [HealthBodyPermissionStatus.permanentlyDenied]、読取は空。
///
/// Example:
/// ```dart
/// const UnavailableHealthBodyMetricsSource();
/// ```
final class UnavailableHealthBodyMetricsSource
    implements HealthBodyMetricsSource {
  /// 利用不可の実装を作る。
  ///
  /// Example:
  /// ```dart
  /// const UnavailableHealthBodyMetricsSource();
  /// ```
  const UnavailableHealthBodyMetricsSource();

  /// 常に [HealthBodyPermissionStatus.permanentlyDenied] を返す。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableHealthBodyMetricsSource().permissionStatus();
  /// ```
  @override
  Future<HealthBodyPermissionStatus> permissionStatus() async =>
      HealthBodyPermissionStatus.permanentlyDenied;

  /// 常に [HealthBodyPermissionStatus.permanentlyDenied] を返す。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableHealthBodyMetricsSource().requestPermission();
  /// ```
  @override
  Future<HealthBodyPermissionStatus> requestPermission() async =>
      HealthBodyPermissionStatus.permanentlyDenied;

  /// 常に空リストを返す。例外は投げない。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableHealthBodyMetricsSource().read(
  ///   startInclusive: DateTime(2026, 10, 12),
  ///   endExclusive: DateTime(2026, 11, 11),
  /// );
  /// ```
  @override
  Future<List<HealthBodySample>> read({
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async => const [];

  /// 常に true（履歴制限の対象外）。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableHealthBodyMetricsSource().isHistoryAuthorized();
  /// ```
  @override
  Future<bool> isHistoryAuthorized() async => true;
}
