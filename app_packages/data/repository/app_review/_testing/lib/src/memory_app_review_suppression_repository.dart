import 'package:data_repository_app_review/data_repository_app_review.dart';

/// メモリ上だけ抑止を持つテスト用 Repository。
///
/// Example:
/// ```dart
/// MemoryAppReviewSuppressionRepository();
/// ```
final class MemoryAppReviewSuppressionRepository
    implements AppReviewSuppressionRepository {
  /// 未抑止から始める。
  ///
  /// Example:
  /// ```dart
  /// MemoryAppReviewSuppressionRepository();
  /// ```
  MemoryAppReviewSuppressionRepository({this.suppressed = false});

  /// メモリ上の抑止フラグ。
  bool suppressed;

  /// 現在の抑止状態を返す。
  ///
  /// Example:
  /// ```dart
  /// await MemoryAppReviewSuppressionRepository().isSuppressed();
  /// ```
  @override
  Future<bool> isSuppressed() async => suppressed;

  /// 抑止済みにする。
  ///
  /// Example:
  /// ```dart
  /// await MemoryAppReviewSuppressionRepository().markSuppressed();
  /// ```
  @override
  Future<void> markSuppressed() async {
    suppressed = true;
  }
}
