// ignore_for_file: avoid_relative_lib_imports

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/seven_segment_yolo_postprocess.dart';

/// 前処理の検証用に赤い PNG を作る。
///
/// Example:
/// ```dart
/// final photo = await _redPhoto(4, 2);
/// ```
Future<Uint8List> _redPhoto(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(const ui.Color(0xFFFF0000), ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('空画像と壊れた画像は null を返す', () async {
    for (final bytes in [Uint8List(0), Uint8List.fromList([1, 2, 3])]) {
      expect(await SevenSegmentYoloPostprocess.decodeAndLetterbox(bytes), isNull);
    }
  });

  for (final size in [(4, 2), (2, 4), (2, 2)]) {
    test('画像 $size を拡大し縦横比と RGB と余白を保持する', () async {
      final result = await SevenSegmentYoloPostprocess.decodeAndLetterbox(
        await _redPhoto(size.$1, size.$2),
        inputSize: 8,
      );
      expect(result, isNotNull);
      final prepared = result!;
      final meta = prepared.letterbox;
      expect(prepared.input.length, 8 * 8 * 3);
      expect(meta.srcWidth, size.$1);
      expect(meta.srcHeight, size.$2);
      expect(meta.scale, size == (2, 2) ? 4 : 2);
      expect(meta.padX, size == (2, 4) ? 2 : 0);
      expect(meta.padY, size == (4, 2) ? 2 : 0);
      for (var y = 0; y < 8; y++) {
        for (var x = 0; x < 8; x++) {
          final inside = x >= meta.padX &&
              x < 8 - meta.padX &&
              y >= meta.padY &&
              y < 8 - meta.padY;
          final offset = (y * 8 + x) * 3;
          for (var c = 0; c < 3; c++) {
            expect(
              prepared.input[offset + c],
              closeTo(inside ? (c == 0 ? 1 : 0) : 114 / 255, 1e-6),
              reason: 'pixel ($x, $y), channel $c',
            );
          }
        }
      }
    });
  }
}
