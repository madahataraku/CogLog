import 'package:domain_trends/domain_trends.dart';
import 'package:test/test.dart';

void main() {
  final buckets = [
    TrendsBucket(
      startInclusive: DateTime(2026, 11, 9),
      endExclusive: DateTime(2026, 11, 10),
      representativeDate: DateTime(2026, 11, 9),
    ),
    TrendsBucket(
      startInclusive: DateTime(2026, 11, 10),
      endExclusive: DateTime(2026, 11, 11),
      representativeDate: DateTime(2026, 11, 10),
    ),
  ];

  test('バケット内で at が最も遅い value を採る', () {
    final points = TrendsBodyAggregator.points(
      samples: [
        TrendsSample(at: DateTime(2026, 11, 10, 8), value: 70),
        TrendsSample(at: DateTime(2026, 11, 10, 20), value: 69.5),
        TrendsSample(at: DateTime(2026, 11, 9, 7), value: 71),
        TrendsSample(at: DateTime(2026, 11, 9, 22), value: 70.8),
      ],
      buckets: buckets,
    );
    expect(points, hasLength(2));
    expect(points[0].representativeDate, DateTime(2026, 11, 9));
    expect(points[0].value, 70.8);
    expect(points[1].representativeDate, DateTime(2026, 11, 10));
    expect(points[1].value, 69.5);
  });

  test('空バケットは点を作らない', () {
    final points = TrendsBodyAggregator.points(
      samples: [TrendsSample(at: DateTime(2026, 11, 9, 12), value: 71)],
      buckets: buckets,
    );
    expect(points, hasLength(1));
    expect(points.single.representativeDate, DateTime(2026, 11, 9));
  });
}
