import '../../achievement_labels.dart';
import '../../strings.dart';
import '../entity/achievement_row_entity.dart';
import '../entity/achievement_screen_entity.dart';
import '../state/achievement_screen_state.dart';

/// State を表示用 Entity へ写す。
///
/// Example:
/// ```dart
/// const AchievementStateToEntityDelegate();
/// ```
final class AchievementStateToEntityDelegate {
  /// 変換委譲を作る。
  ///
  /// Example:
  /// ```dart
  /// const AchievementStateToEntityDelegate();
  /// ```
  const AchievementStateToEntityDelegate();

  /// [state] を Entity にする。未開放名はロック表示に差し替える。
  ///
  /// Example:
  /// ```dart
  /// const AchievementStateToEntityDelegate().execute(
  ///   AchievementScreenState.initial,
  /// );
  /// ```
  AchievementScreenEntity execute(AchievementScreenState state) {
    return switch (state) {
      AchievementScreenLoading() => const AchievementScreenLoadingEntity(),
      AchievementScreenFailed() => const AchievementScreenFailedEntity(),
      AchievementScreenReady(:final rows) => AchievementScreenReadyEntity([
        for (final row in rows)
          AchievementRowEntity(
            id: row.id,
            name: row.unlocked
                ? resolveAchievementName(row.id)
                : strings.screen_feature_achievement_locked_name,
            condition: resolveAchievementCondition(row.id),
            unlocked: row.unlocked,
            progressRatio: row.progressRatio,
            isNew: row.isNew,
          ),
      ]),
    };
  }
}
