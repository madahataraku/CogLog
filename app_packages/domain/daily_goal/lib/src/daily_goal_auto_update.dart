import 'daily_goal.dart';
import 'daily_goal_auto_update_level.dart';

/// 一日あたり目標への上方修正。
///
/// Example:
/// ```dart
/// DailyGoalAutoUpdate.apply(
///   const DailyGoal(caloriesKcal: 100),
///   DailyGoalAutoUpdateLevel.slow,
/// );
/// ```
final class DailyGoalAutoUpdate {
  /// 計算用の名前空間。
  const DailyGoalAutoUpdate._();

  /// 正の目標だけを [level] の倍率で切り上げる。未設定と 0 は変えない。
  ///
  /// Example:
  /// ```dart
  /// DailyGoalAutoUpdate.apply(
  ///   const DailyGoal(distanceKm: 1),
  ///   DailyGoalAutoUpdateLevel.normal,
  /// );
  /// ```
  static DailyGoal apply(DailyGoal goal, DailyGoalAutoUpdateLevel level) {
    final multiplier = level.multiplier;
    return DailyGoal(
      duration: _scaleDuration(goal.duration, multiplier),
      caloriesKcal: _scalePositive(goal.caloriesKcal, multiplier),
      distanceKm: _scalePositive(goal.distanceKm, multiplier),
    );
  }

  /// 正の運動時間を [multiplier] 倍し、秒単位へ切り上げる。
  ///
  /// Example:
  /// ```dart
  /// DailyGoalAutoUpdate.apply(
  ///   const DailyGoal(duration: Duration(seconds: 3600)),
  ///   DailyGoalAutoUpdateLevel.normal,
  /// );
  /// ```
  static Duration? _scaleDuration(Duration? value, double multiplier) {
    if (value == null || value <= Duration.zero) {
      return value;
    }
    final product = value.inSeconds * multiplier;
    final nearest = product.round();
    // 浮動小数の僅差は切り上げず、それ以外は秒単位で切り上げる。
    final scaled = (product - nearest).abs() < 1e-6 ? nearest : product.ceil();
    return Duration(seconds: scaled < 1 ? 1 : scaled);
  }

  static double? _scalePositive(double? value, double multiplier) {
    if (value == null || value <= 0) {
      return value;
    }
    final product = value * multiplier;
    final micros = product * 1e6;
    // 浮動小数の僅差は切り上げず、それ以外は 1e-6 単位で切り上げる。
    final adjustedMicros = (micros - micros.round()).abs() < 1e-6
        ? micros.round()
        : micros.ceil();
    final scaled = adjustedMicros / 1e6;
    if (scaled < value) {
      return value;
    }
    return scaled < 1e-6 ? 1e-6 : scaled;
  }
}
