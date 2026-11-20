import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';

/// インポート用の 1 件。ID を維持し、写真は任意。
///
/// [photoBytes] が null のときは画像ファイルを作らない。
///
/// Example:
/// ```dart
/// ImportedExerciseHistoryEntry(
///   history: ExerciseHistory(
///     id: '11111111-1111-4111-8111-111111111111',
///     savedAt: DateTime.utc(2026, 11, 5),
///     creationStartedAt: DateTime.utc(2026, 11, 5),
///     capturedAt: DateTime.utc(2026, 11, 5),
///     recordedAt: DateTime.utc(2026, 11, 5),
///     recordedAtManuallySet: false,
///     distanceKm: 1,
///     duration: Duration(minutes: 1),
///     caloriesKcal: 1,
///     averageSpeedKmh: 1,
///     photoRelativePath:
///         'exercise_histories/11111111-1111-4111-8111-111111111111/meter.jpg',
///     healthWorkoutId: null,
///   ),
///   photoBytes: null,
/// );
/// ```
final class ImportedExerciseHistoryEntry {
  /// [history] と任意の [photoBytes] を組にする。
  ///
  /// Example:
  /// ```dart
  /// ImportedExerciseHistoryEntry(
  ///   history: ExerciseHistory(
  ///     id: '11111111-1111-4111-8111-111111111111',
  ///     savedAt: DateTime.utc(2026, 11, 5),
  ///     creationStartedAt: DateTime.utc(2026, 11, 5),
  ///     capturedAt: DateTime.utc(2026, 11, 5),
  ///     recordedAt: DateTime.utc(2026, 11, 5),
  ///     recordedAtManuallySet: false,
  ///     distanceKm: 1,
  ///     duration: Duration(minutes: 1),
  ///     caloriesKcal: 1,
  ///     averageSpeedKmh: 1,
  ///     photoRelativePath:
  ///         'exercise_histories/11111111-1111-4111-8111-111111111111/meter.jpg',
  ///     healthWorkoutId: null,
  ///   ),
  ///   photoBytes: Uint8List.fromList([1]),
  /// );
  /// ```
  const ImportedExerciseHistoryEntry({
    required this.history,
    required this.photoBytes,
  });

  /// 取り込む履歴。ヘルス ID は呼び出し側が null にする想定。
  final ExerciseHistory history;

  /// メーター写真。null ならファイル非作成。
  final Uint8List? photoBytes;
}
