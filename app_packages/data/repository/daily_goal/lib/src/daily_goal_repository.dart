import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:riverpod/riverpod.dart';

/// 一日あたりの運動目標をプロセス終了後も残す。
///
/// Example:
/// ```dart
/// repository.read();
/// ```
abstract interface class DailyGoalRepository {
  /// 保存が無ければ [DailyGoal.unset]。
  ///
  /// Example:
  /// ```dart
  /// repository.read();
  /// ```
  Future<DailyGoal> read();

  /// [goal] を保存する。指標が null のときは当該キーを消す。
  ///
  /// Example:
  /// ```dart
  /// repository.write(DailyGoal.unset);
  /// ```
  Future<void> write(DailyGoal goal);

  /// 自動更新設定を読む。キーが無ければ [DailyGoalAutoUpdateSettings.defaults]。
  ///
  /// Example:
  /// ```dart
  /// repository.readAutoUpdateSettings();
  /// ```
  Future<DailyGoalAutoUpdateSettings> readAutoUpdateSettings();

  /// 自動更新設定を保存する。
  ///
  /// Example:
  /// ```dart
  /// repository.writeAutoUpdateSettings(DailyGoalAutoUpdateSettings.defaults);
  /// ```
  Future<void> writeAutoUpdateSettings(DailyGoalAutoUpdateSettings settings);

  /// 目標と自動更新設定をまとめて保存する。
  ///
  /// 途中で失敗したら変更前へ戻す。復元にも失敗したら、保存失敗と復元失敗の
  /// 両方を含む例外を投げる。
  ///
  /// Example:
  /// ```dart
  /// repository.writeGoalAndAutoUpdateSettings(
  ///   goal: DailyGoal.unset,
  ///   settings: DailyGoalAutoUpdateSettings.defaults,
  /// );
  /// ```
  Future<void> writeGoalAndAutoUpdateSettings({
    required DailyGoal goal,
    required DailyGoalAutoUpdateSettings settings,
  });
}

/// 一日あたり目標 Repository の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// dailyGoalRepositoryProvider;
/// ```
final dailyGoalRepositoryProvider = Provider<DailyGoalRepository>(
  (ref) => throw UnimplementedError('dailyGoalRepositoryProvider'),
);
