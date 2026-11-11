import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

void main() {
  test('日本語ラベルの全項目', () {
    final values = MeterPanelTextParser.parse(
      '距離 12.3 km\n時間 1:00:00\n消費 200 kcal\n平均速度 12.3 km/h',
    );
    expect(values.distanceKm, 12.3);
    expect(values.duration, const Duration(hours: 1));
    expect(values.caloriesKcal, 200);
    expect(values.averageSpeedKmh, 12.3);
  });

  test('英語ラベルで平均速度なし', () {
    final values = MeterPanelTextParser.parse(
      'Distance 5.0km Time 0:30:00 Calorie 80',
    );
    expect(values.distanceKm, 5);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, 80);
    expect(values.averageSpeedKmh, isNull);
  });

  test('運動時間 0 でもパネル平均速度を残す', () {
    final values = MeterPanelTextParser.parse('時間 0:00:00 平均速度 10 km/h');
    expect(values.duration, Duration.zero);
    expect(values.averageSpeedKmh, 10);
    expect(values.distanceKm, isNull);
  });

  test('LLM キー行の全項目', () {
    final values = MeterPanelTextParser.parse(
      'DISTANCE_KM=12.3\nDURATION=1:00:00\nCALORIES_KCAL=200\nAVERAGE_SPEED_KMH=12.3',
    );
    expect(values.distanceKm, 12.3);
    expect(values.duration, const Duration(hours: 1));
    expect(values.caloriesKcal, 200);
    expect(values.averageSpeedKmh, 12.3);
  });

  test('LLM キー行で平均速度なし', () {
    final values = MeterPanelTextParser.parse(
      'DISTANCE_KM=5\nDURATION=0:30:00\nCALORIES_KCAL=80',
    );
    expect(values.distanceKm, 5);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, 80);
    expect(values.averageSpeedKmh, isNull);
  });

  test('空とノイズはすべて null', () {
    expect(MeterPanelTextParser.parse('abc').distanceKm, isNull);
    expect(MeterPanelTextParser.parse('').duration, isNull);
  });

  test('負の距離は未取得', () {
    expect(MeterPanelTextParser.parse('距離 -1 km').distanceKm, isNull);
  });
}
