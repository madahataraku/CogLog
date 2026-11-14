import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:infra_meter_reading_testing/infra_meter_reading_testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('両認識器が空なら全フィールド未設定のまま完了する', () async {
    final seven = FakeMeterSevenSegmentRecognizer();
    final engine = SpatialOcrMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      recognizer: FakeMeterLayoutRecognizer(tokens: const []),
      sevenSegmentRecognizer: seven,
    );
    final values = await engine.read(Uint8List(0));
    expect(values.distanceKm, isNull);
    expect(values.duration, isNull);
    expect(values.caloriesKcal, isNull);
    expect(values.averageSpeedKmh, isNull);
    expect(seven.callCount, 1);
  });

  test('補完失敗でもゼロの距離・時間・カロリーを保持する', () async {
    final engine = SpatialOcrMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      recognizer: FakeMeterLayoutRecognizer(
        tokens: const [
          MeterOcrToken(
            text: '0km',
            left: 0.1,
            top: 0.1,
            width: 0.2,
            height: 0.05,
          ),
          MeterOcrToken(
            text: '0:00:00',
            left: 0.1,
            top: 0.4,
            width: 0.2,
            height: 0.05,
          ),
          MeterOcrToken(
            text: '0kcal',
            left: 0.1,
            top: 0.7,
            width: 0.2,
            height: 0.05,
          ),
        ],
      ),
      sevenSegmentRecognizer: FakeMeterSevenSegmentRecognizer(
        throwOnRecognize: true,
      ),
    );
    final values = await engine.read(Uint8List(0));
    expect(values.distanceKm, 0);
    expect(values.duration, Duration.zero);
    expect(values.caloriesKcal, 0);
  });

  test('空間 OCR エンジンは認識結果を推論する', () async {
    final log = AppLogStore();
    final recognizer = FakeMeterLayoutRecognizer(
      tokens: const [
        MeterOcrToken(
          text: '12.3km',
          left: 0.2,
          top: 0.2,
          width: 0.2,
          height: 0.05,
        ),
      ],
    );
    final engine = SpatialOcrMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      recognizer: recognizer,
      log: log,
    );

    final values = await engine.read(Uint8List(0));
    expect(recognizer.callCount, 1);
    expect(values.distanceKm, 12.3);
    expect(log.entries, hasLength(3));
    expect(log.entries.first.tag, 'meter.spatial');
    expect(log.entries.first.message, contains('tokens=1'));
    expect(
      log.entries.first.message,
      contains('classes=[distanceValueWithUnit:1]'),
    );
    expect(log.entries.first.message, contains('otherDigits=0'));
    expect(
      log.entries.first.message,
      contains('texts=[12.3km@0.200,0.200,0.200,0.050]'),
    );
    expect(log.entries[1].message, contains('sevenSeg candidates='));
    expect(log.entries[1].message, contains('error=false'));
    expect(log.entries[1].message, contains('texts=[]'));
    expect(log.entries.last.message, contains('present=[distanceKm'));
    expect(log.entries.last.message, isNot(contains('distanceKm=12.3')));
    expect(log.entries.last.message, contains('adoptedFromSevenSeg='));
  });

  test('トークン0件なら warn と空の推論をログする', () async {
    final log = AppLogStore();
    final engine = SpatialOcrMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      recognizer: FakeMeterLayoutRecognizer(tokens: const []),
      log: log,
    );

    final values = await engine.read(Uint8List(0));
    expect(values.distanceKm, isNull);
    expect(log.entries.first.level, AppLogLevel.warn);
    expect(log.entries.first.message, contains('tokens=0'));
    expect(log.entries.first.message, contains('texts=[]'));
    expect(log.entries[1].message, contains('texts=[]'));
  });

  test('汎用ラベルのみ七セグで距離補完', () async {
    final log = AppLogStore();
    final engine = SpatialOcrMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      recognizer: FakeMeterLayoutRecognizer(
        tokens: const [
          MeterOcrToken(
            text: '距離',
            left: 0.1,
            top: 0.1,
            width: 0.2,
            height: 0.05,
          ),
        ],
      ),
      sevenSegmentRecognizer: FakeMeterSevenSegmentRecognizer(
        tokens: const [
          MeterOcrToken(
            text: '12.3',
            left: 0.1,
            top: 0.18,
            width: 0.2,
            height: 0.06,
          ),
        ],
      ),
      log: log,
    );

    final values = await engine.read(Uint8List(0));
    expect(values.distanceKm, 12.3);
    expect(
      log.entries.last.message,
      contains('adoptedFromSevenSeg=[distanceKm]'),
    );
    expect(
      log.entries.first.message,
      contains('texts=[距離@0.100,0.100,0.200,0.050]'),
    );
    expect(log.entries[1].message, contains('sevenSeg candidates=1'));
    expect(
      log.entries[1].message,
      contains('texts=[12.3@0.100,0.180,0.200,0.060]'),
    );
    expect(log.entries.last.message, isNot(contains('distanceKm=12.3')));
  });

  test('汎用に距離ありなら同位置の七セグは採用しない', () async {
    final log = AppLogStore();
    final engine = SpatialOcrMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      recognizer: FakeMeterLayoutRecognizer(
        tokens: const [
          MeterOcrToken(
            text: '12.3km',
            left: 0.1,
            top: 0.18,
            width: 0.2,
            height: 0.06,
          ),
        ],
      ),
      sevenSegmentRecognizer: FakeMeterSevenSegmentRecognizer(
        tokens: const [
          MeterOcrToken(
            text: '99.9',
            left: 0.1,
            top: 0.18,
            width: 0.2,
            height: 0.06,
          ),
        ],
      ),
      log: log,
    );

    final values = await engine.read(Uint8List(0));
    expect(values.distanceKm, 12.3);
    expect(log.entries.last.message, contains('adoptedFromSevenSeg=[]'));
  });

  test('七セグ例外は汎用のみで完了', () async {
    final log = AppLogStore();
    final engine = SpatialOcrMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      recognizer: FakeMeterLayoutRecognizer(
        tokens: const [
          MeterOcrToken(
            text: '12.3km',
            left: 0.2,
            top: 0.2,
            width: 0.2,
            height: 0.05,
          ),
        ],
      ),
      sevenSegmentRecognizer: FakeMeterSevenSegmentRecognizer(
        throwOnRecognize: true,
      ),
      log: log,
    );

    final values = await engine.read(Uint8List(0));
    expect(values.distanceKm, 12.3);
    expect(log.entries[1].message, contains('error=true'));
    expect(log.entries[1].message, contains('candidates=0'));
  });

  test('汎用単位付き数値と重なる七セグは別項目へ流用しない', () async {
    final engine = SpatialOcrMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      recognizer: FakeMeterLayoutRecognizer(
        tokens: const [
          // 距離ラベル無しでも 12.3km 単独で距離確定（除外無しだと七セグがカロリーへ流れる）
          MeterOcrToken(
            text: '12.3km',
            left: 0.1,
            top: 0.18,
            width: 0.2,
            height: 0.06,
          ),
          MeterOcrToken(
            text: 'カロリー',
            left: 0.05,
            top: 0.50,
            width: 0.15,
            height: 0.04,
          ),
        ],
      ),
      sevenSegmentRecognizer: FakeMeterSevenSegmentRecognizer(
        tokens: const [
          MeterOcrToken(
            text: '12.3',
            left: 0.1,
            top: 0.18,
            width: 0.2,
            height: 0.06,
          ),
        ],
      ),
      log: AppLogStore(),
    );

    final values = await engine.read(Uint8List(0));
    expect(values.distanceKm, 12.3);
    expect(values.caloriesKcal, isNull);
  });

  test('七セグノイズは汎用埋め済み項目を変えない', () async {
    final engine = SpatialOcrMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      recognizer: FakeMeterLayoutRecognizer(
        tokens: const [
          MeterOcrToken(
            text: '距離',
            left: 0.05,
            top: 0.2,
            width: 0.1,
            height: 0.04,
          ),
          MeterOcrToken(
            text: '5.0',
            left: 0.18,
            top: 0.2,
            width: 0.08,
            height: 0.04,
          ),
          MeterOcrToken(
            text: 'km',
            left: 0.28,
            top: 0.2,
            width: 0.06,
            height: 0.04,
          ),
          MeterOcrToken(
            text: 'カロリー',
            left: 0.05,
            top: 0.35,
            width: 0.15,
            height: 0.04,
          ),
          MeterOcrToken(
            text: '200',
            left: 0.25,
            top: 0.35,
            width: 0.1,
            height: 0.04,
          ),
        ],
      ),
      sevenSegmentRecognizer: FakeMeterSevenSegmentRecognizer(
        tokens: const [
          MeterOcrToken(
            text: '7',
            left: 0.8,
            top: 0.8,
            width: 0.05,
            height: 0.05,
          ),
        ],
      ),
      log: AppLogStore(),
    );

    final values = await engine.read(Uint8List(0));
    expect(values.distanceKm, 5.0);
    expect(values.caloriesKcal, 200);
  });
}
