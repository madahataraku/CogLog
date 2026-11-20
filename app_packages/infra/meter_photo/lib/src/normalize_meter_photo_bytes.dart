import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'meter_photo_long_side_limit.dart';

/// [bytes] を Orientation 補正し、長辺を [meterPhotoMaxLongSidePx] 以下へ縮小して JPEG にする。
///
/// デコードやエンコードに失敗したときは [bytes] をそのまま返す。
///
/// Example:
/// ```dart
/// normalizeMeterPhotoBytes(Uint8List(0));
/// ```
Uint8List normalizeMeterPhotoBytes(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return bytes;
    }
    var image = img.bakeOrientation(decoded);
    final longSide = math.max(image.width, image.height);
    if (longSide > meterPhotoMaxLongSidePx) {
      final scale = meterPhotoMaxLongSidePx / longSide;
      var width = math.max(1, (image.width * scale).round());
      var height = math.max(1, (image.height * scale).round());
      if (math.max(width, height) > meterPhotoMaxLongSidePx) {
        if (width >= height) {
          width = meterPhotoMaxLongSidePx;
          height = math.max(1, (image.height * (width / image.width)).round());
        } else {
          height = meterPhotoMaxLongSidePx;
          width = math.max(1, (image.width * (height / image.height)).round());
        }
      }
      image = img.copyResize(
        image,
        width: width,
        height: height,
        interpolation: img.Interpolation.linear,
      );
    }
    return Uint8List.fromList(
      img.encodeJpg(image, quality: meterPhotoNormalizeJpegQuality),
    );
  } on Object {
    return bytes;
  }
}
