import 'dart:convert';

import 'package:data_repository_tutorial_impl/data_repository_tutorial_impl.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('キー無しは initial', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesTutorialRepository(preferences);
    expect(await repository.read(), TutorialProgress.initial);
  });

  test('書き込み後に読める', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesTutorialRepository(preferences);
    const progress = TutorialProgress(
      mainCompleted: true,
      mainReachedStep: 7,
      goalSettingsContextSeen: true,
      cameraContextSeen: true,
      meterEditContextSeen: false,
      trendsContextSeen: true,
      historyContextSeen: false,
      achievementContextSeen: true,
    );
    await repository.write(progress);
    expect(await repository.read(), progress);
  });

  test('不正 JSON は initial', () async {
    SharedPreferences.setMockInitialValues({'tutorial_progress': '{not-json'});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesTutorialRepository(preferences);
    expect(await repository.read(), TutorialProgress.initial);
  });

  test('必須 bool 欠落は initial', () async {
    SharedPreferences.setMockInitialValues({
      'tutorial_progress': jsonEncode({'mainCompleted': true}),
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesTutorialRepository(preferences);
    expect(await repository.read(), TutorialProgress.initial);
  });

  test('配列 JSON は initial', () async {
    SharedPreferences.setMockInitialValues({
      'tutorial_progress': jsonEncode(<Object?>[]),
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesTutorialRepository(preferences);
    expect(await repository.read(), TutorialProgress.initial);
  });
}
