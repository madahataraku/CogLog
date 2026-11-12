import 'package:infra_health_workout/infra_health_workout.dart';

/// テスト用の固定成否ヘルス書き込み。
///
/// Example:
/// ```dart
/// FakeHealthWorkoutWriter(succeed: false);
/// ```
final class FakeHealthWorkoutWriter implements HealthWorkoutWriter {
  /// [succeed] で戻り値を切り替える。
  ///
  /// Example:
  /// ```dart
  /// FakeHealthWorkoutWriter();
  /// ```
  FakeHealthWorkoutWriter({this.succeed = true});

  /// [writeCycling] / [updateCycling] / [deleteCycling] の成否。
  bool succeed;

  /// [writeCycling] が呼ばれた回数。
  int writeCallCount = 0;

  /// [updateCycling] が呼ばれた回数。
  int updateCallCount = 0;

  /// [deleteCycling] が呼ばれた回数。
  int deleteCallCount = 0;

  /// 最後に渡された開始日時。
  DateTime? lastStart;

  /// 最後に渡された終了日時。
  DateTime? lastEnd;

  /// 最後に渡された距離 km。
  double? lastDistanceKm;

  /// 最後に渡された運動時間。
  Duration? lastDuration;

  /// 最後に渡された消費カロリー。
  double? lastCaloriesKcal;

  /// 最後に [updateCycling] / [deleteCycling] へ渡された外部 ID。
  String? lastExternalId;

  /// 成功時は `fake-health-{n}`、失敗時は null。引数を記録する。
  ///
  /// Example:
  /// ```dart
  /// await FakeHealthWorkoutWriter().writeCycling(
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
  }) async {
    writeCallCount += 1;
    lastStart = start;
    lastEnd = end;
    lastDistanceKm = distanceKm;
    lastDuration = duration;
    lastCaloriesKcal = caloriesKcal;
    if (!succeed) {
      return null;
    }
    return 'fake-health-$writeCallCount';
  }

  /// [succeed] を返し、[externalId] と計測値を記録する。
  ///
  /// Example:
  /// ```dart
  /// await FakeHealthWorkoutWriter().updateCycling(
  ///   externalId: 'fake-health-1',
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
  }) async {
    updateCallCount += 1;
    lastExternalId = externalId;
    lastStart = start;
    lastEnd = end;
    lastDistanceKm = distanceKm;
    lastDuration = duration;
    lastCaloriesKcal = caloriesKcal;
    return succeed;
  }

  /// [succeed] を返し、[externalId] を記録する。
  ///
  /// Example:
  /// ```dart
  /// await FakeHealthWorkoutWriter().deleteCycling(
  ///   externalId: 'fake-health-1',
  /// );
  /// ```
  @override
  Future<bool> deleteCycling({required String externalId}) async {
    deleteCallCount += 1;
    lastExternalId = externalId;
    return succeed;
  }
}
