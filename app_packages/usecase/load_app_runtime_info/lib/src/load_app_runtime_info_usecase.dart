import 'package:infra_app_runtime_info/infra_app_runtime_info.dart';
import 'package:riverpod/riverpod.dart';

/// アプリ実行情報を画面向けに読む。
///
/// Example:
/// ```dart
/// LoadAppRuntimeInfoUsecase.provider;
/// ```
abstract interface class LoadAppRuntimeInfoUsecase {
  /// 未接続時は失敗する注入点。
  static final provider = Provider<LoadAppRuntimeInfoUsecase>(
    (ref) => throw UnimplementedError('LoadAppRuntimeInfoUsecase.provider'),
  );

  /// 成功時のみ非 null。欠落・例外は null。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<AppRuntimeInfo?> execute();
}
