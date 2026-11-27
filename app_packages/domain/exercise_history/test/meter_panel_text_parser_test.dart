import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

void main() {
  test('JSON の全項目', () {
    final values = MeterPanelTextParser.parse(
      '{"distance":12.3,"time-hour":1,"time-min":0,"time-sec":0,"calories":200}',
    );
    expect(values.distanceKm, 12.3);
    expect(values.duration, const Duration(hours: 1));
    expect(values.caloriesKcal, 200);
    expect(values.averageSpeedKmh, isNull);
  });

  test('JSON で平均速度キーは無くてもよい', () {
    final values = MeterPanelTextParser.parse(
      '{"distance":5,"time-hour":0,"time-min":30,"time-sec":0,"calories":80}',
    );
    expect(values.distanceKm, 5);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, 80);
  });

  test('コードフェンス付き JSON を読む', () {
    final values = MeterPanelTextParser.parse(
      '```json\n{"distance": 3, "time-hour": 0, "time-min": 10, "time-sec": 5, "calories": 40}\n```',
    );
    expect(values.distanceKm, 3);
    expect(values.duration, const Duration(minutes: 10, seconds: 5));
    expect(values.caloriesKcal, 40);
  });

  test('末尾カンマや単一引用符の JSON を修復する', () {
    final values = MeterPanelTextParser.parse(
      "{'distance': 7.5, 'time-hour': 0, 'time-min': 20, 'time-sec': 0, 'calories': 90,}",
    );
    expect(values.distanceKm, 7.5);
    expect(values.duration, const Duration(minutes: 20));
    expect(values.caloriesKcal, 90);
  });

  test('閉じ括弧欠けの JSON を補う', () {
    final values = MeterPanelTextParser.parse(
      '{"distance": 2, "time-hour": 0, "time-min": 5, "time-sec": 0, "calories": 15',
    );
    expect(values.distanceKm, 2);
    expect(values.duration, const Duration(minutes: 5));
    expect(values.caloriesKcal, 15);
  });

  test('JSON の負の距離は未取得', () {
    final values = MeterPanelTextParser.parse(
      '{"distance": -1, "time-hour": 0, "time-min": 1, "time-sec": 0, "calories": 10}',
    );
    expect(values.distanceKm, isNull);
    expect(values.duration, const Duration(minutes: 1));
    expect(values.caloriesKcal, 10);
  });

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

  test('次ラベルの数値を距離に取り込まない', () {
    final values = MeterPanelTextParser.parse(
      'Distance -- Time 0:30:00 Calories 80',
    );
    expect(values.distanceKm, isNull);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, 80);
  });

  test('mi / mph は未取得', () {
    expect(MeterPanelTextParser.parse('Distance 10 mi').distanceKm, isNull);
    expect(MeterPanelTextParser.parse('Speed 10 mph').averageSpeedKmh, isNull);
  });

  test('未登録単位 cm は距離として取り込まない', () {
    expect(MeterPanelTextParser.parse('Distance 100 cm').distanceKm, isNull);
  });

  test('句読点の直後の次ラベルを越えない', () {
    final values = MeterPanelTextParser.parse('距離 --、時間 0:30:00 消費 80 kcal');
    expect(values.distanceKm, isNull);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, 80);
  });
}
