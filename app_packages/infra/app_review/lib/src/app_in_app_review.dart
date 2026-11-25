import 'package:riverpod/riverpod.dart';

/// OS のアプリ内レビュー API への窓口。
///
/// Example:
/// ```dart
/// await review.isAvailable();
/// ```
abstract interface class AppInAppReview {
  /// レビュー UI を出せるか。
  ///
  /// Example:
  /// ```dart
  /// await review.isAvailable();
  /// ```
  Future<bool> isAvailable();

  /// アプリ内レビューを依頼する。
  ///
  /// Example:
  /// ```dart
  /// await review.requestReview();
  /// ```
  Future<void> requestReview();
}

/// アプリ内レビューの注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// appInAppReviewProvider;
/// ```
final appInAppReviewProvider = Provider<AppInAppReview>(
  (ref) => throw UnimplementedError('appInAppReviewProvider'),
);
