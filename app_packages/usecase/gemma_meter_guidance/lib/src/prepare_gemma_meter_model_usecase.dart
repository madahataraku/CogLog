import 'package:riverpod/riverpod.dart';

/// Gemma メーターモデルの準備を依頼する。
///
/// Example:
/// ```dart
/// PrepareGemmaMeterModelUsecase.provider;
/// ```
abstract interface class PrepareGemmaMeterModelUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// PrepareGemmaMeterModelUsecase.provider;
  /// ```
  static final provider = Provider<PrepareGemmaMeterModelUsecase>(
    (ref) => throw UnimplementedError('PrepareGemmaMeterModelUsecase.provider'),
  );

  /// Wi-Fi 以外なら準備失敗例外を投げる。
  /// Wi-Fi ならモデル準備の進捗を流す。
  ///
  /// Example:
  /// ```dart
  /// await for (final progress in usecase.execute()) {
  ///   progress;
  /// }
  /// ```
  Stream<double> execute();
}
