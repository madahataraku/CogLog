import 'package:infra_app_review_testing/infra_app_review_testing.dart';
import 'package:test/test.dart';

void main() {
  test('isAvailable は available を返す', () async {
    final fake = FakeAppInAppReview(available: false);
    expect(await fake.isAvailable(), isFalse);
  });

  test('requestReview は回数を増やす', () async {
    final fake = FakeAppInAppReview();
    await fake.requestReview();
    expect(fake.requestCount, 1);
  });

  test('throwOnRequest なら例外を投げる', () async {
    final fake = FakeAppInAppReview(throwOnRequest: true);
    await expectLater(fake.requestReview(), throwsStateError);
    expect(fake.requestCount, 1);
  });
}
