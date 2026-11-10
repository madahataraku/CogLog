import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 一日あたり目標を SharedPreferences の 3 キーへ残す。
///
/// Example:
/// ```dart
/// SharedPreferencesDailyGoalRepository(preferences).read();
/// ```
final class SharedPreferencesDailyGoalRepository
    implements DailyGoalRepository {
  /// [preferences] へ読み書きする。
  ///
  /// Example:
  /// ```dart
  /// SharedPreferencesDailyGoalRepository(preferences);
  /// ```
  const SharedPreferencesDailyGoalRepository(this._preferences);

  /// 運動時間（秒）を保存するキー。
  static const _durationSecondsKey = 'daily_goal_duration_seconds';

  /// 消費カロリー（kcal）を保存するキー。
  static const _caloriesKcalKey = 'daily_goal_calories_kcal';

  /// 走行距離（km）を保存するキー。
  static const _distanceKmKey = 'daily_goal_distance_km';

  /// 自動更新の有効フラグ。
  static const _autoUpdateEnabledKey = 'daily_goal_auto_update_enabled';

  /// 自動更新レベル。
  static const _autoUpdateLevelKey = 'daily_goal_auto_update_level';

  /// 有効化した現地日付（yyyy-MM-dd）。
  static const _autoUpdateEnabledOnKey = 'daily_goal_auto_update_enabled_on';

  /// 連続達成の起算日（yyyy-MM-dd）。
  static const _autoUpdateStreakEpochKey =
      'daily_goal_auto_update_streak_epoch';

  /// 直近の上方修正日（yyyy-MM-dd）。
  static const _autoUpdateLastAppliedKey =
      'daily_goal_auto_update_last_applied';

  /// 読み書き先。
  final SharedPreferences _preferences;

  /// キー無しは未設定。有り（0 含む）は設定済み。
  ///
  /// Example:
  /// ```dart
  /// repository.read();
  /// ```
  @override
  Future<DailyGoal> read() async {
    final durationSeconds = _preferences.getInt(_durationSecondsKey);
    final caloriesKcal = _preferences.getDouble(_caloriesKcalKey);
    final distanceKm = _preferences.getDouble(_distanceKmKey);
    return DailyGoal(
      duration: durationSeconds == null
          ? null
          : Duration(seconds: durationSeconds),
      caloriesKcal: caloriesKcal,
      distanceKm: distanceKm,
    );
  }

  /// 指標ごと、null ならキー削除、非 null なら書き込む。
  ///
  /// Example:
  /// ```dart
  /// repository.write(const DailyGoal(caloriesKcal: 0));
  /// ```
  @override
  Future<void> write(DailyGoal goal) async {
    final duration = goal.duration;
    if (duration == null) {
      await _remove(_durationSecondsKey);
    } else {
      await _setInt(_durationSecondsKey, duration.inSeconds);
    }

    final caloriesKcal = goal.caloriesKcal;
    if (caloriesKcal == null) {
      await _remove(_caloriesKcalKey);
    } else {
      await _setDouble(_caloriesKcalKey, caloriesKcal);
    }

    final distanceKm = goal.distanceKm;
    if (distanceKm == null) {
      await _remove(_distanceKmKey);
    } else {
      await _setDouble(_distanceKmKey, distanceKm);
    }
  }

  /// キーが無ければ [DailyGoalAutoUpdateSettings.defaults]。
  ///
  /// Example:
  /// ```dart
  /// repository.readAutoUpdateSettings();
  /// ```
  @override
  Future<DailyGoalAutoUpdateSettings> readAutoUpdateSettings() async {
    final enabled = _preferences.getBool(_autoUpdateEnabledKey) ?? false;
    final level = _parseLevel(_preferences.getString(_autoUpdateLevelKey));
    return DailyGoalAutoUpdateSettings(
      enabled: enabled,
      level: level,
      enabledOnLocalDate: _parseDate(
        _preferences.getString(_autoUpdateEnabledOnKey),
      ),
      streakEpochLocalDate: _parseDate(
        _preferences.getString(_autoUpdateStreakEpochKey),
      ),
      lastAppliedLocalDate: _parseDate(
        _preferences.getString(_autoUpdateLastAppliedKey),
      ),
    );
  }

  /// 自動更新設定をキーへ書く。null 日付はキー削除。
  ///
  /// Example:
  /// ```dart
  /// repository.writeAutoUpdateSettings(DailyGoalAutoUpdateSettings.defaults);
  /// ```
  @override
  Future<void> writeAutoUpdateSettings(
    DailyGoalAutoUpdateSettings settings,
  ) async {
    await _setBool(_autoUpdateEnabledKey, settings.enabled);
    await _setString(_autoUpdateLevelKey, _levelName(settings.level));
    await _writeDate(_autoUpdateEnabledOnKey, settings.enabledOnLocalDate);
    await _writeDate(_autoUpdateStreakEpochKey, settings.streakEpochLocalDate);
    await _writeDate(_autoUpdateLastAppliedKey, settings.lastAppliedLocalDate);
  }

  static DailyGoalAutoUpdateLevel _parseLevel(String? raw) {
    return switch (raw) {
      'slow' => DailyGoalAutoUpdateLevel.slow,
      'challenging' => DailyGoalAutoUpdateLevel.challenging,
      _ => DailyGoalAutoUpdateLevel.normal,
    };
  }

  static String _levelName(DailyGoalAutoUpdateLevel level) {
    return switch (level) {
      DailyGoalAutoUpdateLevel.slow => 'slow',
      DailyGoalAutoUpdateLevel.normal => 'normal',
      DailyGoalAutoUpdateLevel.challenging => 'challenging',
    };
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final parts = raw.split('-');
    if (parts.length != 3) {
      return null;
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _writeDate(String key, DateTime? date) async {
    if (date == null) {
      await _remove(key);
    } else {
      await _setString(key, _formatDate(date));
    }
  }

  /// [key] を整数で書く。失敗時は reload して例外を返す。
  Future<void> _setInt(String key, int value) async {
    var saved = false;
    try {
      saved = await _preferences.setInt(key, value);
    } on Object {
      await _preferences.reload();
      rethrow;
    }
    if (!saved) {
      await _preferences.reload();
      throw StateError('$key を保存できなかった。');
    }
  }

  /// [key] を小数で書く。失敗時は reload して例外を返す。
  Future<void> _setDouble(String key, double value) async {
    var saved = false;
    try {
      saved = await _preferences.setDouble(key, value);
    } on Object {
      await _preferences.reload();
      rethrow;
    }
    if (!saved) {
      await _preferences.reload();
      throw StateError('$key を保存できなかった。');
    }
  }

  /// [key] を真偽値で書く。失敗時は reload して例外を返す。
  Future<void> _setBool(String key, bool value) async {
    var saved = false;
    try {
      saved = await _preferences.setBool(key, value);
    } on Object {
      await _preferences.reload();
      rethrow;
    }
    if (!saved) {
      await _preferences.reload();
      throw StateError('$key を保存できなかった。');
    }
  }

  /// [key] を文字列で書く。失敗時は reload して例外を返す。
  Future<void> _setString(String key, String value) async {
    var saved = false;
    try {
      saved = await _preferences.setString(key, value);
    } on Object {
      await _preferences.reload();
      rethrow;
    }
    if (!saved) {
      await _preferences.reload();
      throw StateError('$key を保存できなかった。');
    }
  }

  /// [key] を消す。失敗時は reload して例外を返す。
  Future<void> _remove(String key) async {
    var removed = false;
    try {
      removed = await _preferences.remove(key);
    } on Object {
      await _preferences.reload();
      rethrow;
    }
    if (!removed) {
      await _preferences.reload();
      throw StateError('$key を削除できなかった。');
    }
  }
}
