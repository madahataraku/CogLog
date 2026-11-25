import 'package:state_stream/state_stream.dart';
import 'package:usecase_request_app_review/usecase_request_app_review.dart';

import '../state/top_screen_state.dart';

/// Ready 後にアプリ内レビュー依頼 Usecase を呼ぶ。
///
/// Example:
/// ```dart
/// OnEvaluateAppReviewDelegate(
///   state: state,
///   usecase: usecase,
/// ).execute();
/// ```
final class OnEvaluateAppReviewDelegate {
  /// State と Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnEvaluateAppReviewDelegate(state: state, usecase: usecase);
  /// ```
  const OnEvaluateAppReviewDelegate({
    required this.state,
    required this.usecase,
  });

  /// 画面状態。
  final MutableStateStream<TopScreenState> state;

  /// レビュー依頼。
  final RequestAppReviewUsecase usecase;

  /// loaded でなければ何もしない。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    if (!state.state.loaded) {
      return;
    }
    await usecase.execute();
  }
}
