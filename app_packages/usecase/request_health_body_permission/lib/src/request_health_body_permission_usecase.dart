import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:riverpod/riverpod.dart';

/// 身体指標のヘルス許可をリクエストする。
///
/// Example:
/// ```dart
/// usecase.execute();
/// ```
abstract interface class RequestHealthBodyPermissionUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<RequestHealthBodyPermissionUsecase>(
    (ref) =>
        throw UnimplementedError('RequestHealthBodyPermissionUsecase.provider'),
  );

  /// 許可ダイアログを出し、結果の許可状態を返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute();
  /// ```
  Future<HealthBodyPermissionStatus> execute();
}
