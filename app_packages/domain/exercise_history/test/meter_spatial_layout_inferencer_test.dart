import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

/// 正規化座標のテスト用トークンを作る。
///
/// [l]/[top]/[w]/[h] は画像正規化の left / top / width / height。
///
/// Example:
/// ```dart
/// t('距離', 0.1, 0.10, 0.2, 0.05);
/// ```
MeterOcrToken t(String text, double l, double top, double w, double h) =>
    MeterOcrToken(text: text, left: l, top: top, width: w, height: h);

void main() {
  test('F1 縦配置で3項目', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('距離', 0.1, 0.10, 0.2, 0.05),
      t('12.3', 0.1, 0.18, 0.2, 0.06),
      t('時間', 0.1, 0.30, 0.2, 0.05),
      t('0:30:00', 0.1, 0.38, 0.25, 0.06),
      t('カロリー', 0.1, 0.50, 0.25, 0.05),
      t('200', 0.1, 0.58, 0.15, 0.06),
    ]);
    expect(values.distanceKm, 12.3);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, 200);
    expect(values.averageSpeedKmh, isNull);
  });

  test('F2 TIME アンカー', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('TIME', 0.1, 0.2, 0.15, 0.05),
      t('1:00:00', 0.3, 0.2, 0.2, 0.05),
    ]);
    expect(values.duration, const Duration(hours: 1));
    expect(values.distanceKm, isNull);
  });

  test('F3 コロンのみ一意', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('0:45:00', 0.4, 0.4, 0.2, 0.05),
    ]);
    expect(values.duration, const Duration(minutes: 45));
  });

  test('F4 km と km/h', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('距離', 0.05, 0.2, 0.15, 0.04),
      t('5.0', 0.25, 0.2, 0.1, 0.04),
      t('km', 0.36, 0.2, 0.08, 0.04),
      t('速度', 0.05, 0.35, 0.15, 0.04),
      t('20.0', 0.25, 0.35, 0.1, 0.04),
      t('km/h', 0.36, 0.35, 0.1, 0.04),
    ]);
    expect(values.distanceKm, 5.0);
    expect(values.averageSpeedKmh, isNull);
    expect(values.caloriesKcal, isNull);
  });

  test('横並びでも距離値を速度に奪わない', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('距離', 0.05, 0.20, 0.10, 0.04),
      t('5.0', 0.18, 0.20, 0.08, 0.04),
      t('km', 0.28, 0.20, 0.06, 0.04),
      t('速度', 0.40, 0.20, 0.10, 0.04),
      t('20.0', 0.55, 0.20, 0.08, 0.04),
      t('km/h', 0.66, 0.20, 0.08, 0.04),
    ]);
    expect(values.distanceKm, 5.0);
    expect(values.caloriesKcal, isNull);
  });

  test('速度の数値はカロリーに流用しない', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('距離', 0.05, 0.2, 0.15, 0.04),
      t('5.0', 0.25, 0.2, 0.1, 0.04),
      t('km', 0.36, 0.2, 0.08, 0.04),
      t('速度', 0.05, 0.35, 0.15, 0.04),
      t('20.0', 0.25, 0.35, 0.1, 0.04),
      t('km/h', 0.36, 0.35, 0.1, 0.04),
      t('カロリー', 0.05, 0.50, 0.2, 0.04),
      t('時間', 0.05, 0.65, 0.15, 0.04),
      t('0:30:00', 0.25, 0.65, 0.2, 0.04),
    ]);
    expect(values.distanceKm, 5.0);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, isNull);
  });

  test('全角コロンの時刻を読む', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('０：３０：００', 0.4, 0.4, 0.2, 0.05),
    ]);
    expect(values.duration, const Duration(minutes: 30));
  });

  test('範囲外の分秒は時間にしない', () {
    expect(MeterDurationParser.parseColonOnly('1:99'), isNull);
    expect(MeterDurationParser.parseColonOnly('0:99:00'), isNull);
  });

  test('F5 カロリー欠落', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('距離', 0.1, 0.10, 0.2, 0.05),
      t('12.3', 0.1, 0.18, 0.2, 0.06),
      t('時間', 0.1, 0.30, 0.2, 0.05),
      t('0:30:00', 0.1, 0.38, 0.25, 0.06),
    ]);
    expect(values.distanceKm, 12.3);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, isNull);
  });

  test('F6 単位別ボックス', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('12.3', 0.2, 0.2, 0.12, 0.05),
      t('km', 0.34, 0.2, 0.08, 0.05),
    ]);
    expect(values.distanceKm, 12.3);
  });

  test('F7 同一ボックス', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('12.3km', 0.2, 0.2, 0.2, 0.05),
    ]);
    expect(values.distanceKm, 12.3);
  });

  test('F8 曖昧で距離未取得', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('距離', 0.10, 0.20, 0.10, 0.04),
      t('1.0', 0.30, 0.20, 0.08, 0.04),
      t('2.0', 0.34, 0.20, 0.08, 0.04),
    ]);
    expect(values.distanceKm, isNull);
  });

  test('F9 アイコンのみ＋コロン一意', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('12.3', 0.1, 0.1, 0.1, 0.04),
      t('200', 0.1, 0.3, 0.1, 0.04),
      t('0:10:00', 0.1, 0.5, 0.2, 0.04),
    ]);
    expect(values.distanceKm, isNull);
    expect(values.caloriesKcal, isNull);
    expect(values.duration, const Duration(minutes: 10));
  });

  test('分類件数は本文を含まない', () {
    final counts = MeterSpatialLayoutInferencer.classifyKindCounts([
      t('距離', 0.1, 0.1, 0.1, 0.04),
      t('12.3', 0.1, 0.2, 0.1, 0.04),
      t('???', 0.1, 0.3, 0.1, 0.04),
    ]);
    expect(counts, {'distanceLabel': 1, 'bareNumber': 1, 'other': 1});
  });

  test('同じ分類の件数は加算する', () {
    final counts = MeterSpatialLayoutInferencer.classifyKindCounts([
      t('12.3', 0.1, 0.1, 0.1, 0.04),
      t('200', 0.1, 0.2, 0.1, 0.04),
      t('距離', 0.1, 0.3, 0.1, 0.04),
      t('???', 0.1, 0.4, 0.1, 0.04),
      t('!!!', 0.1, 0.5, 0.1, 0.04),
    ]);
    expect(counts, {'bareNumber': 2, 'distanceLabel': 1, 'other': 2});
  });

  test('前後ノイズ付き数値をラベル近傍で読む', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('距離', 0.1, 0.10, 0.2, 0.05),
      t('~12.3!', 0.1, 0.18, 0.2, 0.06),
      t('時間', 0.1, 0.30, 0.2, 0.05),
      t('0.30.00', 0.1, 0.38, 0.25, 0.06),
      t('カロリー', 0.1, 0.50, 0.25, 0.05),
      t('200kcal.', 0.1, 0.58, 0.2, 0.06),
    ]);
    expect(values.distanceKm, 12.3);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, 200);
  });

  test('OCR桁化けと日本語分を読む', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('距離', 0.1, 0.10, 0.2, 0.05),
      t('l2.o', 0.1, 0.18, 0.2, 0.06),
      t('時間', 0.1, 0.30, 0.2, 0.05),
      t('30分', 0.1, 0.38, 0.2, 0.06),
    ]);
    expect(values.distanceKm, 12.0);
    expect(values.duration, const Duration(minutes: 30));
  });

  test('| 付き桁化けは補正してから数値にする', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('距離', 0.1, 0.10, 0.2, 0.05),
      t('|2.0', 0.1, 0.18, 0.2, 0.06),
    ]);
    expect(values.distanceKm, 12.0);
  });

  test('単位付き桁化けと hms 形式を読む', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('カロリー', 0.1, 0.10, 0.2, 0.05),
      t('l2kcal', 0.1, 0.18, 0.2, 0.06),
      t('時間', 0.1, 0.30, 0.2, 0.05),
      t('0h3om00s', 0.1, 0.38, 0.25, 0.06),
    ]);
    expect(values.caloriesKcal, 12);
    expect(values.duration, const Duration(minutes: 30));
  });

  test('末尾ノイズ付きでも単位と hms を読む', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('カロリー', 0.1, 0.10, 0.2, 0.05),
      t('l2kcal.', 0.1, 0.18, 0.2, 0.06),
      t('時間', 0.1, 0.30, 0.2, 0.05),
      t('0h3om00s!', 0.1, 0.38, 0.25, 0.06),
    ]);
    expect(values.caloriesKcal, 12);
    expect(values.duration, const Duration(minutes: 30));
  });

  test('負数は距離として採用しない', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('距離', 0.1, 0.10, 0.2, 0.05),
      t('-12.3km', 0.1, 0.18, 0.2, 0.06),
    ]);
    expect(values.distanceKm, isNull);
  });

  test('負号付き hms は時間として採用しない', () {
    final values = MeterSpatialLayoutInferencer.infer([
      t('時間', 0.1, 0.10, 0.2, 0.05),
      t('-1h30m00s', 0.1, 0.18, 0.25, 0.06),
    ]);
    expect(values.duration, isNull);
  });

  test('tokensExcludingNumericValues は数値種を除きラベルと単位を残す', () {
    final tokens = [
      t('距離', 0.1, 0.1, 0.2, 0.05),
      t('12.3', 0.1, 0.18, 0.2, 0.06),
      t('km', 0.32, 0.18, 0.08, 0.06),
    ];
    final filtered = MeterSpatialLayoutInferencer.tokensExcludingNumericValues(
      tokens,
    );
    final texts = filtered.map((e) => e.text).toSet();
    expect(texts, containsAll(['距離', 'km']));
    expect(texts, isNot(contains('12.3')));
  });

  test('adoptedNumericValueTokens は採用した数値だけ返す', () {
    final adopted = MeterSpatialLayoutInferencer.adoptedNumericValueTokens([
      t('12.3km', 0.1, 0.18, 0.2, 0.06),
    ]);
    expect(adopted, hasLength(1));
    expect(adopted.single.text, '12.3km');
  });

  test('adoptedNumericValueTokens は曖昧な数値を含めない', () {
    final adopted = MeterSpatialLayoutInferencer.adoptedNumericValueTokens([
      t('距離', 0.1, 0.10, 0.2, 0.05),
      t('12', 0.05, 0.18, 0.08, 0.05),
      t('3', 0.25, 0.18, 0.08, 0.05),
    ]);
    expect(adopted, isEmpty);
  });

  test('otherDigits は other のうち桁ありだけ数える', () {
    final tokens = [
      t('距離', 0.1, 0.1, 0.1, 0.04),
      t('abc', 0.1, 0.2, 0.1, 0.04),
      t('x9y', 0.1, 0.3, 0.1, 0.04),
      t('12.3', 0.1, 0.4, 0.1, 0.04),
    ];
    expect(MeterSpatialLayoutInferencer.countOtherWithDigits(tokens), 1);
  });
}
