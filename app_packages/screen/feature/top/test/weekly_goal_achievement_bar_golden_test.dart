import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_top/src/view/weekly_goal_achievement_bar.dart';

void main() {
  testWidgets('週間達成バー progress / ja / Android / light', (tester) async {
    await _pumpWeeklyBarGolden(
      tester,
      bar: const WeeklyGoalAchievementBar(
        title: '今週の目標達成日数',
        showGuidance: false,
        guidanceText: '',
        ratioText: '達成日数:2日 / 目標日数:5日',
        statusText: '目標達成まであと3日！',
        progress: 2 / 5,
        semanticsLabel: '今週の目標達成は2日、目標は5日、残り3日',
      ),
      golden: 'goldens/weekly_bar_progress.png',
    );
  });

  testWidgets('週間達成バー done / ja / Android / light', (tester) async {
    await _pumpWeeklyBarGolden(
      tester,
      bar: const WeeklyGoalAchievementBar(
        title: '今週の目標達成日数',
        showGuidance: false,
        guidanceText: '',
        ratioText: '達成日数:5日 / 目標日数:5日',
        statusText: '今週は目標達成済！',
        progress: 1.0,
        semanticsLabel: '今週の目標達成は5日、目標は5日、達成済',
      ),
      golden: 'goldens/weekly_bar_done.png',
    );
  });

  testWidgets('週間達成バー guidance / ja / Android / light', (tester) async {
    await _pumpWeeklyBarGolden(
      tester,
      bar: const WeeklyGoalAchievementBar(
        title: '今週の目標達成日数',
        showGuidance: true,
        guidanceText: '目標設定で週間の目標運動日数と一日あたりの目標を設定しましょう',
        ratioText: '',
        statusText: '',
        progress: 0,
        semanticsLabel: '',
      ),
      golden: 'goldens/weekly_bar_guidance.png',
    );
  });
}

Future<void> _pumpWeeklyBarGolden(
  WidgetTester tester, {
  required WeeklyGoalAchievementBar bar,
  required String golden,
}) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  tester.platformDispatcher.localesTestValue = const [Locale('ja')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  tester.view.physicalSize = const Size(390, 200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await LocalizeStringDelegate.injectDelegateForTest(
    arbJson: StringsTestHelper.ja,
  );
  addTearDown(LocalizeStringDelegate.resetDelegateForTest);

  try {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        home: FTheme(
          data: FThemeData(touch: true, colors: FColors.neutralLight),
          child: ColoredBox(
            color: FColors.neutralLight.background,
            child: Center(child: bar),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(WeeklyGoalAchievementBar),
      matchesGoldenFile(golden),
    );
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}
