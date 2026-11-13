import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

void main() {
  test('preferFirst は preferred を優先し欠落だけ fallback で埋める', () {
    final merged = MeterReadingMerger.preferFirst(
      const MeterReadingValues(distanceKm: 1),
      const MeterReadingValues(distanceKm: 9, caloriesKcal: 3),
    );
    expect(merged.distanceKm, 1);
    expect(merged.caloriesKcal, 3);
    expect(merged.duration, isNull);
  });

  test('preferFirst は preferred が空なら fallback を採用する', () {
    final merged = MeterReadingMerger.preferFirst(
      const MeterReadingValues(),
      const MeterReadingValues(duration: Duration(minutes: 1)),
    );
    expect(merged.duration, const Duration(minutes: 1));
  });

  test('M1: 後勝ちで非 null フィールドを上書きする', () {
    final merged = MeterReadingMerger.merge(
      const MeterReadingValues(distanceKm: 1),
      const MeterReadingValues(distanceKm: 2, caloriesKcal: 3),
    );
    expect(merged.distanceKm, 2);
    expect(merged.caloriesKcal, 3);
    expect(merged.duration, isNull);
    expect(merged.averageSpeedKmh, isNull);
  });

  test('M2: コアが揃い運動時間 > 0 なら complete、0 なら incomplete', () {
    expect(
      isCompleteMeterReadingCore(
        const MeterReadingValues(
          distanceKm: 1,
          duration: Duration(minutes: 1),
          caloriesKcal: 1,
        ),
      ),
      isTrue,
    );
    expect(
      isCompleteMeterReadingCore(
        const MeterReadingValues(
          distanceKm: 1,
          duration: Duration.zero,
          caloriesKcal: 1,
        ),
      ),
      isFalse,
    );
  });

  test('手打ち案内はコア未完了のとき true', () {
    expect(needsMeterHandEntryGuidance(const MeterReadingValues()), isTrue);
    expect(
      needsMeterHandEntryGuidance(
        const MeterReadingValues(
          distanceKm: 1,
          duration: Duration.zero,
          caloriesKcal: 1,
        ),
      ),
      isTrue,
    );
    expect(
      needsMeterHandEntryGuidance(
        const MeterReadingValues(
          distanceKm: 1,
          duration: Duration(minutes: 1),
          caloriesKcal: 1,
        ),
      ),
      isFalse,
    );
  });
}
