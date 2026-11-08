import 'dart:io';
import 'dart:typed_data';

import 'package:data_database/data_database.dart';
import 'package:data_repository_exercise_history_impl/data_repository_exercise_history_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory docs;
  late AppDatabase db;
  late DriftExerciseHistoryRepository repo;

  setUp(() {
    docs = Directory.systemTemp.createTempSync('eh_');
    db = openMemoryDatabase();
    repo = DriftExerciseHistoryRepository(
      database: db,
      photos: ExerciseHistoryPhotoStore(docs),
    );
  });

  tearDown(() async {
    await db.close();
    if (docs.existsSync()) {
      docs.deleteSync(recursive: true);
    }
  });

  test('0件のとき list は空', () async {
    expect(await repo.list(), isEmpty);
  });

  test('create 後 list で同値が得られ写真ファイルが存在する', () async {
    final created = await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5, 1),
      recordedAt: DateTime.utc(2026, 11, 5, 2),
      recordedAtManuallySet: false,
      distanceKm: 1.5,
      duration: const Duration(minutes: 20),
      caloriesKcal: 80,
      averageSpeedKmh: 4.5,
      photoBytes: Uint8List.fromList([1, 2, 3]),
    );

    final listed = await repo.list();
    expect(listed, hasLength(1));
    expect(listed.single.id, created.id);
    expect(listed.single.distanceKm, 1.5);
    expect(listed.single.savedAt.isUtc, isTrue);
    expect(
      File('${docs.path}/${created.photoRelativePath}').existsSync(),
      isTrue,
    );
  });

  test('複数 create で list は recordedAt 降順', () async {
    await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5),
      recordedAt: DateTime.utc(2026, 11, 5, 10),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([1]),
    );
    await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5),
      recordedAt: DateTime.utc(2026, 11, 5, 12),
      recordedAtManuallySet: false,
      distanceKm: 2,
      duration: const Duration(minutes: 2),
      caloriesKcal: 2,
      averageSpeedKmh: 2,
      photoBytes: Uint8List.fromList([2]),
    );

    final listed = await repo.list();
    expect(listed, hasLength(2));
    expect(listed.first.recordedAt, DateTime.utc(2026, 11, 5, 12));
    expect(listed.last.recordedAt, DateTime.utc(2026, 11, 5, 10));
  });

  test('update 後 savedAt は変わらず他項目は変わる', () async {
    final created = await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5),
      recordedAt: DateTime.utc(2026, 11, 5),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([1]),
    );

    final updated = await repo.update(
      id: created.id,
      creationStartedAt: DateTime.utc(2026, 11, 6),
      capturedAt: DateTime.utc(2026, 11, 6),
      recordedAt: DateTime.utc(2026, 11, 6),
      recordedAtManuallySet: true,
      distanceKm: 9,
      duration: const Duration(minutes: 9),
      caloriesKcal: 9,
      averageSpeedKmh: 9,
    );

    expect(updated.savedAt, created.savedAt);
    expect(updated.distanceKm, 9);
    expect(updated.recordedAtManuallySet, isTrue);
  });

  test('update で写真置換するとファイル内容が新 bytes', () async {
    final created = await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5),
      recordedAt: DateTime.utc(2026, 11, 5),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([1, 1, 1]),
    );

    await repo.update(
      id: created.id,
      creationStartedAt: created.creationStartedAt,
      capturedAt: created.capturedAt,
      recordedAt: created.recordedAt,
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([9, 9, 9]),
    );

    final bytes = await File('${docs.path}/${created.photoRelativePath}')
        .readAsBytes();
    expect(bytes, [9, 9, 9]);
  });

  test('delete 後 list 空かつ写真ディレクトリ不存在', () async {
    final created = await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5),
      recordedAt: DateTime.utc(2026, 11, 5),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([1]),
    );

    await repo.delete(created.id);

    expect(await repo.list(), isEmpty);
    expect(
      Directory('${docs.path}/exercise_histories/${created.id}').existsSync(),
      isFalse,
    );
  });

  test('duration 0 の create は ArgumentError', () async {
    expect(
      () => repo.create(
        creationStartedAt: DateTime.utc(2026, 11, 5),
        capturedAt: DateTime.utc(2026, 11, 5),
        recordedAt: DateTime.utc(2026, 11, 5),
        recordedAtManuallySet: false,
        distanceKm: 1,
        duration: Duration.zero,
        caloriesKcal: 1,
        averageSpeedKmh: 1,
        photoBytes: Uint8List.fromList([1]),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('未知 id の update/delete は StateError', () async {
    const missing = '33333333-3333-4333-8333-333333333333';
    expect(
      () => repo.update(
        id: missing,
        creationStartedAt: DateTime.utc(2026, 11, 5),
        capturedAt: DateTime.utc(2026, 11, 5),
        recordedAt: DateTime.utc(2026, 11, 5),
        recordedAtManuallySet: false,
        distanceKm: 1,
        duration: const Duration(minutes: 1),
        caloriesKcal: 1,
        averageSpeedKmh: 1,
      ),
      throwsA(isA<StateError>()),
    );
    expect(() => repo.delete(missing), throwsA(isA<StateError>()));
  });

  test('写真 write 後 deleteFor でディレクトリが消える', () async {
    const id = '22222222-2222-4222-8222-222222222222';
    final store = ExerciseHistoryPhotoStore(docs);
    await store.write(id, Uint8List.fromList([9]));
    expect(
      Directory('${docs.path}/exercise_histories/$id').existsSync(),
      isTrue,
    );
    await store.deleteFor(id);
    expect(
      Directory('${docs.path}/exercise_histories/$id').existsSync(),
      isFalse,
    );
  });

  test('同じ ID の create 再実行は失敗し既存写真を残す', () async {
    const id = '44444444-4444-4444-8444-444444444444';
    final fixed = DriftExerciseHistoryRepository(
      database: db,
      photos: ExerciseHistoryPhotoStore(docs),
      newId: () => id,
    );
    await fixed.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5),
      recordedAt: DateTime.utc(2026, 11, 5),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([1, 1, 1]),
    );

    await expectLater(
      () => fixed.create(
        creationStartedAt: DateTime.utc(2026, 11, 5),
        capturedAt: DateTime.utc(2026, 11, 5),
        recordedAt: DateTime.utc(2026, 11, 5),
        recordedAtManuallySet: false,
        distanceKm: 2,
        duration: const Duration(minutes: 2),
        caloriesKcal: 2,
        averageSpeedKmh: 2,
        photoBytes: Uint8List.fromList([2]),
      ),
      throwsA(isA<StateError>()),
    );
    expect(await fixed.list(), hasLength(1));
    final bytes = await File(
      '${docs.path}/exercise_histories/$id/meter.jpg',
    ).readAsBytes();
    expect(bytes, [1, 1, 1]);
  });

  test('update で photoBytes 省略時は既存写真が変わらない', () async {
    final created = await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5),
      recordedAt: DateTime.utc(2026, 11, 5),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([4, 5, 6]),
    );

    await repo.update(
      id: created.id,
      creationStartedAt: created.creationStartedAt,
      capturedAt: created.capturedAt,
      recordedAt: created.recordedAt,
      recordedAtManuallySet: true,
      distanceKm: 3,
      duration: const Duration(minutes: 3),
      caloriesKcal: 3,
      averageSpeedKmh: 3,
    );

    final bytes = await File('${docs.path}/${created.photoRelativePath}')
        .readAsBytes();
    expect(bytes, [4, 5, 6]);
  });

  test('1秒未満の duration は ArgumentError', () async {
    expect(
      () => repo.create(
        creationStartedAt: DateTime.utc(2026, 11, 5),
        capturedAt: DateTime.utc(2026, 11, 5),
        recordedAt: DateTime.utc(2026, 11, 5),
        recordedAtManuallySet: false,
        distanceKm: 1,
        duration: const Duration(milliseconds: 500),
        caloriesKcal: 1,
        averageSpeedKmh: 1,
        photoBytes: Uint8List.fromList([1]),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('update で 0 秒の duration は ArgumentError', () async {
    final created = await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5),
      recordedAt: DateTime.utc(2026, 11, 5),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([1]),
    );

    for (final duration in const [
      Duration.zero,
      Duration(milliseconds: 500),
    ]) {
      expect(
        () => repo.update(
          id: created.id,
          creationStartedAt: created.creationStartedAt,
          capturedAt: created.capturedAt,
          recordedAt: created.recordedAt,
          recordedAtManuallySet: false,
          distanceKm: 2,
          duration: duration,
          caloriesKcal: 2,
          averageSpeedKmh: 2,
        ),
        throwsA(isA<ArgumentError>()),
      );
    }
  });

  test('commitStaging 失敗時は行が旧値のまま残る', () async {
    final photos = _ThrowingCommitPhotoStore(docs);
    final failing = DriftExerciseHistoryRepository(
      database: db,
      photos: photos,
    );
    final created = await failing.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5),
      recordedAt: DateTime.utc(2026, 11, 5),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([1, 2, 3]),
    );

    await expectLater(
      () => failing.update(
        id: created.id,
        creationStartedAt: created.creationStartedAt,
        capturedAt: created.capturedAt,
        recordedAt: created.recordedAt,
        recordedAtManuallySet: true,
        distanceKm: 9,
        duration: const Duration(minutes: 9),
        caloriesKcal: 9,
        averageSpeedKmh: 9,
        photoBytes: Uint8List.fromList([9, 9, 9]),
      ),
      throwsA(isA<StateError>()),
    );

    final listed = await failing.list();
    expect(listed, hasLength(1));
    expect(listed.single.distanceKm, 1);
    expect(listed.single.caloriesKcal, 1);
    expect(
      await File('${docs.path}/${created.photoRelativePath}').readAsBytes(),
      [1, 2, 3],
    );
  });

  test('writeStaging の rename 失敗時に .tmp が残らない', () async {
    const id = '55555555-5555-4555-8555-555555555555';
    final store = ExerciseHistoryPhotoStore(docs);
    final idPath = Directory('${docs.path}/exercise_histories/$id');
    // rename 先をディレクトリにして、.tmp 書き込み後に rename を失敗させる。
    await Directory('${idPath.path}/meter.jpg.staging').create(recursive: true);

    await expectLater(
      () => store.writeStaging(id, Uint8List.fromList([2])),
      throwsA(isA<FileSystemException>()),
    );
    expect(File('${idPath.path}/meter.jpg.staging.tmp').existsSync(), isFalse);
  });
}

/// `commitStaging` を常に [StateError] で失敗させる写真ストア。
///
/// 行更新後の確定失敗でトランザクションが戻ることを検証するために使う。
final class _ThrowingCommitPhotoStore extends ExerciseHistoryPhotoStore {
  /// [documentsRoot] を親クラスへ渡す。
  _ThrowingCommitPhotoStore(super.documentsRoot);

  @override
  Future<void> commitStaging(String id) async {
    throw StateError('ステージング確定に失敗: $id');
  }
}

  test('listPage は現地暦月で絞り作成開始日時降順', () async {
    final older = await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 1, 8),
      capturedAt: DateTime.utc(2026, 11, 1, 8),
      recordedAt: DateTime.utc(2026, 11, 10, 12),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([1]),
    );
    final newer = await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 2, 8),
      capturedAt: DateTime.utc(2026, 11, 2, 8),
      recordedAt: DateTime.utc(2026, 11, 20, 12),
      recordedAtManuallySet: false,
      distanceKm: 2,
      duration: const Duration(minutes: 2),
      caloriesKcal: 2,
      averageSpeedKmh: 2,
      photoBytes: Uint8List.fromList([2]),
    );
    await repo.create(
      creationStartedAt: DateTime.utc(2026, 10, 1, 8),
      capturedAt: DateTime.utc(2026, 10, 1, 8),
      recordedAt: DateTime.utc(2026, 10, 15, 12),
      recordedAtManuallySet: false,
      distanceKm: 3,
      duration: const Duration(minutes: 3),
      caloriesKcal: 3,
      averageSpeedKmh: 3,
      photoBytes: Uint8List.fromList([3]),
    );

    final page = await repo.listPage(
      year: 2026,
      month: 11,
      offset: 0,
      limit: 30,
    );
    expect(page.map((e) => e.id), [newer.id, older.id]);
  });

  test('listPage の offset/limit と findById / photoAbsolutePath', () async {
    late String firstId;
    for (var i = 0; i < 3; i++) {
      final created = await repo.create(
        creationStartedAt: DateTime.utc(2026, 11, 1 + i),
        capturedAt: DateTime.utc(2026, 11, 1 + i),
        recordedAt: DateTime.utc(2026, 11, 5),
        recordedAtManuallySet: false,
        distanceKm: 1,
        duration: const Duration(minutes: 1),
        caloriesKcal: 1,
        averageSpeedKmh: 1,
        photoBytes: Uint8List.fromList([i]),
      );
      if (i == 2) {
        firstId = created.id;
      }
    }

    final page = await repo.listPage(
      year: 2026,
      month: 11,
      offset: 0,
      limit: 2,
    );
    expect(page, hasLength(2));
    final next = await repo.listPage(
      year: 2026,
      month: 11,
      offset: 2,
      limit: 2,
    );
    expect(next, hasLength(1));

    expect((await repo.findById(firstId))?.id, firstId);
    expect(await repo.findById('00000000-0000-4000-8000-000000000000'), isNull);

    final path = await repo.photoAbsolutePath(firstId);
    expect(path, isNotNull);
    expect(File(path!).existsSync(), isTrue);
  });
