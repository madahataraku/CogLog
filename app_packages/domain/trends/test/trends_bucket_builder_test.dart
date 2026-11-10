import 'package:domain_trends/domain_trends.dart';
import 'package:test/test.dart';

void main() {
  final nowLocal = DateTime(2026, 11, 10);

  test('days30 は 30 バケット・最古 length 1・最新代表日は本日', () {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: nowLocal,
      spec: TrendsPeriodSpec.days30,
    );
    expect(buckets, hasLength(30));
    expect(buckets.first.lengthDays, 1);
    expect(buckets.last.representativeDate, DateTime(2026, 11, 10));
    expect(buckets.last.lengthDays, 1);
  });

  test('days90 は 13 バケット・最古 length 6・最新代表日は本日', () {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: nowLocal,
      spec: TrendsPeriodSpec.days90,
    );
    expect(buckets, hasLength(13));
    expect(buckets.first.lengthDays, 6);
    expect(buckets.last.representativeDate, DateTime(2026, 11, 10));
    expect(buckets.last.lengthDays, 7);
  });

  test('days182 は 13 バケット・最古 length 14・最新代表日は本日', () {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: nowLocal,
      spec: TrendsPeriodSpec.days182,
    );
    expect(buckets, hasLength(13));
    expect(buckets.first.lengthDays, 14);
    expect(buckets.last.representativeDate, DateTime(2026, 11, 10));
  });

  test('days365 は 14 バケット・最古 length 1・最新代表日は本日', () {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: nowLocal,
      spec: TrendsPeriodSpec.days365,
    );
    expect(buckets, hasLength(14));
    expect(buckets.first.lengthDays, 1);
    expect(buckets.last.representativeDate, DateTime(2026, 11, 10));
    expect(buckets.last.lengthDays, 28);
  });

  test('隣接バケットは endExclusive == 次の startInclusive', () {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: nowLocal,
      spec: TrendsPeriodSpec.days90,
    );
    for (var i = 0; i < buckets.length - 1; i++) {
      expect(buckets[i].endExclusive, buckets[i + 1].startInclusive);
    }
  });

  test('範囲端点は本日を含む dayCount 日分', () {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: nowLocal,
      spec: TrendsPeriodSpec.days30,
    );
    expect(buckets.first.startInclusive, DateTime(2026, 10, 12));
    expect(buckets.last.endExclusive, DateTime(2026, 11, 11));
  });

  test('日付境界のサンプルは 1 バケットだけに入る', () {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: nowLocal,
      spec: TrendsPeriodSpec.days90,
    );
    final midnight = DateTime(2026, 11, 4);
    final hits = [
      for (final bucket in buckets)
        if (bucket.contains(midnight)) bucket,
    ];
    expect(hits, hasLength(1));
    expect(hits.single.startInclusive, DateTime(2026, 11, 4));
    expect(hits.single.endExclusive, DateTime(2026, 11, 11));
  });
}
