import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_feature_main/screen_feature_main.dart';

import 'top_screen_harness.dart';

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    final golden = brightness == Brightness.light
        ? 'goldens/main_shell_home.png'
        : 'goldens/main_shell_home_dark.png';
    testWidgets('シェル付きホームの $brightness / ja / Android の空状態', (tester) async {
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
        await expectLater(
          find.byType(MainShellScreen),
          matchesGoldenFile(golden),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('メーター記録タブの空画面', (tester) async {
    await _pumpTabGolden(
      tester,
      tab: 'メーター記録',
      golden: 'goldens/main_shell_meter_capture.png',
    );
  });

  testWidgets('運動履歴タブの空画面', (tester) async {
    await _pumpTabGolden(
      tester,
      tab: '運動履歴',
      golden: 'goldens/main_shell_exercise_history.png',
    );
  });

  testWidgets('目標設定タブの空画面', (tester) async {
    await _pumpTabGolden(
      tester,
      tab: '目標設定',
      golden: 'goldens/main_shell_goal_settings.png',
    );
  });
}

Future<void> _pumpTabGolden(
  WidgetTester tester, {
  required String tab,
  required String golden,
}) async {
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
    await pumpTopScreen(tester);
    await tester.tap(find.text(tab).last);
    await tester.pumpAndSettle();
    await expectLater(find.byType(MainShellScreen), matchesGoldenFile(golden));
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}
