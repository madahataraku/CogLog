import 'package:data_repository_health_write_guidance/data_repository_health_write_guidance.dart';

/// メモリ上の提示済みフラグ。初期は未提示。
///
/// Example:
/// ```dart
/// final repository = MemoryHealthWriteGuidanceRepository();
/// repository.markSeen();
/// ```
final class MemoryHealthWriteGuidanceRepository
    implements HealthWriteGuidanceRepository {
  /// 未提示の状態で作る。
  ///
  /// Example:
  /// ```dart
  /// MemoryHealthWriteGuidanceRepository();
  /// ```
  MemoryHealthWriteGuidanceRepository();

  var _seen = false;

  /// まだ書いていなければ false。
  ///
  /// Example:
  /// ```dart
  /// repository.isSeen();
  /// ```
  @override
  Future<bool> isSeen() async => _seen;

  /// 次の [isSeen] で true を返す。
  ///
  /// Example:
  /// ```dart
  /// repository.markSeen();
  /// ```
  @override
  Future<void> markSeen() async {
    _seen = true;
  }
}
