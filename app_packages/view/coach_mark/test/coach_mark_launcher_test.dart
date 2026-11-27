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
  // CoachMarkLauncher.show / enableTargetTab
  //
  // テスト内容:
  // 穴タップは主ボタンと同じ primary。
  testWidgets('穴タップは primary', (tester) async {
    final registry = CoachMarkRegistry();
    late BuildContext savedContext;
    final targetKey = GlobalKey();

    await tester.pumpWidget(
      _wrap(
        registry: registry,
        child: Builder(
          builder: (context) {
            savedContext = context;
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                key: targetKey,
                width: 120,
                height: 48,
                child: const ColoredBox(color: Color(0xFF88AAFF)),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    registry.register(CoachMarkTargetId.homeAdvisor, targetKey);

    final future = CoachMarkLauncher.show(
      savedContext,
      step: const CoachMarkStep(
        targetId: CoachMarkTargetId.homeAdvisor,
        title: '穴',
        body: '本文',
        primaryLabel: '次へ',
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('穴'), findsOneWidget);

    // 穴上のオーバーレイ（enableTargetTab）が受ける。下の Widget には届かない。
    final holeCenter = tester.getCenter(find.byKey(targetKey));
    await tester.tapAt(holeCenter);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(await future, CoachMarkDismissReason.primary);
    expect(find.text('穴'), findsNothing);
  });

  // テスト対象:
  // CoachMarkLauncher.focusRadiusFor
  //
  // テスト内容:
  // アチーブメント行は枠と同じ 12、それ以外は既定 8。
  test('穴の角丸はアチーブメント行だけ 12', () {
    expect(
      CoachMarkLauncher.focusRadiusFor(CoachMarkTargetId.achievementList),
      12,
    );
    expect(CoachMarkLauncher.focusRadiusFor(CoachMarkTargetId.homeAdvisor), 8);
    expect(
      CoachMarkLauncher.focusRadiusFor(CoachMarkTargetId.homePeriodTotals),
      8,
    );
  });

  // テスト対象:
  // CoachMarkLauncher.contentAlignFor / resolveContentPlacement
  //
  // テスト内容:
  // 常に custom。穴が下寄りなら上帯、上寄りなら下帯（SafeArea 内で top+bottom）。
  test('吹き出し配置は穴の上下で帯を切り替える', () {
    const size = Size(360, 640);
    const safe = EdgeInsets.only(top: 20, bottom: 20);
    final above = CoachMarkLauncher.resolveContentPlacement(
      hole: const Rect.fromLTWH(10, 500, 100, 40),
      screenSize: size,
      safePadding: safe,
    );
    expect(above.align, ContentAlign.custom);
    expect(above.customPosition?.top, 20 + 8);
    expect(above.customPosition?.bottom, greaterThan(20));

    final below = CoachMarkLauncher.resolveContentPlacement(
      hole: const Rect.fromLTWH(10, 80, 100, 40),
      screenSize: size,
      safePadding: safe,
    );
    expect(below.align, ContentAlign.custom);
    expect(below.customPosition?.top, greaterThan(80));
    expect(below.customPosition?.bottom, 20 + 8);

    expect(
      CoachMarkLauncher.contentAlignFor(hole: null, screenSize: size),
      ContentAlign.custom,
    );
  });

  // テスト対象:
  // CoachMarkLauncher.resolveContentPlacement
  //
  // テスト内容:
  // 大きな穴でも custom の top と bottom が両方入り SafeArea 帯になる。
  test('大きな穴は custom で SafeArea 帯に固定する', () {
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
    expect(custom.top, isNotNull);
    expect(custom.bottom, isNotNull);
  });

  // テスト対象:
  // CoachMarkLauncher.resolveContentPlacement
  //
  // テスト内容:
  // 穴下に十分余白があるとき穴直下〜 SafeArea 下端の帯（top と bottom 両方）。
  test('穴の下に余白があれば穴直下の SafeArea 帯へ custom 配置する', () {
    const size = Size(360, 640);
    // 下余白が minContentHeight 以上になる穴（480 だと下 118 で全画面帯に落ちる）。
    final placement = CoachMarkLauncher.resolveContentPlacement(
      hole: const Rect.fromLTWH(0, 0, 360, 400),
      screenSize: size,
      safePadding: const EdgeInsets.only(bottom: 34),
    );
    expect(placement.align, ContentAlign.custom);
    expect(placement.customPosition?.top, greaterThan(400));
    expect(placement.customPosition?.bottom, 34 + 8);
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
