import 'package:data_repository_health_write_guidance/data_repository_health_write_guidance.dart';
import 'package:infra_health_workout/infra_health_workout.dart';
import 'package:usecase_health_write_guidance/usecase_health_write_guidance.dart';

/// 提示済みフラグと書き込み権限から案内要否を決める。
///
/// Example:
/// ```dart
/// HealthWriteGuidanceUsecaseImpl(
///   guidance: guidance,
///   health: health,
/// ).shouldShow();
/// ```
final class HealthWriteGuidanceUsecaseImpl
    implements HealthWriteGuidanceUsecase {
  /// [guidance] と [health] を読む実装を作る。
  ///
  /// Example:
  /// ```dart
  /// HealthWriteGuidanceUsecaseImpl(guidance: guidance, health: health);
  /// ```
  const HealthWriteGuidanceUsecaseImpl({
    required this.guidance,
    required this.health,
  });

  /// 提示済みフラグの保存先。
  final HealthWriteGuidanceRepository guidance;

  /// 書き込み権限の照会先。
  final HealthWorkoutWriter health;

  /// 未提示かつ書き込み未連携なら true。
  ///
  /// Example:
  /// ```dart
  /// usecase.shouldShow();
  /// ```
  @override
  Future<bool> shouldShow() async {
    if (await guidance.isSeen()) {
      return false;
    }
    if (await health.hasWritePermissionGranted()) {
      return false;
    }
    return true;
  }

  /// 提示済みにする。
  ///
  /// Example:
  /// ```dart
  /// usecase.markSeen();
  /// ```
  @override
  Future<void> markSeen() => guidance.markSeen();
}
