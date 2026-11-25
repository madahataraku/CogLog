import 'package:infra_app_review/infra_app_review.dart';

/// 非モバイル等でレビュー API を使えないときの実装。
///
/// Example:
/// ```dart
/// const UnavailableAppInAppReview();
/// ```
final class UnavailableAppInAppReview implements AppInAppReview {
  /// 常に利用不可の実装を作る。
  ///
  /// Example:
  /// ```dart
  /// const UnavailableAppInAppReview();
  /// ```
  const UnavailableAppInAppReview();

  /// 常に false。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableAppInAppReview().isAvailable();
  /// ```
  @override
  Future<bool> isAvailable() async => false;

  /// 何もしない。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableAppInAppReview().requestReview();
  /// ```
  @override
  Future<void> requestReview() async {}
}
