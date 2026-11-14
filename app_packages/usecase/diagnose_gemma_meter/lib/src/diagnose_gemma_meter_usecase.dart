import 'package:riverpod/riverpod.dart';

import 'diagnose_gemma_meter_result.dart';

/// Gemma メーター経路の準備状態と短い画像生成を診断する。
///
/// Example:
/// ```dart
/// DiagnoseGemmaMeterUsecase.provider;
/// ```
abstract interface class DiagnoseGemmaMeterUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// DiagnoseGemmaMeterUsecase.provider;
  /// ```
  static final provider = Provider<DiagnoseGemmaMeterUsecase>(
    (ref) => throw UnimplementedError('DiagnoseGemmaMeterUsecase.provider'),
  );

  /// スナップショット取得と任意の画像生成プローブを行う。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<DiagnoseGemmaMeterResult> execute({bool probeGenerate = true});
}
