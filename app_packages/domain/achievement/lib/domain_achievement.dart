/// アチーブメントの定義・進捗・評価。
///
/// 運動履歴から達成状況を算出し、獲得記録の型も提供する。
///
/// Example:
/// ```dart
/// final progress = AchievementEvaluator.evaluate(
///   histories,
///   DateTime(2026, 11, 10),
/// );
/// ```
library;

export 'src/achievement_catalog.dart';
export 'src/achievement_criterion.dart';
export 'src/achievement_definition.dart';
export 'src/achievement_evaluator.dart';
export 'src/achievement_id.dart';
export 'src/achievement_local_date.dart';
export 'src/achievement_progress.dart';
export 'src/achievement_unlock.dart';
