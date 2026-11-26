import 'package:riverpod/riverpod.dart';

/// デバッグ用に LFM VL を強制削除してから再準備する。
///
/// Example:
/// ```dart
/// RedownloadMeterVlModelUsecase.provider;
/// ```
abstract interface class RedownloadMeterVlModelUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// RedownloadMeterVlModelUsecase.provider;
  /// ```
  static final provider = Provider<RedownloadMeterVlModelUsecase>(
    (ref) => throw UnimplementedError('RedownloadMeterVlModelUsecase.provider'),
  );

  /// Wi-Fi 以外・削除失敗・prepare 失敗・削除直後の競合は [MeterVlPrepareException]。
  /// 成功時は prepare の進捗（0.0〜1.0）を流す。
  ///
  /// Example:
  /// ```dart
  /// await for (final progress in usecase.execute()) {
  ///   progress;
  /// }
  /// ```
  Stream<double> execute();
}
