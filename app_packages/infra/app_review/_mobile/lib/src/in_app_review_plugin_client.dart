import 'package:in_app_review/in_app_review.dart';
import 'package:infra_app_review/infra_app_review.dart';

/// [InAppReview] プラグインで OS のアプリ内レビューを呼ぶ。
///
/// Example:
/// ```dart
/// const InAppReviewPluginClient();
/// ```
final class InAppReviewPluginClient implements AppInAppReview {
  /// プラグイン経由の実装を作る。
  ///
  /// Example:
  /// ```dart
  /// const InAppReviewPluginClient();
  /// ```
  const InAppReviewPluginClient();

  /// レビュー UI を出せるか。
  ///
  /// Example:
  /// ```dart
  /// await const InAppReviewPluginClient().isAvailable();
  /// ```
  @override
  Future<bool> isAvailable() => InAppReview.instance.isAvailable();

  /// アプリ内レビューを依頼する。
  ///
  /// Example:
  /// ```dart
  /// await const InAppReviewPluginClient().requestReview();
  /// ```
  @override
  Future<void> requestReview() => InAppReview.instance.requestReview();
}
