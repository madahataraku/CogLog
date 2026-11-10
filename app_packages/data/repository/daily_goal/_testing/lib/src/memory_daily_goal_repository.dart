import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';

/// メモリ上の 1 つの一日あたり目標。初期値は未設定。
///
/// Example:
/// ```dart
/// final repository = MemoryDailyGoalRepository();
/// repository.write(const DailyGoal(caloriesKcal: 0));
/// ```
final class MemoryDailyGoalRepository implements DailyGoalRepository {
  /// 未設定の状態で作る。
  ///
  /// Example:
  /// ```dart
  /// MemoryDailyGoalRepository();
  /// ```
  MemoryDailyGoalRepository();

  DailyGoal _goal = DailyGoal.unset;
  DailyGoalAutoUpdateSettings _autoUpdate =
      DailyGoalAutoUpdateSettings.defaults;

  /// まだ書いていなければ [DailyGoal.unset]。
  ///
  /// Example:
  /// ```dart
  /// repository.read();
  /// ```
  @override
  Future<DailyGoal> read() async => _goal;

  /// [goal] を次の [read] で返す。
  ///
  /// Example:
  /// ```dart
  /// repository.write(const DailyGoal(distanceKm: 0));
  /// ```
  @override
  Future<void> write(DailyGoal goal) async {
    _goal = goal;
  }

  /// まだ書いていなければ [DailyGoalAutoUpdateSettings.defaults]。
  ///
  /// Example:
  /// ```dart
  /// repository.readAutoUpdateSettings();
  /// ```
  @override
  Future<DailyGoalAutoUpdateSettings> readAutoUpdateSettings() async =>
      _autoUpdate;

  /// [settings] を次の [readAutoUpdateSettings] で返す。
  ///
  /// Example:
  /// ```dart
  /// repository.writeAutoUpdateSettings(DailyGoalAutoUpdateSettings.defaults);
  /// ```
  @override
  Future<void> writeAutoUpdateSettings(
    DailyGoalAutoUpdateSettings settings,
  ) async {
    _autoUpdate = settings;
  }

  /// 目標と自動更新設定をまとめて上書きする。
  ///
  /// Example:
  /// ```dart
  /// repository.writeGoalAndAutoUpdateSettings(
  ///   goal: DailyGoal.unset,
  ///   settings: DailyGoalAutoUpdateSettings.defaults,
  /// );
  /// ```
  @override
  Future<void> writeGoalAndAutoUpdateSettings({
    required DailyGoal goal,
    required DailyGoalAutoUpdateSettings settings,
  }) async {
    _goal = goal;
    _autoUpdate = settings;
  }
}
