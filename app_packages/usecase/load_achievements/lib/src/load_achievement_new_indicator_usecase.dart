import 'package:riverpod/riverpod.dart';

/// ホーム等向けに、新規アチーブメントの有無を返す。
///
/// Example:
/// ```dart
/// LoadAchievementNewIndicatorUsecase.provider;
/// ```
abstract interface class LoadAchievementNewIndicatorUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// LoadAchievementNewIndicatorUsecase.provider;
  /// ```
  static final provider = Provider<LoadAchievementNewIndicatorUsecase>(
    (ref) =>
        throw UnimplementedError('LoadAchievementNewIndicatorUsecase.provider'),
  );

  /// 未保存なら [now] で初期化し、新規が 1 件以上なら true。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(now: DateTime.timestamp());
  /// ```
  Future<bool> execute({required DateTime now});
}
