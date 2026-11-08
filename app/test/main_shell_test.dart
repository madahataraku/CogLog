import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'top_screen_harness.dart';

void main() {
  testWidgets('起動直後はホームの期間集計とボトムナビがある', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await pumpTopScreen(tester);

    expect(find.text('本日'), findsOneWidget);
    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('メーター記録'), findsOneWidget);
    expect(find.text('運動履歴'), findsOneWidget);
    expect(find.text('目標設定'), findsOneWidget);
    expect(find.bySemanticsLabel('メーターパネルを撮影'), findsNothing);
  });

  testWidgets('ボトムナビで各画面へ切り替わりホームへ戻れる', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final screens = await pumpTopScreen(tester);

    await tester.tap(find.text('メーター記録'));
    await tester.pumpAndSettle();
    expect(find.text('メーター記録'), findsWidgets);
    expect(screens.router.state.uri.path, '/meter-capture');
    expect(find.text('本日'), findsNothing);

    await tester.tap(find.text('運動履歴'));
    await tester.pumpAndSettle();
    expect(screens.router.state.uri.path, '/exercise-history');

    await tester.tap(find.text('目標設定'));
    await tester.pumpAndSettle();
    expect(screens.router.state.uri.path, '/goal-settings');

    await tester.tap(find.text('ホーム'));
    await tester.pumpAndSettle();
    expect(screens.router.state.uri.path, '/');
    expect(find.text('本日'), findsOneWidget);
  });
}
