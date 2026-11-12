import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

void main() {
  test('A1: 30 km / 1 h は 30 km/h', () {
    expect(
      calculateAverageSpeedKmh(
        distanceKm: 30,
        duration: const Duration(hours: 1),
      ),
      30,
    );
  });

  test('A2: 運動時間が 0 なら null', () {
    expect(
      calculateAverageSpeedKmh(distanceKm: 30, duration: Duration.zero),
      isNull,
    );
  });

  test('A3: パネル平均速度があっても距離÷時間を使い fromPanel は false', () {
    final resolved = resolveInitialAverageSpeed(
      merged: const MeterReadingValues(
        distanceKm: 1,
        duration: Duration(hours: 1),
        averageSpeedKmh: 9,
      ),
    );
    expect(resolved.speed, 1);
    expect(resolved.fromPanel, isFalse);
  });

  test('A4: 平均速度が無く距離と時間があれば計算し fromPanel は false', () {
    final resolved = resolveInitialAverageSpeed(
      merged: const MeterReadingValues(
        distanceKm: 1,
        duration: Duration(hours: 1),
      ),
    );
    expect(resolved.speed, 1);
    expect(resolved.fromPanel, isFalse);
  });

  test('A5: 距離と時間があれば再計算する', () {
    expect(
      recalculateAverageSpeedIfNeeded(
        distanceKm: 5,
        duration: const Duration(hours: 1),
      ),
      5,
    );
  });

  test('A6: 運動時間 0 ならパネル平均速度があっても null', () {
    final resolved = resolveInitialAverageSpeed(
      merged: const MeterReadingValues(
        duration: Duration.zero,
        averageSpeedKmh: 10,
      ),
    );
    expect(resolved.speed, isNull);
    expect(resolved.fromPanel, isFalse);
  });

  test('A7: 距離または時間が無いとき再計算は null', () {
    expect(
      recalculateAverageSpeedIfNeeded(distanceKm: 1, duration: null),
      isNull,
    );
    expect(
      recalculateAverageSpeedIfNeeded(
        distanceKm: null,
        duration: const Duration(hours: 1),
      ),
      isNull,
    );
  });

  group('classifyMeterReadingMessages', () {
    test('コアが揃えば complete', () {
      expect(
        classifyMeterReadingMessages(
          const MeterReadingValues(
            distanceKm: 1,
            duration: Duration(minutes: 1),
            caloriesKcal: 1,
          ),
        ),
        MeterReadingMessageKind.complete,
      );
    });

    test('運動時間 0 は incomplete', () {
      expect(
        classifyMeterReadingMessages(
          const MeterReadingValues(
            distanceKm: 1,
            duration: Duration.zero,
            caloriesKcal: 1,
          ),
        ),
        MeterReadingMessageKind.incomplete,
      );
    });

    test('コアの一部だけなら incomplete', () {
      expect(
        classifyMeterReadingMessages(const MeterReadingValues(distanceKm: 1)),
        MeterReadingMessageKind.incomplete,
      );
    });

    test('コアが皆無なら empty', () {
      expect(
        classifyMeterReadingMessages(const MeterReadingValues()),
        MeterReadingMessageKind.empty,
      );
    });
  });
}
