import 'dart:io';

import 'package:data_repository_app_review_impl/data_repository_app_review_impl.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;
  late CacheFileAppReviewSuppressionRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('app_review_');
    repository = CacheFileAppReviewSuppressionRepository(dir);
  });

  tearDown(() async {
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  });

  test('初期は未抑止', () async {
    expect(await repository.isSuppressed(), isFalse);
  });

  test('markSuppressed 後は抑止済み', () async {
    await repository.markSuppressed();
    expect(await repository.isSuppressed(), isTrue);
    expect(
      File('${dir.path}/${CacheFileAppReviewSuppressionRepository.fileName}')
          .existsSync(),
      isTrue,
    );
  });
}
