import 'package:riverpod/riverpod.dart';

import 'health_body_metrics_read_exception.dart';
import 'health_body_permission_status.dart';
import 'health_body_sample.dart';

/// ヘルス身体指標の許可と読取の口。
///
/// Example:
/// ```dart
/// await source.permissionStatus();
/// ```
abstract interface class HealthBodyMetricsSource {
  /// いまの許可状態を返す。
  ///
  /// Example:
  /// ```dart
  /// await source.permissionStatus();
  /// ```
  Future<HealthBodyPermissionStatus> permissionStatus();

  /// 体重・体脂肪率・除脂肪体重をまとめて許可リクエストする。
  ///
  /// Example:
  /// ```dart
  /// await source.requestPermission();
  /// ```
  Future<HealthBodyPermissionStatus> requestPermission();

  /// `[startInclusive, endExclusive)` の計測を返す。未許可の kind は含めない。
  ///
  /// 失敗時は [HealthBodyMetricsReadException] を投げる。
  ///
  /// Example:
  /// ```dart
  /// await source.read(
  ///   startInclusive: DateTime(2026, 10, 12),
  ///   endExclusive: DateTime(2026, 11, 11),
  /// );
  /// ```
  Future<List<HealthBodySample>> read({
    required DateTime startInclusive,
    required DateTime endExclusive,
  });
}

/// 身体指標ソースの注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// healthBodyMetricsSourceProvider;
/// ```
final healthBodyMetricsSourceProvider = Provider<HealthBodyMetricsSource>(
  (ref) => throw UnimplementedError('healthBodyMetricsSourceProvider'),
);
