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
  TestWidgetsFlutterBinding.ensureInitialized();

  test('長辺 800 横長は長辺 600 以下の JPEG になりアスペクト比を維持する', () async {
    final input = _jpeg(width: 800, height: 600);
    final out = await normalizeMeterPhotoBytes(input);
    expect(_isJpeg(out), isTrue);
    final decoded = img.decodeImage(out)!;
    expect(math.max(decoded.width, decoded.height), lessThanOrEqualTo(600));
    expect(decoded.width / decoded.height, closeTo(800 / 600, 0.02));
  });

  test('長辺 800 縦長は長辺 600 以下の JPEG になりアスペクト比を維持する', () async {
    final input = _jpeg(width: 600, height: 800);
    final out = await normalizeMeterPhotoBytes(input);
    final decoded = img.decodeImage(out)!;
    expect(math.max(decoded.width, decoded.height), lessThanOrEqualTo(600));
    expect(decoded.height / decoded.width, closeTo(800 / 600, 0.02));
  });

  test('正方形 900 は長辺 600 以下の JPEG になる', () async {
    final out = await normalizeMeterPhotoBytes(_jpeg(width: 900, height: 900));
    final decoded = img.decodeImage(out)!;
    expect(math.max(decoded.width, decoded.height), lessThanOrEqualTo(600));
    expect(_isJpeg(out), isTrue);
  });

  test('長辺 601 は 600 以下になる', () async {
    final out = await normalizeMeterPhotoBytes(_jpeg(width: 601, height: 400));
    final decoded = img.decodeImage(out)!;
    expect(math.max(decoded.width, decoded.height), lessThanOrEqualTo(600));
  });

  test('長辺 600 以下は拡大せず JPEG になる', () async {
    final input = _jpeg(width: 400, height: 300);
    final out = await normalizeMeterPhotoBytes(input);
    final decoded = img.decodeImage(out)!;
    expect(decoded.width, lessThanOrEqualTo(400));
    expect(decoded.height, lessThanOrEqualTo(300));
    expect(_isJpeg(out), isTrue);
  });

  test('Orientation=6 の横長符号化は補正後に幅 338・高さ 600 になる', () async {
    final image = img.Image(width: 800, height: 450);
    img.fill(image, color: img.ColorRgb8(128, 128, 128));
    // 左上を赤、右下を青にして回転方向を検証できるようにする。
    for (var y = 0; y < 40; y++) {
      for (var x = 0; x < 40; x++) {
        image.setPixelRgb(x, y, 255, 0, 0);
      }
    }
    for (var y = 410; y < 450; y++) {
      for (var x = 760; x < 800; x++) {
        image.setPixelRgb(x, y, 0, 0, 255);
      }
    }
    final exif = img.ExifData();
    exif.imageIfd.orientation = 6;
    image.exif = exif;
    final input = Uint8List.fromList(img.encodeJpg(image, quality: 95));

    final out = await normalizeMeterPhotoBytes(input);
    expect(_isJpeg(out), isTrue);
    final decoded = img.decodeImage(out)!;
    expect(decoded.width, equals(338));
    expect(decoded.height, equals(600));

    // Orientation=6 は 90° CW。符号化左上(赤)→表示右上、符号化右下(青)→表示左下。
    final topRight = decoded.getPixel(decoded.width - 8, 8);
    final bottomLeft = decoded.getPixel(8, decoded.height - 8);
    expect(topRight.r, greaterThan(topRight.b));
    expect(bottomLeft.b, greaterThan(bottomLeft.r));
  });

  test('不正バイトは原寸を返す', () async {
    final input = Uint8List.fromList([1, 2, 3]);
    final out = await normalizeMeterPhotoBytes(input);
    expect(out, same(input));
  });
}
