import 'dart:convert';

import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// チュートリアル進捗を SharedPreferences の JSON オブジェクトへ残す。
///
/// Example:
/// ```dart
/// SharedPreferencesTutorialRepository(preferences).read();
/// ```
final class SharedPreferencesTutorialRepository implements TutorialRepository {
  /// [preferences] へ読み書きする。
  ///
  /// Example:
  /// ```dart
  /// SharedPreferencesTutorialRepository(preferences);
  /// ```
  const SharedPreferencesTutorialRepository(this._preferences);

  /// JSON オブジェクトのキー。
  static const _progressKey = 'tutorial_progress';

  /// 読み書き先。
  final SharedPreferences _preferences;

  /// キー無し・JSON 不正・必須 bool 欠落は [TutorialProgress.initial]。
  ///
  /// 新フィールド欠落は既定値（goalSettings=false、mainReachedStep は完了なら 7）。
  ///
  /// Example:
  /// ```dart
  /// repository.read();
  /// ```
  @override
  Future<TutorialProgress> read() async {
    final raw = _preferences.getString(_progressKey);
    if (raw == null || raw.isEmpty) {
      return TutorialProgress.initial;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return TutorialProgress.initial;
      }
      final map = decoded.cast<Object?, Object?>();
      final mainCompleted = _requireBool(map, 'mainCompleted');
      return TutorialProgress(
        mainCompleted: mainCompleted,
        mainReachedStep: _optionalInt(
          map,
          'mainReachedStep',
          fallback: mainCompleted ? 7 : 0,
        ),
        goalSettingsContextSeen: _optionalBool(
          map,
          'goalSettingsContextSeen',
          fallback: false,
        ),
        cameraContextSeen: _requireBool(map, 'cameraContextSeen'),
        meterEditContextSeen: _requireBool(map, 'meterEditContextSeen'),
        trendsContextSeen: _requireBool(map, 'trendsContextSeen'),
        historyContextSeen: _requireBool(map, 'historyContextSeen'),
        achievementContextSeen: _requireBool(map, 'achievementContextSeen'),
      );
    } on Object {
      return TutorialProgress.initial;
    }
  }

  /// [progress] を JSON で書く。失敗時は reload のうえ例外を返す。
  ///
  /// Example:
  /// ```dart
  /// repository.write(TutorialProgress.initial.copyWith(mainCompleted: true));
  /// ```
  @override
  Future<void> write(TutorialProgress progress) async {
    final payload = jsonEncode(<String, Object?>{
      'mainCompleted': progress.mainCompleted,
      'mainReachedStep': progress.mainReachedStep,
      'goalSettingsContextSeen': progress.goalSettingsContextSeen,
      'cameraContextSeen': progress.cameraContextSeen,
      'meterEditContextSeen': progress.meterEditContextSeen,
      'trendsContextSeen': progress.trendsContextSeen,
      'historyContextSeen': progress.historyContextSeen,
      'achievementContextSeen': progress.achievementContextSeen,
    });
    var saved = false;
    try {
      saved = await _preferences.setString(_progressKey, payload);
    } on Object {
      await _preferences.reload();
      rethrow;
    }
    if (!saved) {
      await _preferences.reload();
      throw StateError('$_progressKey を保存できなかった。');
    }
  }

  /// [map] の [key] を真偽値として取り出す。
  ///
  /// 欠落・非 bool は [FormatException]。
  static bool _requireBool(Map<Object?, Object?> map, String key) {
    final value = map[key];
    if (value is! bool) {
      throw FormatException('$key が真偽値でない');
    }
    return value;
  }

  /// 新フィールド用。欠落は [fallback]、非 bool は [FormatException]。
  static bool _optionalBool(
    Map<Object?, Object?> map,
    String key, {
    required bool fallback,
  }) {
    if (!map.containsKey(key)) {
      return fallback;
    }
    return _requireBool(map, key);
  }

  /// 新フィールド用。欠落は [fallback]、非 int は [FormatException]。
  static int _optionalInt(
    Map<Object?, Object?> map,
    String key, {
    required int fallback,
  }) {
    if (!map.containsKey(key)) {
      return fallback;
    }
    final value = map[key];
    if (value is! int) {
      throw FormatException('$key が整数でない');
    }
    return value;
  }
}
