import 'package:data_repository_app_review/data_repository_app_review.dart';
import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:foundation_metadata/foundation_metadata.dart';
import 'package:infra_app_review/infra_app_review.dart';
import 'package:usecase_request_app_review/usecase_request_app_review.dart';

/// 条件判定のうえ [AppInAppReview.requestReview] を呼ぶ。
///
/// Example:
/// ```dart
/// RequestAppReviewUsecaseImpl(
///   review: FakeAppInAppReview(),
///   suppression: MemoryAppReviewSuppressionRepository(),
///   tutorial: MemoryTutorialRepository(),
///   session: AppReviewRuntimeSession(),
/// );
/// ```
final class RequestAppReviewUsecaseImpl implements RequestAppReviewUsecase {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// RequestAppReviewUsecaseImpl(
  ///   review: review,
  ///   suppression: suppression,
  ///   tutorial: tutorial,
  ///   session: session,
  /// );
  /// ```
  RequestAppReviewUsecaseImpl({
    required this.review,
    required this.suppression,
    required this.tutorial,
    required this.session,
  });

  /// OS レビュー API。
  final AppInAppReview review;

  /// 抑止状態。
  final AppReviewSuppressionRepository suppression;

  /// チュートリアル進捗。
  final TutorialRepository tutorial;

  /// プロセス内の二重実行防止。
  final AppReviewRuntimeSession session;

  /// flavor・抑止・完了・可用性を見て必要なら依頼する。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<RequestAppReviewResult> execute() async {
    if (Defines.FLAVOR != 'production') {
      return RequestAppReviewResult.skippedFlavor;
    }
    if (session.requestInFlight) {
      return RequestAppReviewResult.skippedInFlight;
    }
    session.requestInFlight = true;
    try {
      if (await suppression.isSuppressed()) {
        return RequestAppReviewResult.skippedSuppressed;
      }
      final TutorialProgress progress;
      try {
        progress = await tutorial.read();
      } on Object {
        return RequestAppReviewResult.skippedTutorial;
      }
      if (!progress.mainCompleted) {
        return RequestAppReviewResult.skippedTutorial;
      }
      final bool available;
      try {
        available = await review.isAvailable();
      } on Object {
        // 可用性確認の失敗は利用不可と同じ扱い。抑止しない。
        return RequestAppReviewResult.skippedUnavailable;
      }
      if (!available) {
        return RequestAppReviewResult.skippedUnavailable;
      }
      try {
        await review.requestReview();
      } on Object {
        // 利用者向けエラーは出さない。
      }
      try {
        await suppression.markSuppressed();
      } on Object {
        // 書込失敗時は再試行しうる。
      }
      return RequestAppReviewResult.requested;
    } finally {
      session.requestInFlight = false;
    }
  }
}
