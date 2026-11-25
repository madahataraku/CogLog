import 'package:data_repository_app_review_testing/data_repository_app_review_testing.dart';
import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:data_repository_tutorial_testing/data_repository_tutorial_testing.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:foundation_metadata/foundation_metadata.dart';
import 'package:infra_app_review_testing/infra_app_review_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_request_app_review/usecase_request_app_review.dart';
import 'package:usecase_request_app_review_impl/usecase_request_app_review_impl.dart';

void main() {
  late FakeAppInAppReview review;
  late MemoryAppReviewSuppressionRepository suppression;
  late MemoryTutorialRepository tutorial;
  late AppReviewRuntimeSession session;
  late RequestAppReviewUsecaseImpl usecase;

  setUp(() {
    Defines.override({'FLAVOR': 'production'});
    addTearDown(() => Defines.override({'FLAVOR': 'development'}));
    review = FakeAppInAppReview();
    suppression = MemoryAppReviewSuppressionRepository();
    tutorial = MemoryTutorialRepository();
    session = AppReviewRuntimeSession();
    usecase = RequestAppReviewUsecaseImpl(
      review: review,
      suppression: suppression,
      tutorial: tutorial,
      session: session,
    );
  });

  Future<void> completeMain() async {
    await tutorial.write(
      TutorialProgress.initial.copyWith(mainCompleted: true),
    );
  }

  test('development なら skippedFlavor', () async {
    Defines.override({'FLAVOR': 'development'});
    await completeMain();
    expect(await usecase.execute(), RequestAppReviewResult.skippedFlavor);
    expect(review.requestCount, 0);
  });

  test('抑止済みなら skippedSuppressed', () async {
    await completeMain();
    await suppression.markSuppressed();
    expect(await usecase.execute(), RequestAppReviewResult.skippedSuppressed);
    expect(review.requestCount, 0);
  });

  test('mainCompleted 偽なら skippedTutorial', () async {
    expect(await usecase.execute(), RequestAppReviewResult.skippedTutorial);
    expect(review.requestCount, 0);
  });

  test('tutorial 読取失敗なら skippedTutorial', () async {
    final failing = _FailingTutorialRepository();
    final local = RequestAppReviewUsecaseImpl(
      review: review,
      suppression: suppression,
      tutorial: failing,
      session: session,
    );
    expect(await local.execute(), RequestAppReviewResult.skippedTutorial);
    expect(review.requestCount, 0);
  });

  test('isAvailable 偽なら skippedUnavailable で抑止しない', () async {
    await completeMain();
    review.available = false;
    expect(await usecase.execute(), RequestAppReviewResult.skippedUnavailable);
    expect(review.requestCount, 0);
    expect(await suppression.isSuppressed(), isFalse);
  });

  test('isAvailable 例外なら skippedUnavailable で抑止しない', () async {
    await completeMain();
    review.throwOnIsAvailable = true;
    expect(await usecase.execute(), RequestAppReviewResult.skippedUnavailable);
    expect(review.requestCount, 0);
    expect(await suppression.isSuppressed(), isFalse);
  });

  test('inFlight 中は skippedInFlight', () async {
    await completeMain();
    session.requestInFlight = true;
    expect(await usecase.execute(), RequestAppReviewResult.skippedInFlight);
    expect(review.requestCount, 0);
  });

  test('条件成立で request と抑止', () async {
    await completeMain();
    expect(await usecase.execute(), RequestAppReviewResult.requested);
    expect(review.requestCount, 1);
    expect(await suppression.isSuppressed(), isTrue);
  });

  test('request 例外でも抑止する', () async {
    await completeMain();
    review.throwOnRequest = true;
    expect(await usecase.execute(), RequestAppReviewResult.requested);
    expect(review.requestCount, 1);
    expect(await suppression.isSuppressed(), isTrue);
  });
}

final class _FailingTutorialRepository implements TutorialRepository {
  @override
  Future<TutorialProgress> read() async {
    throw StateError('read failed');
  }

  @override
  Future<void> write(TutorialProgress progress) async {}
}
