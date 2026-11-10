import 'package:riverpod/riverpod.dart';

import 'load_achievements_request.dart';
import 'load_achievements_result.dart';

/// アチーブメント一覧を画面向けに読み込む。
///
/// Example:
/// ```dart
/// usecase.execute(LoadAchievementsRequest(now: DateTime.timestamp()));
/// ```
abstract interface class LoadAchievementsUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<LoadAchievementsUsecase>(
    (ref) => throw UnimplementedError('LoadAchievementsUsecase.provider'),
  );

  /// [request] の基準時刻で進捗を算出し、獲得状態と合わせて返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(LoadAchievementsRequest(now: DateTime.timestamp()));
  /// ```
  Future<LoadAchievementsResult> execute(LoadAchievementsRequest request);
}
