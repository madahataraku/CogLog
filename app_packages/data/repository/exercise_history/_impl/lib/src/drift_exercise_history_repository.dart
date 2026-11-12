import 'package:data_database/data_database.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'exercise_history_photo_store.dart';

/// Drift とローカル写真で運動履歴を永続化する。
///
/// Example:
/// ```dart
/// DriftExerciseHistoryRepository(
///   database: openMemoryDatabase(),
///   photos: ExerciseHistoryPhotoStore(Directory.systemTemp),
/// );
/// ```
final class DriftExerciseHistoryRepository
    implements ExerciseHistoryRepository {
  /// [database] と写真ストアで永続口を作る。
  ///
  /// Example:
  /// ```dart
  /// DriftExerciseHistoryRepository(
  ///   database: openMemoryDatabase(),
  ///   photos: ExerciseHistoryPhotoStore(Directory.systemTemp),
  /// );
  /// ```
  DriftExerciseHistoryRepository({
    required AppDatabase database,
    required this._photos,
    String Function()? newId,
  }) : _db = database,
       _newId = newId ?? const Uuid().v4;

  final AppDatabase _db;
  final ExerciseHistoryPhotoStore _photos;
  final String Function() _newId;

  /// 記録日時の降順、同値は ID 降順ですべて返す。
  @override
  Future<List<ExerciseHistory>> list() async {
    final rows =
        await (_db.select(_db.exerciseHistories)..orderBy([
              (t) => OrderingTerm.desc(t.recordedAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
            .get();
    return rows.map(_toDomain).toList();
  }

  /// 現地暦月で絞り、作成開始日時降順・ID 降順で頁を返す。
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
    final rows = await _db.select(_db.exerciseHistories).get();
    final matched = rows
        .map(_toDomain)
        .where((h) => window.contains(h.recordedAt))
        .toList();
    matched.sort((a, b) {
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
    final rows = await _db.select(_db.exerciseHistories).get();
    final matched = rows
        .map(_toDomain)
        .where((h) => window.contains(h.recordedAt))
        .toList();
    matched.sort((a, b) {
      final byCreated = b.creationStartedAt.compareTo(a.creationStartedAt);
      if (byCreated != 0) {
        return byCreated;
      }
      return b.id.compareTo(a.id);
    });
    return matched;
  }

  /// ID で 1 件返す。
  ///
  /// Example:
  /// ```dart
  /// repository.findById(id);
  /// ```
  @override
  Future<ExerciseHistory?> findById(String id) => _byId(id);

  /// 写真ファイルの絶対パス。無ければ null。
  ///
  /// Example:
  /// ```dart
  /// repository.photoAbsolutePath(id);
  /// ```
  @override
  Future<String?> photoAbsolutePath(String id) async {
    final file = _photos.fileFor(id);
    if (!await file.exists()) {
      return null;
    }
    return file.path;
  }

  /// 写真を書いてから行を挿入する。INSERT 失敗時は写真を削除する。
  ///
  /// ID が既存行と衝突する場合は、写真を書かずに失敗する。
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
  }) async {
    if (duration.inSeconds == 0) {
      throw ArgumentError.value(duration, 'duration', '0 では保存できない');
    }
    final id = _newId();
    if (await _byId(id) != null) {
      throw StateError('運動履歴が既に有る: $id');
    }
    final savedAt = DateTime.timestamp();
    var wrotePhoto = false;
    try {
      final relative = await _photos.write(id, photoBytes);
      wrotePhoto = true;
      await _db
          .into(_db.exerciseHistories)
          .insert(
            ExerciseHistoriesCompanion.insert(
              id: id,
              savedAt: encodeUtc(savedAt),
              creationStartedAt: encodeUtc(creationStartedAt),
              capturedAt: encodeUtc(capturedAt),
              recordedAt: encodeUtc(recordedAt),
              recordedAtManuallySet: recordedAtManuallySet,
              distanceKm: distanceKm,
              durationMs: duration.inMilliseconds,
              caloriesKcal: caloriesKcal,
              averageSpeedKmh: averageSpeedKmh,
              photoRelativePath: relative,
              healthWorkoutId: Value(healthWorkoutId),
            ),
          );
    } catch (error, stack) {
      if (wrotePhoto) {
        try {
          await _photos.deleteFor(id);
        } catch (_) {
          // 元の例外を優先する。
        }
      }
      Error.throwWithStackTrace(error, stack);
    }
    return (await _byId(id))!;
  }

  /// [savedAt] と [healthWorkoutId] は変えず更新する。未知 ID は [StateError]。
  ///
  /// 写真があるときはステージングへ書き、行更新と確定を同一トランザクションで行う。
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
    Uint8List? photoBytes,
  }) async {
    if (duration.inSeconds == 0) {
      throw ArgumentError.value(duration, 'duration', '0 では保存できない');
    }
    final existing = await _byId(id);
    if (existing == null) {
      throw StateError('運動履歴が無い: $id');
    }
    final replacePhoto = photoBytes != null;
    try {
      if (replacePhoto) {
        await _photos.writeStaging(id, photoBytes);
      }
      await _db.transaction(() async {
        final updated =
            await (_db.update(
              _db.exerciseHistories,
            )..where((t) => t.id.equals(id))).write(
              ExerciseHistoriesCompanion(
                creationStartedAt: Value(encodeUtc(creationStartedAt)),
                capturedAt: Value(encodeUtc(capturedAt)),
                recordedAt: Value(encodeUtc(recordedAt)),
                recordedAtManuallySet: Value(recordedAtManuallySet),
                distanceKm: Value(distanceKm),
                durationMs: Value(duration.inMilliseconds),
                caloriesKcal: Value(caloriesKcal),
                averageSpeedKmh: Value(averageSpeedKmh),
                photoRelativePath: Value(existing.photoRelativePath),
              ),
            );
        if (updated == 0) {
          throw StateError('運動履歴が無い: $id');
        }
        if (replacePhoto) {
          await _photos.commitStaging(id);
        }
      });
    } catch (error, stack) {
      if (replacePhoto) {
        try {
          await _photos.discardStaging(id);
        } catch (_) {
          // 元の例外を優先する。
        }
      }
      Error.throwWithStackTrace(error, stack);
    }
    return (await _byId(id))!;
  }

  /// [healthWorkoutId] だけを付け替える。未知 ID は [StateError]。
  ///
  /// Example:
  /// ```dart
  /// repository.attachHealthWorkoutId(
  ///   id: id,
  ///   healthWorkoutId: 'health-1',
  /// );
  /// ```
  @override
  Future<ExerciseHistory> attachHealthWorkoutId({
    required String id,
    required String healthWorkoutId,
  }) async {
    // UPDATE と結果取得を同一トランザクションにし、途中失敗時は ID 付与を残さない。
    return _db.transaction(() async {
      final existing = await _byId(id);
      if (existing == null) {
        throw StateError('運動履歴が無い: $id');
      }
      final updated =
          await (_db.update(
            _db.exerciseHistories,
          )..where((t) => t.id.equals(id))).write(
            ExerciseHistoriesCompanion(
              healthWorkoutId: Value(healthWorkoutId),
            ),
          );
      if (updated == 0) {
        throw StateError('運動履歴が無い: $id');
      }
      return (await _byId(id))!;
    });
  }

  /// 写真を消してから行を削除する。未知 ID は [StateError]。
  @override
  Future<void> delete(String id) async {
    final existing = await _byId(id);
    if (existing == null) {
      throw StateError('運動履歴が無い: $id');
    }
    await _photos.deleteFor(id);
    await (_db.delete(
      _db.exerciseHistories,
    )..where((t) => t.id.equals(id))).go();
  }

  Future<ExerciseHistory?> _byId(String id) async {
    final row = await (_db.select(
      _db.exerciseHistories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  ExerciseHistory _toDomain(ExerciseHistoryRow row) => ExerciseHistory(
    id: row.id,
    savedAt: decodeUtc(row.savedAt),
    creationStartedAt: decodeUtc(row.creationStartedAt),
    capturedAt: decodeUtc(row.capturedAt),
    recordedAt: decodeUtc(row.recordedAt),
    recordedAtManuallySet: row.recordedAtManuallySet,
    distanceKm: row.distanceKm,
    duration: Duration(milliseconds: row.durationMs),
    caloriesKcal: row.caloriesKcal,
    averageSpeedKmh: row.averageSpeedKmh,
    photoRelativePath: row.photoRelativePath,
    healthWorkoutId: row.healthWorkoutId,
  );
}
