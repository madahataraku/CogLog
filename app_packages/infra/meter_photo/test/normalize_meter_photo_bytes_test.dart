import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:infra_meter_photo/infra_meter_photo.dart';

Uint8List _jpeg({required int width, required int height, img.ExifData? exif}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(120, 80, 40));
  if (exif != null) {
    image.exif = exif;
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

bool _isJpeg(Uint8List bytes) =>
    bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8;

void main() {
  test('長辺 800 横長は長辺 600 以下の JPEG になりアスペクト比を維持する', () {
    final input = _jpeg(width: 800, height: 600);
    final out = normalizeMeterPhotoBytes(input);
    expect(_isJpeg(out), isTrue);
    final decoded = img.decodeImage(out)!;
    expect(math.max(decoded.width, decoded.height), lessThanOrEqualTo(600));
    expect(decoded.width / decoded.height, closeTo(800 / 600, 0.02));
  });

  test('長辺 800 縦長は長辺 600 以下の JPEG になりアスペクト比を維持する', () {
    final input = _jpeg(width: 600, height: 800);
    final out = normalizeMeterPhotoBytes(input);
    final decoded = img.decodeImage(out)!;
    expect(math.max(decoded.width, decoded.height), lessThanOrEqualTo(600));
    expect(decoded.height / decoded.width, closeTo(800 / 600, 0.02));
  });

  test('正方形 900 は長辺 600 以下の JPEG になる', () {
    final out = normalizeMeterPhotoBytes(_jpeg(width: 900, height: 900));
    final decoded = img.decodeImage(out)!;
    expect(math.max(decoded.width, decoded.height), lessThanOrEqualTo(600));
    expect(_isJpeg(out), isTrue);
  });

  test('長辺 601 は 600 以下になる', () {
    final out = normalizeMeterPhotoBytes(_jpeg(width: 601, height: 400));
    final decoded = img.decodeImage(out)!;
    expect(math.max(decoded.width, decoded.height), lessThanOrEqualTo(600));
  });

  test('長辺 600 以下は拡大せず JPEG になる', () {
    final input = _jpeg(width: 400, height: 300);
    final out = normalizeMeterPhotoBytes(input);
    final decoded = img.decodeImage(out)!;
    expect(decoded.width, lessThanOrEqualTo(400));
    expect(decoded.height, lessThanOrEqualTo(300));
    expect(_isJpeg(out), isTrue);
  });

  test('Orientation=6 の横長符号化は補正後長辺で縮小する', () {
    final exif = img.ExifData();
    exif.imageIfd.orientation = 6;
    final input = _jpeg(width: 800, height: 450, exif: exif);
    final out = normalizeMeterPhotoBytes(input);
    final decoded = img.decodeImage(out)!;
    expect(math.max(decoded.width, decoded.height), lessThanOrEqualTo(600));
    expect(_isJpeg(out), isTrue);
  });

  test('不正バイトは原寸を返す', () {
    final input = Uint8List.fromList([1, 2, 3]);
    final out = normalizeMeterPhotoBytes(input);
    expect(out, same(input));
  });
}
