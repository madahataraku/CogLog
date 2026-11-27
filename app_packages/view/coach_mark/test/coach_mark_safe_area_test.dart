import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

/// 本番同様に [MaterialApp.builder] で [FTheme] を載せ、Registry を差し込む。
Widget _wrap({required Widget child, required CoachMarkRegistry registry}) {
  return ProviderScope(
    overrides: [CoachMarkProviders.registry.overrideWith((ref) => registry)],
    child: MaterialApp(
      builder: (context, child) => FTheme(
        data: FThemeData(touch: true, colors: FColors.neutralLight),
        child: child!,
      ),
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 640),
          padding: EdgeInsets.only(top: 47, bottom: 34),
          viewPadding: EdgeInsets.only(top: 47, bottom: 34),
        ),
        child: Scaffold(body: child),
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

  tearDown(() {
    CoachMarkLauncher.dismissActive();
    LocalizeStringDelegate.resetDelegateForTest();
  });

  // テスト対象:
  // CoachMarkLauncher.show / resolveContentPlacement（低解像度・SafeArea）
  //
  // テスト内容:
  // 穴下余白が 160 超でも吹き出しを片側だけ固定せず、主ボタンが SafeArea 内に残る。
  testWidgets('低解像度で穴下配置でも主ボタンは SafeArea 内', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final registry = CoachMarkRegistry();
    late BuildContext savedContext;
    final targetKey = GlobalKey();

    // 穴下に約 200px（旧実装だと top のみ custom でボタンが SafeArea 外へ切れる）。
    await tester.pumpWidget(
      _wrap(
        registry: registry,
        child: Builder(
          builder: (context) {
            savedContext = context;
            return Column(
              children: [
                const SizedBox(height: 80),
                SizedBox(
                  height: 360,
                  width: double.infinity,
                  child: ColoredBox(
                    key: targetKey,
                    color: const Color(0xFFCCCCCC),
                  ),
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    registry.register(CoachMarkTargetId.meterCameraArea, targetKey);

    final future = CoachMarkLauncher.show(
      savedContext,
      step: const CoachMarkStep(
        targetId: CoachMarkTargetId.meterCameraArea,
        title: 'メーターを撮影',
        body: 'カメラでメーターパネルを写すか、アルバムから写真を選べます。撮影後に読み取り結果を確認します。',
        primaryLabel: '閉じる',
      ),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final button = find.text('閉じる');
    expect(button, findsOneWidget);
    final buttonRect = tester.getRect(button);
    expect(
      buttonRect.bottom,
      lessThanOrEqualTo(640 - 34 + 1.0),
      reason: '主ボタンはホームインジケータ上（SafeArea 内）にあること',
    );
    expect(
      buttonRect.top,
      greaterThanOrEqualTo(47 - 1.0),
      reason: '主ボタンはステータスバー下にあること',
    );

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(await future, CoachMarkDismissReason.primary);
  });
}
