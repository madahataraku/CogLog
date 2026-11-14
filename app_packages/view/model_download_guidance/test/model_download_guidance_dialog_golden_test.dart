import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:view_model_download_guidance/src/model_download_guidance_dialog.dart';

Widget _wrapDialog(ModelDownloadGuidanceDialog dialog) {
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

    try {
      await tester.pumpWidget(
        _wrapDialog(
          ModelDownloadGuidanceDialog(
            style: _dialogStyle,
            animation: const AlwaysStoppedAnimation(1),
            title: '端末上のAIモデルの準備',
            body: 'ワンポイントアドバイス等に使うモデルが端末にありません。',
            dismissLabel: '閉じる',
            prepareLabel: 'モデルを準備',
            prepareFailedLabel: '準備に失敗しました',
            onDismiss: () {},
            onPrepare: () async* {},
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

  testWidgets('準備中進捗と閉じる無効 / ja / Android / light', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final progress = StreamController<double>();
    addTearDown(progress.close);

    try {
      await tester.pumpWidget(
        _wrapDialog(
          ModelDownloadGuidanceDialog(
            style: _dialogStyle,
            animation: const AlwaysStoppedAnimation(1),
            title: 'メーター読み取りモデルの準備',
            body: 'メーター読み取り用のモデルが端末にありません。',
            dismissLabel: '閉じる',
            prepareLabel: 'モデルを準備',
            prepareFailedLabel: '準備に失敗しました',
            disableDismissWhilePreparing: true,
            onDismiss: () {},
            onPrepare: () => progress.stream,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('モデルを準備'));
      await tester.pump();
      progress.add(0.42);
      // FTappable の押下アニメーション用 Timer を消化する。
      await tester.pump(const Duration(milliseconds: 200));
      await expectLater(
        find.byType(ModelDownloadGuidanceDialog),
        matchesGoldenFile(
          'goldens/model_download_guidance_dialog_preparing_light.png',
        ),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('準備失敗 Wi-Fi 文言 / ja / Android / light', (tester) async {
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
          ModelDownloadGuidanceDialog(
            style: _dialogStyle,
            animation: const AlwaysStoppedAnimation(1),
            title: 'メーター読み取りモデルの準備',
            body: 'メーター読み取り用のモデルが端末にありません。',
            dismissLabel: '閉じる',
            prepareLabel: 'モデルを準備',
            prepareFailedLabel: '準備に失敗しました',
            mapPrepareError: (_) => 'Wi-Fiに接続してから再度お試しください。',
            disableDismissWhilePreparing: true,
            onDismiss: () {},
            onPrepare: () async* {
              throw StateError('wifi');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('モデルを準備'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ModelDownloadGuidanceDialog),
        matchesGoldenFile(
          'goldens/model_download_guidance_dialog_wifi_error_light.png',
        ),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
