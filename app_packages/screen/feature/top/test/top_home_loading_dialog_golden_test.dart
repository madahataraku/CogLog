import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_top/src/view/top_home_loading_dialog.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('ja'),
    home: FTheme(
      data: FThemeData(touch: true, colors: FColors.neutralLight),
      child: ColoredBox(
        color: FColors.neutralLight.background,
        child: Center(child: child),
      ),
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

  Future<void> pumpBody(
    WidgetTester tester, {
    required bool loadFailed,
    required String golden,
  }) async {
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
          TopHomeLoadingDialogBody(
            loadFailed: loadFailed,
            onRetry: () async {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byType(TopHomeLoadingDialogBody),
        matchesGoldenFile(golden),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  testWidgets('ホーム読込中ダイアログ / ja / Android / light', (tester) async {
    await pumpBody(
      tester,
      loadFailed: false,
      golden: 'goldens/top_home_loading_dialog_loading.png',
    );
  });

  testWidgets('ホーム読込失敗ダイアログ / ja / Android / light', (tester) async {
    await pumpBody(
      tester,
      loadFailed: true,
      golden: 'goldens/top_home_loading_dialog_failed.png',
    );
  });
}
