import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
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
      home: Scaffold(body: child),
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
  // CoachMarkLauncher.dismissActive
  //
  // テスト内容:
  // 表示予約直後の強制破棄は forced。遅延挿入はキャンセルされる。
  testWidgets('強制破棄は forced（遅延挿入キャンセル）', (tester) async {
    final registry = CoachMarkRegistry();
    late BuildContext savedContext;

    await tester.pumpWidget(
      _wrap(
        registry: registry,
        child: Builder(
          builder: (context) {
            savedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pump();

    final future = CoachMarkLauncher.show(
      savedContext,
      step: const CoachMarkStep(
        targetId: CoachMarkTargetId.trendsChart,
        title: '破棄',
        body: '本文',
        primaryLabel: '閉じる',
      ),
    );
    CoachMarkLauncher.dismissActive();
    // 上流の遅延 insert と、その直後の tearDown を進める。
    await tester.pump();
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);
    await tester.pump(const Duration(milliseconds: 800));
    expect(await future, CoachMarkDismissReason.forced);
    expect(find.text('破棄'), findsNothing);
  });

  // テスト対象:
  // CoachMarkLauncher.show / CoachMarkBubble 主ボタン
  //
  // テスト内容:
  // 主ボタンで閉じると primary。
  testWidgets('主ボタンは primary', (tester) async {
    final registry = CoachMarkRegistry();
    late BuildContext savedContext;

    await tester.pumpWidget(
      _wrap(
        registry: registry,
        child: Builder(
          builder: (context) {
            savedContext = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    await tester.pump();

    final future = CoachMarkLauncher.show(
      savedContext,
      step: const CoachMarkStep(
        targetId: CoachMarkTargetId.trendsChart,
        title: '主',
        body: '本文',
        primaryLabel: '次へ',
      ),
    );
    // 上流の遅延 insert と focus アニメのため、短い間隔で複数フレーム進める。
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('主'), findsOneWidget);
    await tester.tap(find.text('次へ'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(await future, CoachMarkDismissReason.primary);
    expect(find.text('主'), findsNothing);
  });

  // テスト対象:
  // CoachMarkLauncher.show / CoachMarkBubble 副ボタン
  //
  // テスト内容:
  // 副ボタンで閉じると secondary。
  testWidgets('副ボタンは secondary', (tester) async {
    final registry = CoachMarkRegistry();
    late BuildContext savedContext;

    await tester.pumpWidget(
      _wrap(
        registry: registry,
        child: Builder(
          builder: (context) {
            savedContext = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    await tester.pump();

    final future = CoachMarkLauncher.show(
      savedContext,
      step: const CoachMarkStep(
        targetId: CoachMarkTargetId.trendsChart,
        title: '副',
        body: '本文',
        primaryLabel: '次へ',
        secondaryLabel: 'スキップ',
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('副'), findsOneWidget);
    await tester.tap(find.text('スキップ'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(await future, CoachMarkDismissReason.secondary);
    expect(find.text('副'), findsNothing);
  });

  // テスト対象:
  // CoachMarkLauncher.contentAlignFor / resolveContentPlacement
  //
  // テスト内容:
  // 穴が下半分なら top、上半分なら bottom。
  test('吹き出し配置は穴の上下で切り替わる', () {
    const size = Size(360, 640);
    expect(
      CoachMarkLauncher.contentAlignFor(
        hole: const Rect.fromLTWH(10, 500, 100, 40),
        screenSize: size,
      ),
      ContentAlign.top,
    );
    expect(
      CoachMarkLauncher.contentAlignFor(
        hole: const Rect.fromLTWH(10, 80, 100, 40),
        screenSize: size,
      ),
      ContentAlign.bottom,
    );
    expect(
      CoachMarkLauncher.contentAlignFor(hole: null, screenSize: size),
      ContentAlign.bottom,
    );
  });

  // テスト対象:
  // CoachMarkLauncher.resolveContentPlacement
  //
  // テスト内容:
  // 大きな穴で top／bottom 余白が足りないとき custom で画面内に固定する。
  test('大きな穴は custom で画面内に固定する', () {
    const size = Size(360, 640);
    // ほぼ全画面の穴（撮影プレビュー／グラフ／カレンダー想定）。
    final placement = CoachMarkLauncher.resolveContentPlacement(
      hole: const Rect.fromLTWH(0, 40, 360, 520),
      screenSize: size,
      safePadding: const EdgeInsets.only(top: 20, bottom: 20),
    );
    expect(placement.align, ContentAlign.custom);
    expect(placement.customPosition, isNotNull);
    final custom = placement.customPosition!;
    expect(custom.left, 0);
    expect(custom.right, 0);
    // top か bottom のどちらかで画面端に固定される。
    expect(custom.top != null || custom.bottom != null, isTrue);
  });

  // テスト対象:
  // CoachMarkLauncher.resolveContentPlacement
  //
  // テスト内容:
  // ライブラリ top／bottom では足りず、穴下に余白があるとき穴直下へ custom。
  test('穴の下に余白があれば穴直下へ custom 配置する', () {
    const size = Size(360, 640);
    final placement = CoachMarkLauncher.resolveContentPlacement(
      hole: const Rect.fromLTWH(0, 0, 360, 480),
      screenSize: size,
    );
    expect(placement.align, ContentAlign.custom);
    expect(placement.customPosition?.top, greaterThan(480));
    expect(placement.customPosition?.bottom, isNull);
  });

  // テスト対象:
  // CoachMarkLauncher.show + 大きなターゲット
  //
  // テスト内容:
  // 大きな穴でも閉じるボタンが画面内にあり押せる。
  testWidgets('大きな穴でも主ボタンを押せる', (tester) async {
    final registry = CoachMarkRegistry();
    late BuildContext savedContext;
    final targetKey = GlobalKey();

    await tester.pumpWidget(
      _wrap(
        registry: registry,
        child: Builder(
          builder: (context) {
            savedContext = context;
            return SizedBox.expand(
              child: ColoredBox(key: targetKey, color: const Color(0xFFCCCCCC)),
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
        title: '撮影',
        body: 'カメラ領域の説明',
        primaryLabel: '閉じる',
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('閉じる'), findsOneWidget);
    final buttonRect = tester.getRect(find.text('閉じる'));
    final screen = tester.getSize(find.byType(MaterialApp));
    expect(buttonRect.top, greaterThanOrEqualTo(0));
    expect(buttonRect.bottom, lessThanOrEqualTo(screen.height));

    await tester.tap(find.text('閉じる'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(await future, CoachMarkDismissReason.primary);
  });
}
