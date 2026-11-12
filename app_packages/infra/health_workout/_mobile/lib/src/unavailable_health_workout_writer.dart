import 'package:infra_health_workout/infra_health_workout.dart';

/// 初回アプリ向けの未接続ヘルス書き込み。
///
/// 常に null / false。Apple Health / Health Connect の実接続は後続で差し替える。
///
/// Example:
/// ```dart
/// const UnavailableHealthWorkoutWriter();
/// ```
final class UnavailableHealthWorkoutWriter implements HealthWorkoutWriter {
  /// 利用不可の実装を作る。
  ///
  /// Example:
  /// ```dart
  /// const UnavailableHealthWorkoutWriter();
  /// ```
  const UnavailableHealthWorkoutWriter();

  /// 常に null を返す。例外は投げない。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableHealthWorkoutWriter().writeCycling(
  ///   start: DateTime.timestamp(),
  ///   end: DateTime.timestamp(),
  ///   distanceKm: 1,
  ///   duration: const Duration(minutes: 1),
  ///   caloriesKcal: 1,
  /// );
  /// ```
  @override
  Future<String?> writeCycling({
    required DateTime start,
    required DateTime end,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
  }) async => null;

  /// 常に false を返す。例外は投げない。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableHealthWorkoutWriter().updateCycling(
  ///   externalId: 'health-1',
  ///   start: DateTime.timestamp(),
  ///   end: DateTime.timestamp(),
  ///   distanceKm: 1,
  ///   duration: const Duration(minutes: 1),
  ///   caloriesKcal: 1,
  /// );
  /// ```
  @override
  Future<bool> updateCycling({
    required String externalId,
    required DateTime start,
    required DateTime end,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
  }) async => false;

  /// 常に false を返す。例外は投げない。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableHealthWorkoutWriter().deleteCycling(
  ///   externalId: 'health-1',
  /// );
  /// ```
  @override
  Future<bool> deleteCycling({required String externalId}) async => false;
}
