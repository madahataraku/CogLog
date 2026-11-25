import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/on_evaluate_app_review_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/state/top_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_request_app_review/usecase_request_app_review.dart';

void main() {
  test('loaded でなければ usecase を呼ばない', () async {
    final usecase = _CountingRequestAppReviewUsecase();
    final state = MutableStateStream(TopScreenState.initial);
    await OnEvaluateAppReviewDelegate(state: state, usecase: usecase).execute();
    expect(usecase.callCount, 0);
  });

  test('loaded なら usecase を呼ぶ', () async {
    final usecase = _CountingRequestAppReviewUsecase();
    final state = MutableStateStream(
      TopScreenState.initial.copyWith(loaded: true),
    );
    await OnEvaluateAppReviewDelegate(state: state, usecase: usecase).execute();
    expect(usecase.callCount, 1);
  });
}

final class _CountingRequestAppReviewUsecase
    implements RequestAppReviewUsecase {
  int callCount = 0;

  @override
  Future<RequestAppReviewResult> execute() async {
    callCount += 1;
    return RequestAppReviewResult.skippedFlavor;
  }
}
