import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:view_loading_spinner/view_loading_spinner.dart';

void main() {
  testWidgets('AppLoadingSpinner / ja / Android / light', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(200, 200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    try {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ja'),
          home: FTheme(
            data: FThemeData(touch: true, colors: FColors.neutralLight),
            child: const ColoredBox(
              color: Color(0xFFFFFFFF),
              child: Center(child: AppLoadingSpinner()),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await expectLater(
        find.byType(AppLoadingSpinner),
        matchesGoldenFile('goldens/app_loading_spinner.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
