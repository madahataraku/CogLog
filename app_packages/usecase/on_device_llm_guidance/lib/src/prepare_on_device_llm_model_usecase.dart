import 'package:riverpod/riverpod.dart';

/// 端末上 LLM のモデル準備を依頼する。
///
/// Example:
/// ```dart
/// PrepareOnDeviceLlmModelUsecase.provider;
/// ```
abstract interface class PrepareOnDeviceLlmModelUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// PrepareOnDeviceLlmModelUsecase.provider;
  /// ```
  static final provider = Provider<PrepareOnDeviceLlmModelUsecase>(
    (ref) =>
        throw UnimplementedError('PrepareOnDeviceLlmModelUsecase.provider'),
  );

  /// モデル準備を依頼する。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<void> execute();
}
