import 'package:riverpod/riverpod.dart';

/// ヘルス書き込み案内を一度出したかを残す。
///
/// Example:
/// ```dart
/// repository.isSeen();
/// ```
abstract interface class HealthWriteGuidanceRepository {
  /// 未保存または false のときは false。
  ///
  /// Example:
  /// ```dart
  /// repository.isSeen();
  /// ```
  Future<bool> isSeen();

  /// 提示済みにする。
  ///
  /// Example:
  /// ```dart
  /// repository.markSeen();
  /// ```
  Future<void> markSeen();
}

/// 案内フラグ Repository の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// healthWriteGuidanceRepositoryProvider;
/// ```
final healthWriteGuidanceRepositoryProvider =
    Provider<HealthWriteGuidanceRepository>(
      (ref) =>
          throw UnimplementedError('healthWriteGuidanceRepositoryProvider'),
    );
