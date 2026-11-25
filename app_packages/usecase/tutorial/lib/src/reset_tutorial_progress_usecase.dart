import 'package:riverpod/riverpod.dart';

/// チュートリアル進捗を初期化し、手動開始ガードを立てる。
///
/// Example:
/// ```dart
/// ResetTutorialProgressUsecase.provider;
/// ```
abstract interface class ResetTutorialProgressUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// ResetTutorialProgressUsecase.provider;
  /// ```
  static final provider = Provider<ResetTutorialProgressUsecase>(
    (ref) => throw UnimplementedError('ResetTutorialProgressUsecase.provider'),
  );

  /// 永続を initial にし、session をクリアしたうえで manualStartGuard を立てる。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<void> execute();
}
