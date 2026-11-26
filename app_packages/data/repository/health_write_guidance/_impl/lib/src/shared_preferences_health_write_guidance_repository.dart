import 'package:data_repository_health_write_guidance/data_repository_health_write_guidance.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 提示済みを `health_write_guidance_seen` へ bool で残す。
///
/// Example:
/// ```dart
/// SharedPreferencesHealthWriteGuidanceRepository(preferences).isSeen();
/// ```
final class SharedPreferencesHealthWriteGuidanceRepository
    implements HealthWriteGuidanceRepository {
  /// [preferences] へ読み書きする。
  ///
  /// Example:
  /// ```dart
  /// SharedPreferencesHealthWriteGuidanceRepository(preferences);
  /// ```
  const SharedPreferencesHealthWriteGuidanceRepository(this._preferences);

  /// 提示済みフラグのキー。
  static const _key = 'health_write_guidance_seen';

  /// 読み書き先。
  final SharedPreferences _preferences;

  /// 未保存は false。
  ///
  /// Example:
  /// ```dart
  /// repository.isSeen();
  /// ```
  @override
  Future<bool> isSeen() async => _preferences.getBool(_key) ?? false;

  /// 提示済みを true で書く。
  ///
  /// Example:
  /// ```dart
  /// repository.markSeen();
  /// ```
  @override
  Future<void> markSeen() async {
    var saved = false;
    try {
      saved = await _preferences.setBool(_key, true);
    } on Object {
      await _preferences.reload();
      rethrow;
    }
    if (!saved) {
      await _preferences.reload();
      throw StateError('$_key を保存できなかった。');
    }
  }
}
