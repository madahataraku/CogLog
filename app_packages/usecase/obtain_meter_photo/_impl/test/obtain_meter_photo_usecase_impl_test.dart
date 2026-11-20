import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:infra_meter_photo/infra_meter_photo.dart'
    hide MeterPhotoPermissionKind;
import 'package:infra_meter_photo_testing/infra_meter_photo_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_obtain_meter_photo_impl/usecase_obtain_meter_photo_impl.dart';

void main() {
  test('カメラ成功で bytes と capturedAt を返す', () async {
    // 非画像バイトは正規化失敗のため原寸のまま Success になる。
    final capturedAt = DateTime.utc(2026, 11, 8, 12);
    final source = FakeMeterPhotoSource(
      cameraCapture: MeterPhotoCapture(
        bytes: Uint8List.fromList([1, 2]),
        capturedAt: capturedAt,
      ),
    );

    final result = await ObtainMeterPhotoUsecaseImpl(source: source).execute(
      const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.camera),
    );

    expect(result, isA<ObtainMeterPhotoSuccess>());
    final success = result as ObtainMeterPhotoSuccess;
    expect(success.bytes, Uint8List.fromList([1, 2]));
    expect(success.capturedAt, capturedAt);
    expect(source.captureCallCount, 1);
    expect(source.pickCallCount, 0);
  });

  test('ライブラリ成功で bytes を返す', () async {
    // 非画像バイトは正規化失敗のため原寸のまま Success になる。
    final source = FakeMeterPhotoSource(
      libraryCapture: MeterPhotoCapture(bytes: Uint8List.fromList([9])),
    );

    final result = await ObtainMeterPhotoUsecaseImpl(source: source).execute(
      const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.library),
    );

    expect(result, isA<ObtainMeterPhotoSuccess>());
    expect((result as ObtainMeterPhotoSuccess).bytes, Uint8List.fromList([9]));
    expect(source.pickCallCount, 1);
    expect(source.captureCallCount, 0);
  });

  test('キャンセルは Cancelled', () async {
    final source = FakeMeterPhotoSource();

    final result = await ObtainMeterPhotoUsecaseImpl(source: source).execute(
      const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.camera),
    );

    expect(result, isA<ObtainMeterPhotoCancelled>());
  });

  test('カメラ権限拒否は PermissionDenied(camera)', () async {
    final source = FakeMeterPhotoSource(throwPermissionOnCamera: true);

    final result = await ObtainMeterPhotoUsecaseImpl(source: source).execute(
      const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.camera),
    );

    expect(result, isA<ObtainMeterPhotoPermissionDenied>());
    expect(
      (result as ObtainMeterPhotoPermissionDenied).kind,
      MeterPhotoPermissionKind.camera,
    );
  });

  test('ライブラリ権限拒否は PermissionDenied(library)', () async {
    final source = FakeMeterPhotoSource(throwPermissionOnLibrary: true);

    final result = await ObtainMeterPhotoUsecaseImpl(source: source).execute(
      const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.library),
    );

    expect(result, isA<ObtainMeterPhotoPermissionDenied>());
    expect(
      (result as ObtainMeterPhotoPermissionDenied).kind,
      MeterPhotoPermissionKind.library,
    );
  });

  test('長辺 800 の JPEG は正規化後に長辺 600 以下で Success になる', () async {
    final raw = img.Image(width: 800, height: 600);
    img.fill(raw, color: img.ColorRgb8(10, 20, 30));
    final jpeg = Uint8List.fromList(img.encodeJpg(raw, quality: 90));
    final source = FakeMeterPhotoSource(
      cameraCapture: MeterPhotoCapture(bytes: jpeg),
    );

    final result = await ObtainMeterPhotoUsecaseImpl(source: source).execute(
      const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.camera),
    );

    final success = result as ObtainMeterPhotoSuccess;
    expect(success.bytes[0], 0xFF);
    expect(success.bytes[1], 0xD8);
    final decoded = img.decodeImage(success.bytes)!;
    expect(math.max(decoded.width, decoded.height), lessThanOrEqualTo(600));
  });
}
