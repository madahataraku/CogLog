import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:infra_meter_photo/infra_meter_photo.dart';

Uint8List _jpegWithExif({
  String? dateTimeOriginal,
  String? digitized,
  String? dateTime,
}) {
  final image = img.Image(width: 16, height: 16);
  img.fill(image, color: img.ColorRgb8(10, 20, 30));
  final exif = img.ExifData();
  if (dateTimeOriginal != null) {
    exif.exifIfd[0x9003] = dateTimeOriginal;
  }
  if (digitized != null) {
    exif.exifIfd[0x9004] = digitized;
  }
  if (dateTime != null) {
    exif.imageIfd[0x0132] = dateTime;
  }
  image.exif = exif;
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

void main() {
  final now = DateTime(2026, 11, 21, 12);

  test('DateTimeOriginal を優先する', () {
    final bytes = _jpegWithExif(
      dateTimeOriginal: '2024:05:18 12:33:21',
      digitized: '2023:01:01 00:00:00',
      dateTime: '2022:01:01 00:00:00',
    );
    expect(
      resolveMeterPhotoCapturedAt(bytes: bytes, now: now),
      DateTime(2024, 5, 18, 12, 33, 21),
    );
  });

  test('Original 無しなら Digitized', () {
    final bytes = _jpegWithExif(digitized: '2023:06:01 08:00:00');
    expect(
      resolveMeterPhotoCapturedAt(bytes: bytes, now: now),
      DateTime(2023, 6, 1, 8),
    );
  });

  test('EXIF 無しなら asset を使う', () {
    final bytes = _jpegWithExif();
    final asset = DateTime(2024, 3, 4, 5, 6, 7);
    expect(
      resolveMeterPhotoCapturedAt(
        bytes: bytes,
        assetCapturedOrCreatedAt: asset,
        now: now,
      ),
      asset,
    );
  });

  test('EXIF と asset 両方なら EXIF 優先', () {
    final bytes = _jpegWithExif(dateTimeOriginal: '2024:05:18 12:33:21');
    expect(
      resolveMeterPhotoCapturedAt(
        bytes: bytes,
        assetCapturedOrCreatedAt: DateTime(2020, 1, 1),
        now: now,
      ),
      DateTime(2024, 5, 18, 12, 33, 21),
    );
  });

  test('異常な EXIF は asset があっても null', () {
    final bytes = _jpegWithExif(dateTimeOriginal: '1990:01:01 00:00:00');
    expect(
      resolveMeterPhotoCapturedAt(
        bytes: bytes,
        assetCapturedOrCreatedAt: DateTime(2024, 3, 4),
        now: now,
      ),
      isNull,
    );
  });

  test('壊れたバイトは null', () {
    expect(
      resolveMeterPhotoCapturedAt(
        bytes: Uint8List.fromList([1, 2, 3]),
        now: now,
      ),
      isNull,
    );
  });

  test('未来の EXIF は null', () {
    final bytes = _jpegWithExif(dateTimeOriginal: '2026:11:25 00:00:00');
    expect(resolveMeterPhotoCapturedAt(bytes: bytes, now: now), isNull);
  });
}
