import 'package:domain_trends/domain_trends.dart';
import 'package:test/test.dart';

void main() {
  final buckets = List.generate(
    5,
    (i) => TrendsBucket(
      startInclusive: DateTime(2026, 11, 6 + i),
      endExclusive: DateTime(2026, 11, 7 + i),
      representativeDate: DateTime(2026, 11, 6 + i),
    ),
  );

  test('隣接 index の 2 点は solid 1 本', () {
    final segments = TrendsLineBuilder.segments(
      points: [
        TrendsSeriesPoint(
          representativeDate: buckets[0].representativeDate,
          value: 1,
        ),
        TrendsSeriesPoint(
          representativeDate: buckets[1].representativeDate,
          value: 2,
        ),
      ],
      buckets: buckets,
    );
    expect(segments, hasLength(1));
    expect(segments.single.kind, TrendsLineKind.solid);
  });

  test('飛び index の 2 点は dashed 1 本', () {
    final segments = TrendsLineBuilder.segments(
      points: [
        TrendsSeriesPoint(
          representativeDate: buckets[0].representativeDate,
          value: 1,
        ),
        TrendsSeriesPoint(
          representativeDate: buckets[2].representativeDate,
          value: 3,
        ),
      ],
      buckets: buckets,
    );
    expect(segments, hasLength(1));
    expect(segments.single.kind, TrendsLineKind.dashed);
  });

  test('点 1 個は segments 空', () {
    final segments = TrendsLineBuilder.segments(
      points: [
        TrendsSeriesPoint(
          representativeDate: buckets[0].representativeDate,
          value: 1,
        ),
      ],
      buckets: buckets,
    );
    expect(segments, isEmpty);
  });
}
