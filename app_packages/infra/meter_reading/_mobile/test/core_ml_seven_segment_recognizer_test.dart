// ignore_for_file: avoid_relative_lib_imports

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/src/core_ml_seven_segment_recognizer.dart';

/// 実画像の代わりに小さな単色 PNG を作る。
///
/// Example:
/// ```dart
/// final bytes = await _photo();
/// ```
Future<Uint8List> _photo() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(const ui.Color(0xFFFF0000), ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(2, 2);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('infra_meter_reading/seven_segment');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('壊れた画像はネイティブへ渡さない', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (_) async {
      calls++;
      return null;
    });
    final recognizer = CoreMlSevenSegmentRecognizer();
    expect(await recognizer.recognize(Uint8List.fromList([1, 2, 3])), isEmpty);
    expect(calls, 0);
  });

  for (final response in <List<dynamic>?>[null, []]) {
    test('ネイティブ結果 $response は空トークンを返す', () async {
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (_) async {
        calls++;
        return response;
      });
      expect(
        await CoreMlSevenSegmentRecognizer().recognize(await _photo()),
        isEmpty,
      );
      expect(calls, 1);
    });
  }

  test('RGB float32 を送り整数を含む検出行を数値トークンへ戻す', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'predict');
      final args = call.arguments as Map<dynamic, dynamic>;
      expect(args['width'], 192);
      expect(args['height'], 192);
      expect(args['channels'], 3);
      final bytes = args['inputFloat32'] as Uint8List;
      expect(bytes.length, 192 * 192 * 3 * 4);
      final data = ByteData.sublistView(bytes);
      expect(
        [for (var i = 0; i < 3; i++) data.getFloat32(i * 4, Endian.host)],
        [1, 0, 0],
      );
      return [
        [96, 96, 24, 48, 0.9, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
      ];
    });
    final tokens = await CoreMlSevenSegmentRecognizer().recognize(
      await _photo(),
    );
    expect(tokens.single.text, '7');
    expect(tokens.single.left, 0.4375);
    expect(tokens.single.top, 0.375);
    expect(tokens.single.width, 0.125);
    expect(tokens.single.height, 0.25);
  });

  test('指定した score 閾値で検出を除外する', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => [
        [96, 96, 24, 48, 0.5, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      ],
    );
    expect(
      await CoreMlSevenSegmentRecognizer(scoreThreshold: 0.75)
          .recognize(await _photo()),
      isEmpty,
    );
  });

  test('プラットフォーム例外はエンジンのフォールバック用に伝播する', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'model_unavailable');
    });
    final photo = await _photo();
    await expectLater(
      CoreMlSevenSegmentRecognizer().recognize(photo),
      throwsA(isA<PlatformException>()),
    );
  });
}
