import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:usecase_request_health_body_permission/usecase_request_health_body_permission.dart';

/// [HealthBodyMetricsSource.requestPermission] を呼ぶ実装。
///
/// Example:
/// ```dart
/// RequestHealthBodyPermissionUsecaseImpl(source: source).execute();
/// ```
final class RequestHealthBodyPermissionUsecaseImpl
    implements RequestHealthBodyPermissionUsecase {
  /// [source] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// RequestHealthBodyPermissionUsecaseImpl(source: source);
  /// ```
  const RequestHealthBodyPermissionUsecaseImpl({required this.source});

  /// 許可リクエスト口。
  final HealthBodyMetricsSource source;

  /// [source] の許可リクエストをそのまま返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute();
  /// ```
  @override
  Future<HealthBodyPermissionStatus> execute() => source.requestPermission();
}
