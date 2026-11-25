import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:view_coach_mark/src/coach_mark_bubble.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

/// Golden 用に ja / Forui ライトテーマで包む。
///
/// Example:
/// ```dart
/// _wrap(const SizedBox.shrink());
/// ```
Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('ja'),
    home: FTheme(
      data: FThemeData(touch: true, colors: FColors.neutralLight),
      child: ColoredBox(color: FColors.neutralLight.background, child: child),
    ),
  );
}

void main() {
  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDown(LocalizeStringDelegate.resetDelegateForTest);

  // テスト対象:
  // CoachMarkBubble
  //
  // テスト内容:
  // ja / Android / light で吹き出しの見た目が golden と一致する。
  testWidgets('コーチマーク吹き出し / ja / Android / light', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    try {
      await tester.pumpWidget(
        _wrap(
          Center(
            child: CoachMarkBubble(
              step: const CoachMarkStep(
                targetId: CoachMarkTargetId.homePeriodTotals,
                title: 'ホームの見かた',
                body: '本日・今週・今月の合計と、目標に対する達成状況を確認できます。',
                primaryLabel: '次へ',
                secondaryLabel: 'スキップ',
              ),
              onDismiss: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CoachMarkBubble),
        matchesGoldenFile('goldens/coach_mark_overlay_light.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
