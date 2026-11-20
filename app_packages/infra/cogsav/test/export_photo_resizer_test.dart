import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:infra_cogsav/infra_cogsav.dart';
import 'package:test/test.dart';

Uint8List _jpeg({required int width, required int height}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(10, 20, 30));
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

void main() {
  test('長辺が 600 未満なら元バイトを返す', () {
    final original = _jpeg(width: 400, height: 300);
    final result = ExportPhotoResizer.resizeIfNeeded(original);
    expect(
      identical(result, original) || result.length == original.length,
      isTrue,
    );
    expect(result, original);
  });

  test('長辺が 600 以上なら長辺 600 に縮小する', () {
    final original = _jpeg(width: 1200, height: 800);
    final result = ExportPhotoResizer.resizeIfNeeded(original);
    final decoded = img.decodeImage(result)!;
    expect(decoded.width, 600);
    expect(decoded.height, 400);
    expect(result.length, lessThan(original.length));
  });

  test('縦長でも長辺 600 に縮小する', () {
    final original = _jpeg(width: 500, height: 1000);
    final result = ExportPhotoResizer.resizeIfNeeded(original);
    final decoded = img.decodeImage(result)!;
    expect(decoded.height, 600);
    expect(decoded.width, 300);
  });

  test('デコード不能なら元バイトを返す', () {
    final original = Uint8List.fromList([1, 2, 3, 4, 5]);
    expect(ExportPhotoResizer.resizeIfNeeded(original), original);
  });
}
