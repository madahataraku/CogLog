import 'package:riverpod/riverpod.dart';

import 'app_review_runtime_session.dart';

/// プロセス内のレビュー依頼セッション。
///
/// Example:
/// ```dart
/// appReviewRuntimeSessionProvider;
/// ```
final appReviewRuntimeSessionProvider = Provider<AppReviewRuntimeSession>((
  ref,
) {
  ref.keepAlive();
  return AppReviewRuntimeSession();
});
