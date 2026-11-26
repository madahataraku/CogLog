import 'package:riverpod/riverpod.dart';

/// メーター VLモデルの準備を依頼する。
///
/// Example:
/// ```dart
/// PrepareMeterVlModelUsecase.provider;
/// ```
abstract interface class PrepareMeterVlModelUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// PrepareMeterVlModelUsecase.provider;
  /// ```
  static final provider = Provider<PrepareMeterVlModelUsecase>(
    (ref) => throw UnimplementedError('PrepareMeterVlModelUsecase.provider'),
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
