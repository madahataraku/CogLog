import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

import 'meter_photo_long_side_limit.dart';

/// [bytes] を Orientation 補正し、長辺を [meterPhotoMaxLongSidePx] 以下へ縮小して JPEG にする。
///
/// `package:image` で解けない形式（例: HEIC）は Flutter の画像コーデックでデコードする。
/// 重い処理は UI isolate を塞がないよう [Isolate.run] / [compute] 相当で逃がす。
/// デコードやエンコードに失敗したときは [bytes] をそのまま返す。
///
/// Example:
/// ```dart
/// await normalizeMeterPhotoBytes(Uint8List(0));
/// ```
Future<Uint8List> normalizeMeterPhotoBytes(Uint8List bytes) async {
  try {
    final viaPackage = await Isolate.run(
      () => _normalizeWithPackageImage(bytes),
    );
    if (viaPackage != null) {
      return viaPackage;
    }
    final viaFlutter = await _normalizeWithFlutterCodec(bytes);
    if (viaFlutter != null) {
      return viaFlutter;
    }
    return bytes;
  } on Object {
    return bytes;
  }
}

/// `package:image` でデコードできるときだけ JPEG 正規化結果を返す。
///
/// Example:
/// ```dart
/// _normalizeWithPackageImage(Uint8List(0));
/// ```
Uint8List? _normalizeWithPackageImage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return null;
  }
  final oriented = img.bakeOrientation(decoded);
  return _encodeResizedJpeg(oriented);
}

/// Flutter コーデックでデコードし、長辺制限後の JPEG を返す。
///
/// Example:
/// ```dart
/// await _normalizeWithFlutterCodec(Uint8List(0));
/// ```
Future<Uint8List?> _normalizeWithFlutterCodec(Uint8List bytes) async {
  ui.Codec? codec;
  try {
    codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;
    try {
      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) {
        return null;
      }
      final rgba = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      final width = uiImage.width;
      final height = uiImage.height;
      return await Isolate.run(
        () => _encodeRgbaJpeg(
          rgba: Uint8List.fromList(rgba),
          width: width,
          height: height,
        ),
      );
    } finally {
      uiImage.dispose();
    }
  } on Object {
    return null;
  } finally {
    codec?.dispose();
  }
}

/// RGBA 画素から [img.Image] を組み立てて JPEG 正規化する。
///
/// Example:
/// ```dart
/// _encodeRgbaJpeg(rgba: Uint8List(0), width: 1, height: 1);
/// ```
Uint8List? _encodeRgbaJpeg({
  required Uint8List rgba,
  required int width,
  required int height,
}) {
  if (width <= 0 || height <= 0) {
    return null;
  }
  final expected = width * height * 4;
  if (rgba.length < expected) {
    return null;
  }
  final image = img.Image.fromBytes(
    width: width,
    height: height,
    bytes: rgba.buffer,
    bytesOffset: rgba.offsetInBytes,
    order: img.ChannelOrder.rgba,
  );
  return _encodeResizedJpeg(image);
}

/// 長辺上限を満たすよう縮小して JPEG エンコードする。
///
/// Example:
/// ```dart
/// _encodeResizedJpeg(img.Image(width: 1, height: 1));
/// ```
Uint8List _encodeResizedJpeg(img.Image image) {
  var output = image;
  final longSide = math.max(output.width, output.height);
  if (longSide > meterPhotoMaxLongSidePx) {
    final scale = meterPhotoMaxLongSidePx / longSide;
    var width = math.max(1, (output.width * scale).round());
    var height = math.max(1, (output.height * scale).round());
    if (math.max(width, height) > meterPhotoMaxLongSidePx) {
      if (width >= height) {
        width = meterPhotoMaxLongSidePx;
        height = math.max(1, (output.height * (width / output.width)).round());
      } else {
        height = meterPhotoMaxLongSidePx;
        width = math.max(1, (output.width * (height / output.height)).round());
      }
    }
    output = img.copyResize(
      output,
      width: width,
      height: height,
      interpolation: img.Interpolation.linear,
    );
  }
  return Uint8List.fromList(
    img.encodeJpg(output, quality: meterPhotoNormalizeJpegQuality),
  );
}
