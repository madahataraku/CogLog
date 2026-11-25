import 'package:riverpod/riverpod.dart';

/// アプリ内レビュー依頼の抑止状態を残す。
///
/// Example:
/// ```dart
/// repository.isSuppressed();
/// ```
abstract interface class AppReviewSuppressionRepository {
  /// 抑止済みなら true。
  ///
  /// Example:
  /// ```dart
  /// repository.isSuppressed();
  /// ```
  Future<bool> isSuppressed();

  /// 抑止済みにする。
  ///
  /// Example:
  /// ```dart
  /// repository.markSuppressed();
  /// ```
  Future<void> markSuppressed();
}

/// 抑止 Repository の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// appReviewSuppressionRepositoryProvider;
/// ```
final appReviewSuppressionRepositoryProvider =
    Provider<AppReviewSuppressionRepository>(
      (ref) =>
          throw UnimplementedError('appReviewSuppressionRepositoryProvider'),
    );
