import 'package:riverpod/riverpod.dart';

/// ヘルスサービスへサイクリングを書く・更新・削除する。
///
/// Example:
/// ```dart
/// await writer.writeCycling(
///   start: DateTime.timestamp(),
///   end: DateTime.timestamp(),
///   distanceKm: 1,
///   duration: const Duration(minutes: 1),
///   caloriesKcal: 1,
/// );
/// ```
abstract interface class HealthWorkoutWriter {
  /// 成功時は外部 ID、失敗時は null（例外にしない）。
  ///
  /// Example:
  /// ```dart
  /// await writer.writeCycling(
  ///   start: DateTime.timestamp(),
  ///   end: DateTime.timestamp(),
  ///   distanceKm: 1,
  ///   duration: const Duration(minutes: 1),
  ///   caloriesKcal: 1,
  /// );
  /// ```
  Future<String?> writeCycling({
    required DateTime start,
    required DateTime end,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
  });

  /// [externalId] のサイクリングを更新する。成功時 true、失敗は false。
  ///
  /// Example:
  /// ```dart
  /// await writer.updateCycling(
  ///   externalId: 'health-1',
  ///   start: DateTime.timestamp(),
  ///   end: DateTime.timestamp(),
  ///   distanceKm: 1,
  ///   duration: const Duration(minutes: 1),
  ///   caloriesKcal: 1,
  /// );
  /// ```
  Future<bool> updateCycling({
    required String externalId,
    required DateTime start,
    required DateTime end,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
  });

  /// [externalId] のサイクリングを削除する。成功時 true、失敗は false。
  ///
  /// Example:
  /// ```dart
  /// await writer.deleteCycling(externalId: 'health-1');
  /// ```
  Future<bool> deleteCycling({required String externalId});
}

/// ヘルス書き込みの注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// healthWorkoutWriterProvider;
/// ```
final healthWorkoutWriterProvider = Provider<HealthWorkoutWriter>(
  (ref) => throw UnimplementedError('healthWorkoutWriterProvider'),
);
