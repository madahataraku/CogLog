import 'package:infra_app_review/infra_app_review.dart';

/// テスト用のアプリ内レビュー。呼び出し回数だけ数える。
///
/// Example:
/// ```dart
/// FakeAppInAppReview();
/// ```
final class FakeAppInAppReview implements AppInAppReview {
  /// [available] と例外可否を持つ実装を作る。
  ///
  /// Example:
  /// ```dart
  /// FakeAppInAppReview(available: false);
  /// ```
  FakeAppInAppReview({
    this.available = true,
    this.throwOnRequest = false,
    this.throwOnIsAvailable = false,
  });

  /// [isAvailable] が返す値。
  bool available;

  /// [requestReview] で例外を投げるか。
  bool throwOnRequest;

  /// [isAvailable] で例外を投げるか。
  bool throwOnIsAvailable;

  /// [requestReview] が呼ばれた回数。
  int requestCount = 0;

  /// [available] を返す。例外設定時は投げる。
  ///
  /// Example:
  /// ```dart
  /// await FakeAppInAppReview().isAvailable();
  /// ```
  @override
  Future<bool> isAvailable() async {
    if (throwOnIsAvailable) {
      throw StateError('isAvailable failed');
    }
    return available;
  }

  /// 回数を増やし、必要なら例外を投げる。
  ///
  /// Example:
  /// ```dart
  /// await FakeAppInAppReview().requestReview();
  /// ```
  @override
  Future<void> requestReview() async {
    requestCount += 1;
    if (throwOnRequest) {
      throw StateError('requestReview failed');
    }
  }
}
