import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_meter_reading_testing/infra_meter_reading_testing.dart';
import 'package:test/test.dart';

void main() {
  test('既定は空列で callCount が増える', () async {
    final fake = FakeMeterSevenSegmentRecognizer();
    final result = await fake.recognize(Uint8List(0));
    expect(result, isEmpty);
    expect(fake.callCount, 1);
  });

  test('tokens をそのまま返す', () async {
    const tokens = [
      MeterOcrToken(text: '1', left: 0.1, top: 0.1, width: 0.05, height: 0.08),
    ];
    final fake = FakeMeterSevenSegmentRecognizer(tokens: tokens);
    expect(await fake.recognize(Uint8List(0)), tokens);
  });

  test('throwOnRecognize で StateError', () async {
    final fake = FakeMeterSevenSegmentRecognizer(throwOnRecognize: true);
    expect(() => fake.recognize(Uint8List(0)), throwsA(isA<StateError>()));
  });
}
