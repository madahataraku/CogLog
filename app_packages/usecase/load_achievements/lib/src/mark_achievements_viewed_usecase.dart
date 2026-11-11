import 'package:riverpod/riverpod.dart';

import 'mark_achievements_viewed_request.dart';

/// アチーブメント一覧の最終閲覧日時を残す。
///
/// Example:
/// ```dart
/// MarkAchievementsViewedUsecase.provider;
/// ```
abstract interface class MarkAchievementsViewedUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// MarkAchievementsViewedUsecase.provider;
  /// ```
  static final provider = Provider<MarkAchievementsViewedUsecase>(
    (ref) => throw UnimplementedError('MarkAchievementsViewedUsecase.provider'),
  );

  /// 最終閲覧日時を [request.now] で上書きする。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   MarkAchievementsViewedRequest(now: DateTime.timestamp()),
  /// );
  /// ```
  Future<void> execute(MarkAchievementsViewedRequest request);
}
