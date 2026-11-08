import 'dart:typed_data';

import 'package:infra_meter_photo/infra_meter_photo.dart';
import 'package:infra_meter_photo_testing/infra_meter_photo_testing.dart';
import 'package:test/test.dart';

void main() {
  test('カメラ成功時に capture を返す', () async {
    final capture = MeterPhotoCapture(bytes: Uint8List.fromList([1, 2]));
    final source = FakeMeterPhotoSource(cameraCapture: capture);

    expect(await source.captureWithCamera(), same(capture));
    expect(source.captureCallCount, 1);
  });

  test('ライブラリキャンセルは null', () async {
    final source = FakeMeterPhotoSource();

    expect(await source.pickFromLibrary(), isNull);
    expect(source.pickCallCount, 1);
  });

  test('カメラ権限拒否は例外', () async {
    final source = FakeMeterPhotoSource(throwPermissionOnCamera: true);

    await expectLater(
      source.captureWithCamera(),
      throwsA(
        isA<MeterPhotoPermissionDeniedException>().having(
          (e) => e.kind,
          'kind',
          MeterPhotoPermissionKind.camera,
        ),
      ),
    );
  });
}
