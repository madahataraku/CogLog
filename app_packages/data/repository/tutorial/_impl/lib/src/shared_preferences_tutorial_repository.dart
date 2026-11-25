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
      return TutorialProgress(
        mainCompleted: _requireBool(map, 'mainCompleted'),
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
  ///
  /// Example:
  /// ```dart
  /// SharedPreferencesTutorialRepository._requireBool(
  ///   {'mainCompleted': true},
  ///   'mainCompleted',
  /// );
  /// ```
  static bool _requireBool(Map<Object?, Object?> map, String key) {
    final value = map[key];
    if (value is! bool) {
      throw FormatException('$key が真偽値でない');
    }
    return value;
  }
}
