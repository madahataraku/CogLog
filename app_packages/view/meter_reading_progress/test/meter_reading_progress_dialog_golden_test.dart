import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:view_meter_reading_progress/src/meter_reading_progress_dialog.dart';

Widget _wrapDialog(MeterReadingProgressDialog dialog) {
  return MaterialApp(
    locale: const Locale('ja'),
    home: FTheme(
      data: FThemeData(touch: true, colors: FColors.neutralLight),
      child: ColoredBox(
        color: FColors.neutralLight.background,
        child: Center(child: dialog),
      ),
    ),
  );
}

FDialogStyle get _dialogStyle =>
    FThemeData(touch: true, colors: FColors.neutralLight).dialogStyle;

void main() {
  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDown(LocalizeStringDelegate.resetDelegateForTest);

  testWidgets('読み取り中ダイアログ / ja / Android / light', (tester) async {
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
        _wrapDialog(
          MeterReadingProgressDialog(
            style: _dialogStyle,
            animation: const AlwaysStoppedAnimation(1),
            onCancel: () {},
          ),
        ),
      );
      // FCircularProgress は無限アニメのため settle しない。
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byType(MeterReadingProgressDialog),
        matchesGoldenFile('goldens/meter_reading_progress_dialog.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
