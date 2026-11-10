import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:view_model_download_guidance/src/model_download_guidance_dialog.dart';

void main() {
  testWidgets('モデル誘導ダイアログ / ja / Android / light', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(360, 640);
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
              child: Center(
                child: ModelDownloadGuidanceDialog(
                  style: FThemeData(
                    touch: true,
                    colors: FColors.neutralLight,
                  ).dialogStyle,
                  animation: const AlwaysStoppedAnimation(1),
                  title: '端末上のAIモデルの準備',
                  body: 'ワンポイントアドバイス等に使うモデルが端末にありません。',
                  dismissLabel: '閉じる',
                  prepareLabel: 'モデルを準備',
                  prepareFailedLabel: '準備に失敗しました',
                  onDismiss: () {},
                  onPrepare: () async {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ModelDownloadGuidanceDialog),
        matchesGoldenFile('goldens/model_download_guidance_dialog_light.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
