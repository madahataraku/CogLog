import 'package:riverpod/riverpod.dart';

/// ヘルス書き込み案内を出すか判定し、提示済みにする。
///
/// Example:
/// ```dart
/// usecase.shouldShow();
/// ```
abstract interface class HealthWriteGuidanceUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<HealthWriteGuidanceUsecase>(
    (ref) => throw UnimplementedError('HealthWriteGuidanceUsecase.provider'),
  );

  /// 未提示かつ書き込み未連携なら true。
  ///
  /// Example:
  /// ```dart
  /// usecase.shouldShow();
  /// ```
  Future<bool> shouldShow();

  /// 提示済みにする。
  ///
  /// Example:
  /// ```dart
  /// usecase.markSeen();
  /// ```
  Future<void> markSeen();
}
