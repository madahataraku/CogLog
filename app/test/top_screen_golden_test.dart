import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_feature_top/screen_feature_top.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'top_screen_harness.dart';

Map<String, Object> _positiveGoalsPrefs({required int weeklyDays}) => {
  'daily_goal_calories_kcal': 100.0,
  'daily_goal_duration_seconds': 600,
  'daily_goal_distance_km': 1.0,
  'daily_goal_weekly_achievement_days': weeklyDays,
};

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    final golden = brightness == Brightness.light
        ? 'goldens/top_screen.png'
        : 'goldens/top_screen_dark.png';
    testWidgets('トップ画面の $brightness / ja / Android の空状態', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      tester.platformDispatcher.localesTestValue = const [Locale('ja')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      try {
        await pumpTopScreen(tester);
        await expectLater(find.byType(TopScreen), matchesGoldenFile(golden));
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('消費カロリー 1.25 を 1.3 kcal で示す', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    try {
      await pumpTopScreen(tester, histories: [rideNow()]);
      await expectLater(
        find.byType(TopScreen),
        matchesGoldenFile('goldens/top_screen_values.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('週間達成 progress / ja / Android / light', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    try {
      SharedPreferences.setMockInitialValues(
        _positiveGoalsPrefs(weeklyDays: 5),
      );
      await pumpTopScreen(
        tester,
        preferences: await SharedPreferences.getInstance(),
      );
      await expectLater(
        find.byType(TopScreen),
        matchesGoldenFile('goldens/top_screen_weekly_progress.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('週間達成 done / ja / Android / light', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    try {
      SharedPreferences.setMockInitialValues(
        _positiveGoalsPrefs(weeklyDays: 1),
      );
      await pumpTopScreen(
        tester,
        preferences: await SharedPreferences.getInstance(),
        histories: [rideNow(distanceKm: 2.0, caloriesKcal: 200)],
      );
      await expectLater(
        find.byType(TopScreen),
        matchesGoldenFile('goldens/top_screen_weekly_done.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('週間達成 guidance / ja / Android / light', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    try {
      SharedPreferences.setMockInitialValues({});
      await pumpTopScreen(
        tester,
        preferences: await SharedPreferences.getInstance(),
      );
      await expectLater(
        find.byType(TopScreen),
        matchesGoldenFile('goldens/top_screen_weekly_guidance.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
