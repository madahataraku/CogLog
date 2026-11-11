import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_top/src/view/advice_speech_panel.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

const _fixedAdviceText = '水分をこまめに取りましょう。';

void main() {
  for (final tone in AdviceTone.values) {
    testWidgets('アドバイス吹き出し $tone / ja / Android / light', (tester) async {
      await _pumpPanelGolden(
        tester,
        tone: tone,
        brightness: Brightness.light,
        golden: 'goldens/advice_speech_panel_${tone.name}_light.png',
      );
    });
  }

  testWidgets('アドバイス吹き出し fun / ja / Android / dark', (tester) async {
    await _pumpPanelGolden(
      tester,
      tone: AdviceTone.fun,
      brightness: Brightness.dark,
      golden: 'goldens/advice_speech_panel_fun_dark.png',
    );
  });

  testWidgets('キャラクター画像に代替テキストがある', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

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
            child: AdviceSpeechPanel(
              adviceText: _fixedAdviceText,
              tone: AdviceTone.fun,
              semanticsLabel: 'アドバイザー',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('アドバイザー'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Future<void> _pumpPanelGolden(
  WidgetTester tester, {
  required AdviceTone tone,
  required Brightness brightness,
  required String golden,
}) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  tester.platformDispatcher.localesTestValue = const [Locale('ja')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  tester.view.physicalSize = const Size(360, 200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await LocalizeStringDelegate.injectDelegateForTest(
    arbJson: StringsTestHelper.ja,
  );
  addTearDown(LocalizeStringDelegate.resetDelegateForTest);

  final colors = brightness == Brightness.light
      ? FColors.neutralLight
      : FColors.neutralDark;

  try {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        home: FTheme(
          data: FThemeData(touch: true, colors: colors),
          child: ColoredBox(
            color: colors.background,
            child: Center(
              child: SizedBox(
                width: 360,
                child: AdviceSpeechPanel(
                  adviceText: _fixedAdviceText,
                  tone: tone,
                  semanticsLabel: 'アドバイザー',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // アドバイザー PNG のデコード完了前に撮ると light Golden が空になる。
    await tester.runAsync(() async {
      final context = tester.element(find.byType(AdviceSpeechPanel));
      await precacheImage(
        AssetImage(
          'assets/advisor/${tone.name}.png',
          package: 'screen_feature_top',
        ),
        context,
      );
    });
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AdviceSpeechPanel),
      matchesGoldenFile(golden),
    );
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}
