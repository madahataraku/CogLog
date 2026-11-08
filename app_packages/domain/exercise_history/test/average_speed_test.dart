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

  test('A3: パネル由来の平均速度があるとき fromPanel は true', () {
    final resolved = resolveInitialAverageSpeed(
      merged: const MeterReadingValues(
        distanceKm: 1,
        duration: Duration(hours: 1),
        averageSpeedKmh: 9,
      ),
    );
    expect(resolved.speed, 9);
    expect(resolved.fromPanel, isTrue);
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

  test('A5: fromPanel のとき距離変更でも速度を維持する', () {
    final updated = recalculateAverageSpeedIfNeeded(
      distanceKm: 5,
      duration: const Duration(hours: 1),
      currentSpeed: 9,
      averageSpeedFromPanel: true,
      averageSpeedUserEdited: false,
      averageSpeedClearedByUser: false,
    );
    expect(updated.speed, 9);
    expect(updated.userEdited, isFalse);
    expect(updated.fromPanel, isTrue);
  });

  test('A6: クリア後は再計算し userEdited / fromPanel は false', () {
    final updated = recalculateAverageSpeedIfNeeded(
      distanceKm: 1,
      duration: const Duration(hours: 1),
      currentSpeed: 9,
      averageSpeedFromPanel: true,
      averageSpeedUserEdited: false,
      averageSpeedClearedByUser: true,
    );
    expect(updated.speed, 1);
    expect(updated.userEdited, isFalse);
    expect(updated.fromPanel, isFalse);
  });
}
