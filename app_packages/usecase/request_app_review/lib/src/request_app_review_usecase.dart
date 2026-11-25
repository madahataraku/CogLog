import 'package:riverpod/riverpod.dart';

import 'request_app_review_result.dart';

/// 条件を満たせば OS アプリ内レビューを依頼する。
///
/// Example:
/// ```dart
/// await usecase.execute();
/// ```
abstract interface class RequestAppReviewUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<RequestAppReviewUsecase>(
    (ref) => throw UnimplementedError('RequestAppReviewUsecase.provider'),
  );

  /// 依頼可否を判定し、必要なら requestReview する。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<RequestAppReviewResult> execute();
}
