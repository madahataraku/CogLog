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
  /// [nextUpdateExternalId] を渡すと、更新成功時にその ID を返す。
  ///
  /// Example:
  /// ```dart
  /// FakeHealthWorkoutWriter();
  /// ```
  FakeHealthWorkoutWriter({this.succeed = true, this.nextUpdateExternalId});

  /// [writeCycling] / [updateCycling] / [deleteCycling] の成否。
  bool succeed;

  /// 更新成功時に返す外部 ID。null なら引数の [externalId] を返す。
  final String? nextUpdateExternalId;

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

  /// 成功時は [nextUpdateExternalId] または [externalId]、失敗時は null。
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
  Future<String?> updateCycling({
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
    if (!succeed) {
      return null;
    }
    return nextUpdateExternalId ?? externalId;
  }

  /// [succeed] を返し、[externalId] と時間窓を記録する。
  ///
  /// Example:
  /// ```dart
  /// await FakeHealthWorkoutWriter().deleteCycling(
  ///   externalId: 'fake-health-1',
  ///   start: DateTime.timestamp(),
  ///   end: DateTime.timestamp(),
  /// );
  /// ```
  @override
  Future<bool> deleteCycling({
    required String externalId,
    required DateTime start,
    required DateTime end,
  }) async {
    deleteCallCount += 1;
    lastExternalId = externalId;
    lastStart = start;
    lastEnd = end;
    return succeed;
  }
}
