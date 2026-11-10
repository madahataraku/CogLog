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

  test('バケット内の value を合計する', () {
    final points = TrendsExerciseAggregator.points(
      samples: [
        TrendsSample(at: DateTime(2026, 11, 10, 8), value: 100),
        TrendsSample(at: DateTime(2026, 11, 10, 18), value: 50),
        TrendsSample(at: DateTime(2026, 11, 9, 12), value: 30),
      ],
      buckets: buckets,
    );
    expect(points, hasLength(2));
    expect(points[0].representativeDate, DateTime(2026, 11, 9));
    expect(points[0].value, 30);
    expect(points[1].representativeDate, DateTime(2026, 11, 10));
    expect(points[1].value, 150);
  });

  test('空バケットは点を作らない', () {
    final points = TrendsExerciseAggregator.points(
      samples: [TrendsSample(at: DateTime(2026, 11, 10, 8), value: 100)],
      buckets: buckets,
    );
    expect(points, hasLength(1));
    expect(points.single.representativeDate, DateTime(2026, 11, 10));
  });
}
