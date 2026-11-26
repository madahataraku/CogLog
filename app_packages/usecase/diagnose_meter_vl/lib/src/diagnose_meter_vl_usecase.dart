import 'package:riverpod/riverpod.dart';

import 'diagnose_meter_vl_result.dart';

/// メーター VL経路の準備状態と短い画像生成を診断する。
///
/// Example:
/// ```dart
/// DiagnoseMeterVlUsecase.provider;
/// ```
abstract interface class DiagnoseMeterVlUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// DiagnoseMeterVlUsecase.provider;
  /// ```
  static final provider = Provider<DiagnoseMeterVlUsecase>(
    (ref) => throw UnimplementedError('DiagnoseMeterVlUsecase.provider'),
  );

  /// スナップショット取得と任意の画像生成プローブを行う。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<DiagnoseMeterVlResult> execute({bool probeGenerate = true});
}
