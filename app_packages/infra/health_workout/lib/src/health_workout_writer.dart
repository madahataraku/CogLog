import 'package:riverpod/riverpod.dart';

/// ヘルスサービスへサイクリングを書く。
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
  /// 成功時 true。失敗は false（例外にしない）。
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
  Future<bool> writeCycling({
    required DateTime start,
    required DateTime end,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
  });
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
