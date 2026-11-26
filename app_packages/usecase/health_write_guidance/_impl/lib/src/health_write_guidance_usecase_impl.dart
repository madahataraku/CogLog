import 'package:data_repository_health_write_guidance/data_repository_health_write_guidance.dart';
import 'package:usecase_health_write_guidance/usecase_health_write_guidance.dart';

/// 提示済みフラグを Repository に渡す。
///
/// Example:
/// ```dart
/// HealthWriteGuidanceUsecaseImpl(guidance: guidance).shouldShow();
/// ```
final class HealthWriteGuidanceUsecaseImpl
    implements HealthWriteGuidanceUsecase {
  /// [guidance] を読む実装を作る。
  ///
  /// Example:
  /// ```dart
  /// HealthWriteGuidanceUsecaseImpl(guidance: guidance);
  /// ```
  const HealthWriteGuidanceUsecaseImpl({required this.guidance});

  /// 提示済みフラグの保存先。
  final HealthWriteGuidanceRepository guidance;

  /// 未提示なら true。
  ///
  /// Example:
  /// ```dart
  /// usecase.shouldShow();
  /// ```
  @override
  Future<bool> shouldShow() async => !(await guidance.isSeen());

  /// 提示済みにする。
  ///
  /// Example:
  /// ```dart
  /// usecase.markSeen();
  /// ```
  @override
  Future<void> markSeen() => guidance.markSeen();
}
