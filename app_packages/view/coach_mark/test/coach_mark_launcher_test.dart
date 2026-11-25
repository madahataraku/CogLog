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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(await future, CoachMarkDismissReason.forced);
    expect(find.text('破棄'), findsNothing);
  });

  // テスト対象:
  // CoachMarkLauncher.contentAlignFor
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
}
