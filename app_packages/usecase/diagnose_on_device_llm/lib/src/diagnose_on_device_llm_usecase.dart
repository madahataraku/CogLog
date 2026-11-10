import 'package:riverpod/riverpod.dart';

import 'diagnose_on_device_llm_result.dart';

/// 端末上 LLM の準備状態と短い生成を診断する。
///
/// Example:
/// ```dart
/// DiagnoseOnDeviceLlmUsecase.provider;
/// ```
abstract interface class DiagnoseOnDeviceLlmUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// DiagnoseOnDeviceLlmUsecase.provider;
  /// ```
  static final provider = Provider<DiagnoseOnDeviceLlmUsecase>(
    (ref) => throw UnimplementedError('DiagnoseOnDeviceLlmUsecase.provider'),
  );

  /// スナップショット取得と任意の生成プローブを行う。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<DiagnoseOnDeviceLlmResult> execute({bool probeGenerate = true});
}
