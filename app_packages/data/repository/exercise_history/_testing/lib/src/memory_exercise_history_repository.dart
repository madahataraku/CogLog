import 'dart:io';
import 'dart:typed_data';

import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:uuid/uuid.dart';

/// メモリ上で CUD 契約を再現するテスト用 Repository。
///
/// Example:
/// ```dart
/// MemoryExerciseHistoryRepository().list();
/// ```
final class MemoryExerciseHistoryRepository
    implements ExerciseHistoryRepository {
  /// [uuid] を差し替えられる口を作る。
  ///
  /// Example:
  /// ```dart
  /// MemoryExerciseHistoryRepository();
  /// ```
  MemoryExerciseHistoryRepository({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  final List<ExerciseHistory> _items = [];
  final Map<String, Uint8List> _photos = {};

  /// 記録日時の降順で返す。
  @override
  Future<List<ExerciseHistory>> list() async {
    final copy = [..._items];
    copy.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return copy;
  }

  /// 現地暦月で絞り、作成開始日時降順で頁を返す。
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
    final matched = _items.where((h) => window.contains(h.recordedAt)).toList()
      ..sort((a, b) {
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
    return _items.where((h) => window.contains(h.recordedAt)).toList()
      ..sort((a, b) {
        final byCreated = b.creationStartedAt.compareTo(a.creationStartedAt);
        if (byCreated != 0) {
          return byCreated;
        }
        return b.id.compareTo(a.id);
      });
  }

  /// ID で 1 件返す。
  ///
  /// Example:
  /// ```dart
  /// repository.findById(id);
  /// ```
  @override
  Future<ExerciseHistory?> findById(String id) async {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  /// 保持バイトがあれば一時ファイルへ書いて絶対パスを返す。
  ///
  /// Example:
  /// ```dart
  /// repository.photoAbsolutePath(id);
  /// ```
  @override
  Future<String?> photoAbsolutePath(String id) async {
    final bytes = _photos[id];
    if (bytes == null) {
      return null;
    }
    final file = File(
      '${Directory.systemTemp.path}/coglog_memory_photos/$id.jpg',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// 新規作成する。運動時間 0 は [ArgumentError]。
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
    final id = _uuid.v4();
    final savedAt = DateTime.timestamp();
    final path = 'exercise_histories/$id/meter.jpg';
    _photos[id] = Uint8List.fromList(photoBytes);
    final item = ExerciseHistory(
      id: id,
      savedAt: savedAt,
      creationStartedAt: creationStartedAt.toUtc(),
      capturedAt: capturedAt.toUtc(),
      recordedAt: recordedAt.toUtc(),
      recordedAtManuallySet: recordedAtManuallySet,
      distanceKm: distanceKm,
      duration: duration,
      caloriesKcal: caloriesKcal,
      averageSpeedKmh: averageSpeedKmh,
      photoRelativePath: path,
      healthWorkoutId: healthWorkoutId,
    );
    _items.add(item);
    return item;
  }

  /// 更新する。未知 ID は [StateError]。[healthWorkoutId] は維持する。
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
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) {
      throw StateError('運動履歴が無い: $id');
    }
    final previous = _items[index];
    if (photoBytes != null) {
      _photos[id] = Uint8List.fromList(photoBytes);
    }
    final next = ExerciseHistory(
      id: id,
      savedAt: previous.savedAt,
      creationStartedAt: creationStartedAt.toUtc(),
      capturedAt: capturedAt.toUtc(),
      recordedAt: recordedAt.toUtc(),
      recordedAtManuallySet: recordedAtManuallySet,
      distanceKm: distanceKm,
      duration: duration,
      caloriesKcal: caloriesKcal,
      averageSpeedKmh: averageSpeedKmh,
      photoRelativePath: previous.photoRelativePath,
      healthWorkoutId: previous.healthWorkoutId,
    );
    _items[index] = next;
    return next;
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
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) {
      throw StateError('運動履歴が無い: $id');
    }
    final previous = _items[index];
    final next = ExerciseHistory(
      id: id,
      savedAt: previous.savedAt,
      creationStartedAt: previous.creationStartedAt,
      capturedAt: previous.capturedAt,
      recordedAt: previous.recordedAt,
      recordedAtManuallySet: previous.recordedAtManuallySet,
      distanceKm: previous.distanceKm,
      duration: previous.duration,
      caloriesKcal: previous.caloriesKcal,
      averageSpeedKmh: previous.averageSpeedKmh,
      photoRelativePath: previous.photoRelativePath,
      healthWorkoutId: healthWorkoutId,
    );
    _items[index] = next;
    return next;
  }

  /// 削除する。未知 ID は [StateError]。
  @override
  Future<void> delete(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) {
      throw StateError('運動履歴が無い: $id');
    }
    _items.removeAt(index);
    _photos.remove(id);
  }
}
