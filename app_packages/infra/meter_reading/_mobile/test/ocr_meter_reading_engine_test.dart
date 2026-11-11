import 'dart:typed_data';

import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:test/test.dart';

/// 固定文字列を返す認識 Fake。
final class _FakeRecognizer implements MeterTextRecognizer {
  /// [text] を返す。
  ///
  /// Example:
  /// ```dart
  /// _FakeRecognizer('距離 1 km');
  /// ```
  _FakeRecognizer(this.text, {this.throwOnRecognize = false});

  /// 返す生テキスト。
  final String text;

  /// true のとき失敗する。
  final bool throwOnRecognize;

  /// 最後に渡された画像。
  Uint8List? lastBytes;

  /// [text] を返すか失敗する。
  ///
  /// Example:
  /// ```dart
  /// await _FakeRecognizer('x').recognize(Uint8List(0));
  /// ```
  @override
  Future<String> recognize(Uint8List photoBytes) async {
    lastBytes = photoBytes;
    if (throwOnRecognize) {
      throw StateError('recognize failed');
    }
    return text;
  }

  /// Fake では何もしない。
  ///
  /// Example:
  /// ```dart
  /// await _FakeRecognizer('x').close();
  /// ```
  @override
  Future<void> close() async {}
}

void main() {
  test('isAvailable は常に true', () async {
    final engine = OcrMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      recognizer: _FakeRecognizer(''),
    );
    expect(await engine.isAvailable, isTrue);
    expect(engine.kind, MeterReadingEngineKind.mlKit);
  });

  test('read は認識結果をパースする', () async {
    final recognizer = _FakeRecognizer(
      'DISTANCE_KM=12.3\nDURATION=1:00:00\nCALORIES_KCAL=200\nAVERAGE_SPEED_KMH=12.3',
    );
    final engine = OcrMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      recognizer: recognizer,
    );
    final bytes = Uint8List.fromList([4, 5]);
    final values = await engine.read(bytes);
    expect(recognizer.lastBytes, bytes);
    expect(values.distanceKm, 12.3);
    expect(values.duration, const Duration(hours: 1));
    expect(values.caloriesKcal, 200);
    expect(values.averageSpeedKmh, 12.3);
  });

  test('認識失敗は例外のまま伝える', () async {
    final engine = OcrMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      recognizer: _FakeRecognizer('', throwOnRecognize: true),
    );
    await expectLater(engine.read(Uint8List(0)), throwsStateError);
  });
}
