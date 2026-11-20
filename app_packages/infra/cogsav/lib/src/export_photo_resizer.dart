import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// エクスポート用にメーター写真を必要なら縮小する。
///
/// Example:
/// ```dart
/// ExportPhotoResizer.resizeIfNeeded(Uint8List.fromList([1, 2, 3]));
/// ```
abstract final class ExportPhotoResizer {
  /// 長辺の上限。これ以上なら長辺をこの値に合わせる。
  static const int maxLongSide = 600;

  /// JPEG 品質。
  static const int jpegQuality = 85;

  /// 長辺が [maxLongSide] 以上なら縮小した JPEG を返す。
  ///
  /// デコード不能なら元バイトをそのまま返す。元画像ファイルは触らない。
  ///
  /// Example:
  /// ```dart
  /// ExportPhotoResizer.resizeIfNeeded(Uint8List.fromList([1]));
  /// ```
  static Uint8List resizeIfNeeded(Uint8List jpegOrBytes) {
    final img.Image? decoded;
    try {
      decoded = img.decodeImage(jpegOrBytes);
    } on Object {
      // デコーダが例外を投げる入力も「デコード不能」として元バイトを返す。
      return jpegOrBytes;
    }
    if (decoded == null) {
      return jpegOrBytes;
    }
    final longSide = decoded.width > decoded.height
        ? decoded.width
        : decoded.height;
    if (longSide < maxLongSide) {
      return jpegOrBytes;
    }
    final resized = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? maxLongSide : null,
      height: decoded.height > decoded.width ? maxLongSide : null,
      interpolation: img.Interpolation.average,
    );
    return Uint8List.fromList(img.encodeJpg(resized, quality: jpegQuality));
  }
}
