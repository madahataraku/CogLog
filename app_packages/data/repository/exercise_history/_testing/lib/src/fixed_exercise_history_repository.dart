import 'dart:typed_data';

import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';

/// コンストラクタで受け取った履歴を返す読み取り専用の口。
///
/// Example:
/// ```dart
/// FixedExerciseHistoryRepository(const []).list();
/// ```
final class FixedExerciseHistoryRepository
    implements ExerciseHistoryRepository {
  /// [histories] をそのまま返す読み出し口を作る。
  ///
  /// Example:
  /// ```dart
  /// FixedExerciseHistoryRepository(const []);
  /// ```
  const FixedExerciseHistoryRepository(this.histories);

  /// テストが用意した履歴。
  final List<ExerciseHistory> histories;

  /// [histories] を返す。
  ///
  /// Example:
  /// ```dart
  /// FixedExerciseHistoryRepository(const []).list();
  /// ```
  @override
  Future<List<ExerciseHistory>> list() async => histories;

  /// 現地暦月で絞った頁を返す。
  ///
  /// Example:
  /// ```dart
  /// repository.listPage(year: 2026, month: 11, offset: 0, limit: 30);
  /// ```
  @override
  Future<List<ExerciseHistory>> listPage({
    required int year,
    required int month,
    required int offset,
    required int limit,
  }) async {
    final window = PeriodWindow.month(DateTime(year, month));
    final matched =
        histories.where((h) => window.contains(h.recordedAt)).toList()..sort((
          a,
          b,
        ) {
          final byCreated = b.creationStartedAt.compareTo(a.creationStartedAt);
          if (byCreated != 0) {
            return byCreated;
          }
          return b.id.compareTo(a.id);
        });
    if (offset >= matched.length) {
      return const [];
    }
    final end = (offset + limit).clamp(0, matched.length);
    return matched.sublist(offset, end);
  }

  /// 現地暦月の全件を作成開始日時の降順で返す。
  ///
  /// Example:
  /// ```dart
  /// repository.listByMonth(year: 2026, month: 11);
  /// ```
  @override
  Future<List<ExerciseHistory>> listByMonth({
    required int year,
    required int month,
  }) async {
    final window = PeriodWindow.month(DateTime(year, month));
    return histories.where((h) => window.contains(h.recordedAt)).toList()
      ..sort((a, b) {
        final byCreated = b.creationStartedAt.compareTo(a.creationStartedAt);
        if (byCreated != 0) {
          return byCreated;
        }
        return b.id.compareTo(a.id);
      });
  }

  /// [histories] から ID で探す。
  ///
  /// Example:
  /// ```dart
  /// repository.findById(id);
  /// ```
  @override
  Future<ExerciseHistory?> findById(String id) async {
    for (final item in histories) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  /// 実ファイルを持たないため常に null。
  ///
  /// Example:
  /// ```dart
  /// repository.photoAbsolutePath(id);
  /// ```
  @override
  Future<String?> photoAbsolutePath(String id) async => null;

  /// 読み取り専用のため常に失敗する。
  ///
  /// Example:
  /// ```dart
  /// FixedExerciseHistoryRepository(const []).create(
  ///   creationStartedAt: DateTime.timestamp(),
  ///   capturedAt: DateTime.timestamp(),
  ///   recordedAt: DateTime.timestamp(),
  ///   recordedAtManuallySet: false,
  ///   distanceKm: 1,
  ///   duration: Duration(minutes: 1),
  ///   caloriesKcal: 1,
  ///   averageSpeedKmh: 1,
  ///   healthWorkoutId: null,
  ///   photoBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<ExerciseHistory> create({
    required DateTime creationStartedAt,
    required DateTime capturedAt,
    required DateTime recordedAt,
    required bool recordedAtManuallySet,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
    required double averageSpeedKmh,
    required String? healthWorkoutId,
    required Uint8List photoBytes,
  }) async => throw UnsupportedError('FixedExerciseHistoryRepository は読み取り専用');

  /// 読み取り専用のため常に失敗する。
  @override
  Future<ExerciseHistory> update({
    required String id,
    required DateTime creationStartedAt,
    required DateTime capturedAt,
    required DateTime recordedAt,
    required bool recordedAtManuallySet,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
    required double averageSpeedKmh,
    required String? healthWorkoutId,
    Uint8List? photoBytes,
  }) async => throw UnsupportedError('FixedExerciseHistoryRepository は読み取り専用');

  /// 読み取り専用のため常に失敗する。
  @override
  Future<void> delete(String id) async =>
      throw UnsupportedError('FixedExerciseHistoryRepository は読み取り専用');
}
