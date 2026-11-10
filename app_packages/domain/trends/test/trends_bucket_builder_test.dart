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
}
