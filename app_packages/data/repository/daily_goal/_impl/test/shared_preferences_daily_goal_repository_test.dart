import 'package:data_repository_daily_goal_impl/data_repository_daily_goal_impl.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  tearDown(SharedPreferences.resetStatic);

  test('未保存は unset', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    final goal = await repository.read();
    expect(goal.duration, isNull);
    expect(goal.caloriesKcal, isNull);
    expect(goal.distanceKm, isNull);
  });

  test('0 を書いて読める', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.write(
      const DailyGoal(duration: Duration.zero, caloriesKcal: 0, distanceKm: 0),
    );

    final goal = await repository.read();
    expect(goal.duration, Duration.zero);
    expect(goal.caloriesKcal, 0);
    expect(goal.distanceKm, 0);
  });

  test('値を書いて読める', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.write(
      const DailyGoal(
        duration: Duration(hours: 1, minutes: 30, seconds: 15),
        caloriesKcal: 200.5,
        distanceKm: 5.25,
      ),
    );

    final goal = await repository.read();
    expect(goal.duration, const Duration(hours: 1, minutes: 30, seconds: 15));
    expect(goal.caloriesKcal, 200.5);
    expect(goal.distanceKm, 5.25);
  });

  test('null を書くとキーが消える', () async {
    SharedPreferences.setMockInitialValues({
      'daily_goal_duration_seconds': 90,
      'daily_goal_calories_kcal': 100.0,
      'daily_goal_distance_km': 3.0,
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.write(DailyGoal.unset);

    expect(preferences.containsKey('daily_goal_duration_seconds'), isFalse);
    expect(preferences.containsKey('daily_goal_calories_kcal'), isFalse);
    expect(preferences.containsKey('daily_goal_distance_km'), isFalse);

    final goal = await repository.read();
    expect(goal.duration, isNull);
    expect(goal.caloriesKcal, isNull);
    expect(goal.distanceKm, isNull);
  });

  test('自動更新設定の欠落は defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    final settings = await repository.readAutoUpdateSettings();
    expect(settings.enabled, isFalse);
    expect(settings.level, DailyGoalAutoUpdateLevel.normal);
    expect(settings.enabledOnLocalDate, isNull);
  });

  test('自動更新設定を書いて読める', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.writeAutoUpdateSettings(
      DailyGoalAutoUpdateSettings(
        enabled: true,
        level: DailyGoalAutoUpdateLevel.challenging,
        enabledOnLocalDate: DateTime(2026, 11, 5),
        streakEpochLocalDate: DateTime(2026, 11, 6),
        lastAppliedLocalDate: DateTime(2026, 11, 5),
      ),
    );

    final settings = await repository.readAutoUpdateSettings();
    expect(settings.enabled, isTrue);
    expect(settings.level, DailyGoalAutoUpdateLevel.challenging);
    expect(settings.enabledOnLocalDate, DateTime(2026, 11, 5));
    expect(settings.streakEpochLocalDate, DateTime(2026, 11, 6));
    expect(settings.lastAppliedLocalDate, DateTime(2026, 11, 5));
  });

  test('目標と自動更新設定をまとめて書いて読める', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.writeGoalAndAutoUpdateSettings(
      goal: const DailyGoal(caloriesKcal: 120),
      settings: DailyGoalAutoUpdateSettings(
        enabled: true,
        level: DailyGoalAutoUpdateLevel.slow,
        enabledOnLocalDate: DateTime(2026, 11, 5),
      ),
    );

    final goal = await repository.read();
    final settings = await repository.readAutoUpdateSettings();
    expect(goal.caloriesKcal, 120);
    expect(settings.enabled, isTrue);
    expect(settings.level, DailyGoalAutoUpdateLevel.slow);
    expect(settings.enabledOnLocalDate, DateTime(2026, 11, 5));
  });

  test('未設定を二度書いても例外にならない', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.write(DailyGoal.unset);
    await repository.write(DailyGoal.unset);

    final goal = await repository.read();
    expect(goal.duration, isNull);
    expect(goal.caloriesKcal, isNull);
    expect(goal.distanceKm, isNull);
  });

  for (final level in DailyGoalAutoUpdateLevel.values) {
    test('${level.name} の設定は新しい Repository からも復元できる', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      await SharedPreferencesDailyGoalRepository(preferences)
          .writeAutoUpdateSettings(
            DailyGoalAutoUpdateSettings(enabled: true, level: level),
          );

      final restored = await SharedPreferencesDailyGoalRepository(preferences)
          .readAutoUpdateSettings();
      expect(restored.enabled, isTrue);
      expect(restored.level, level);
    });
  }

  test('未知のレベルと解析できない日付は既定値へ戻す', () async {
    SharedPreferences.setMockInitialValues({
      'daily_goal_auto_update_enabled': true,
      'daily_goal_auto_update_level': 'future-level',
      'daily_goal_auto_update_enabled_on': '',
      'daily_goal_auto_update_streak_epoch': 'not-a-date',
      'daily_goal_auto_update_last_applied': '2026/11/05',
    });
    final repository = SharedPreferencesDailyGoalRepository(
      await SharedPreferences.getInstance(),
    );

    final settings = await repository.readAutoUpdateSettings();
    expect(settings.enabled, isTrue);
    expect(settings.level, DailyGoalAutoUpdateLevel.normal);
    expect(settings.enabledOnLocalDate, isNull);
    expect(settings.streakEpochLocalDate, isNull);
    expect(settings.lastAppliedLocalDate, isNull);
  });

  test('日付の時刻を保存せず null への更新では全日付キーを削除する', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);
    final date = DateTime(2026, 12, 31, 23, 59, 59);
    await repository.writeAutoUpdateSettings(
      DailyGoalAutoUpdateSettings(
        enabled: true,
        level: DailyGoalAutoUpdateLevel.slow,
        enabledOnLocalDate: date,
        streakEpochLocalDate: date,
        lastAppliedLocalDate: date,
      ),
    );
    final stored = await repository.readAutoUpdateSettings();
    expect(stored.enabledOnLocalDate, DateTime(2026, 12, 31));
    expect(stored.streakEpochLocalDate, DateTime(2026, 12, 31));
    expect(stored.lastAppliedLocalDate, DateTime(2026, 12, 31));

    await repository.writeAutoUpdateSettings(
      DailyGoalAutoUpdateSettings.defaults,
    );
    await repository.writeAutoUpdateSettings(
      DailyGoalAutoUpdateSettings.defaults,
    );
    for (final suffix in ['enabled_on', 'streak_epoch', 'last_applied']) {
      expect(
        preferences.containsKey('daily_goal_auto_update_$suffix'),
        isFalse,
      );
    }
    expect((await repository.readAutoUpdateSettings()).enabled, isFalse);
  });

  test('一括保存で既存の目標と設定を未設定・既定値へ置き換える', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesDailyGoalRepository(
      await SharedPreferences.getInstance(),
    );
    await repository.writeGoalAndAutoUpdateSettings(
      goal: const DailyGoal(
        duration: Duration(seconds: 1),
        caloriesKcal: 0.000001,
        distanceKm: 0,
      ),
      settings: DailyGoalAutoUpdateSettings(
        enabled: true,
        level: DailyGoalAutoUpdateLevel.challenging,
        enabledOnLocalDate: DateTime(2026, 11, 5),
      ),
    );
    expect((await repository.read()).caloriesKcal, 0.000001);
    await repository.writeGoalAndAutoUpdateSettings(
      goal: DailyGoal.unset,
      settings: DailyGoalAutoUpdateSettings.defaults,
    );
    expect((await repository.read()).sameAs(DailyGoal.unset), isTrue);
    final settings = await repository.readAutoUpdateSettings();
    expect(settings.enabled, isFalse);
    expect(settings.level, DailyGoalAutoUpdateLevel.normal);
    expect(settings.enabledOnLocalDate, isNull);
  });

  test('一括保存の失敗では目標と設定を変更前へ戻す', () async {
    final store = _ControllablePrefsStore(
      data: <String, Object>{
        'daily_goal_calories_kcal': 50.0,
        'daily_goal_auto_update_enabled': false,
        'daily_goal_auto_update_level': 'slow',
      },
      failingKeySuffixes: <String>{'daily_goal_calories_kcal'},
    );
    SharedPreferencesStorePlatform.instance = store;
    SharedPreferences.resetStatic();
    final repository = SharedPreferencesDailyGoalRepository(
      await SharedPreferences.getInstance(),
    );

    await expectLater(
      repository.writeGoalAndAutoUpdateSettings(
        goal: const DailyGoal(caloriesKcal: 100),
        settings: const DailyGoalAutoUpdateSettings(
          enabled: true,
          level: DailyGoalAutoUpdateLevel.challenging,
        ),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('daily_goal_calories_kcal'),
        ),
      ),
    );

    final goal = await repository.read();
    final settings = await repository.readAutoUpdateSettings();
    expect(goal.caloriesKcal, 50.0);
    expect(settings.enabled, isFalse);
    expect(settings.level, DailyGoalAutoUpdateLevel.slow);
  });

  test('一括保存の復元失敗では StateError に両方の失敗を含める', () async {
    final store = _ControllablePrefsStore(
      data: <String, Object>{
        'daily_goal_calories_kcal': 50.0,
        'daily_goal_auto_update_enabled': false,
        'daily_goal_auto_update_level': 'slow',
      },
      failingKeySuffixes: <String>{'daily_goal_calories_kcal'},
      failAfterFirstFailure: true,
    );
    SharedPreferencesStorePlatform.instance = store;
    SharedPreferences.resetStatic();
    final repository = SharedPreferencesDailyGoalRepository(
      await SharedPreferences.getInstance(),
    );

    await expectLater(
      repository.writeGoalAndAutoUpdateSettings(
        goal: const DailyGoal(caloriesKcal: 100),
        settings: const DailyGoalAutoUpdateSettings(
          enabled: true,
          level: DailyGoalAutoUpdateLevel.challenging,
        ),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          allOf(contains('復元にも失敗'), contains('save=')),
        ),
      ),
    );
  });

  test('削除が false でキーが残る場合は StateError', () async {
    final store = _ControllablePrefsStore(
      data: <String, Object>{'daily_goal_calories_kcal': 50.0},
      failingRemoveSuffixes: <String>{'daily_goal_calories_kcal'},
    );
    SharedPreferencesStorePlatform.instance = store;
    SharedPreferences.resetStatic();
    final repository = SharedPreferencesDailyGoalRepository(
      await SharedPreferences.getInstance(),
    );

    await expectLater(
      repository.write(DailyGoal.unset),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('daily_goal_calories_kcal'),
        ),
      ),
    );
    expect((await repository.read()).caloriesKcal, 50.0);
  });

  test('削除が false でもキーが無ければ成功する', () async {
    final store = _ControllablePrefsStore(
      failingRemoveSuffixes: <String>{
        'daily_goal_duration_seconds',
        'daily_goal_calories_kcal',
        'daily_goal_distance_km',
      },
    );
    SharedPreferencesStorePlatform.instance = store;
    SharedPreferences.resetStatic();
    final repository = SharedPreferencesDailyGoalRepository(
      await SharedPreferences.getInstance(),
    );

    await repository.write(DailyGoal.unset);
    expect((await repository.read()).sameAs(DailyGoal.unset), isTrue);
  });
}

/// 指定キーの [setValue] を失敗させられる prefs ストア。
final class _ControllablePrefsStore extends SharedPreferencesStorePlatform {
  /// [data] を初期値にし、[failingKeySuffixes] への書き込みを失敗させる。
  ///
  /// Example:
  /// ```dart
  /// _ControllablePrefsStore(
  ///   data: {'daily_goal_calories_kcal': 50.0},
  ///   failingKeySuffixes: {'daily_goal_calories_kcal'},
  /// );
  /// ```
  _ControllablePrefsStore({
    Map<String, Object> data = const <String, Object>{},
    this.failingKeySuffixes = const <String>{},
    this.failingRemoveSuffixes = const <String>{},
    this.failAfterFirstFailure = false,
  }) : backend = InMemorySharedPreferencesStore.withData(<String, Object>{
         for (final entry in data.entries)
           entry.key.startsWith('flutter.')
                   ? entry.key
                   : 'flutter.${entry.key}':
               entry.value,
       });

  /// 実際の値を保持するストア。
  final InMemorySharedPreferencesStore backend;

  /// 書き込みを失敗させるキー末尾。
  final Set<String> failingKeySuffixes;

  /// 削除を失敗させるキー末尾。値はストアに残す。
  final Set<String> failingRemoveSuffixes;

  /// 最初の失敗のあとも書き込みを失敗させ続けるか。
  final bool failAfterFirstFailure;

  /// すでに一度失敗したか。
  bool _hasFailed = false;

  @override
  Future<bool> clear() => backend.clear();

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) {
    return backend.clearWithParameters(parameters);
  }

  @override
  Future<Map<String, Object>> getAll() => backend.getAll();

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) {
    return backend.getAllWithParameters(parameters);
  }

  @override
  Future<bool> remove(String key) async {
    if (failingRemoveSuffixes.any(key.endsWith)) {
      return false;
    }
    return backend.remove(key);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    final shouldFail =
        failingKeySuffixes.any(key.endsWith) &&
        (!_hasFailed || failAfterFirstFailure);
    if (shouldFail) {
      _hasFailed = true;
      return false;
    }
    return backend.setValue(valueType, key, value);
  }
}
