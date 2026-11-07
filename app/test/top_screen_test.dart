import 'package:forui/forui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'top_screen_harness.dart';

void main() {
  testWidgets('履歴が無い期間は --', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await pumpTopScreen(tester);

    expect(find.text('本日'), findsOneWidget);
    expect(find.text('今週'), findsOneWidget);
    expect(find.text('今月'), findsOneWidget);
    expect(find.text('--'), findsNWidgets(3));
    expect(find.text('kcal'), findsNWidgets(3));
  });

  testWidgets('距離へ切り替えると 3 期間が距離になる', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await pumpTopScreen(
      tester,
      histories: [rideNow(distanceKm: 2.5, caloriesKcal: 1.25)],
    );

    expect(find.text('1.3'), findsNWidgets(3));
    expect(find.text('kcal'), findsNWidgets(3));
    await _chooseMetric(tester, '消費カロリー', '走行距離');
    expect(find.text('2.5'), findsNWidgets(3));
    expect(find.text('km'), findsNWidgets(3));
  });

  testWidgets('選んだ指標は再び開いても残る', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final histories = [rideNow(distanceKm: 2.5, caloriesKcal: 1.25)];

    await pumpTopScreen(tester, histories: histories, preferences: preferences);
    await _chooseMetric(tester, '消費カロリー', '走行距離');

    await tester.pumpWidget(const SizedBox());
    await pumpTopScreen(tester, histories: histories, preferences: preferences);
    expect(find.text('2.5'), findsNWidgets(3));
    expect(find.text('km'), findsNWidgets(3));
  });

  testWidgets('英語で期間と指標を区別できる', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await pumpTopScreen(tester);

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
    // 指標 Select と達成率リング見出しの双方に出る。
    expect(find.text('Calories'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Calories').first);
    await tester.pumpAndSettle();
    final menu = find.byType(FPopover);
    expect(
      find.descendant(of: menu, matching: find.text('Distance')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: menu, matching: find.text('Exercise time')),
      findsOneWidget,
    );
  });

  testWidgets('他タブからホームへ戻ると目標を再読み込みする', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await pumpTopScreen(tester, preferences: preferences);
    expect(find.text('目標設定で一日あたりの目標を設定しましょう'), findsNWidgets(3));

    await tester.tap(find.text('目標設定').last);
    await tester.pumpAndSettle();
    await preferences.setDouble('daily_goal_calories_kcal', 200);

    await tester.tap(find.text('ホーム'));
    await tester.pumpAndSettle();

    expect(find.text('目標 200.0'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('目標設定で一日あたりの目標を設定しましょう'), findsNWidgets(2));
  });
}

Future<void> _chooseMetric(
  WidgetTester tester,
  String current,
  String label,
) async {
  // Select 欄が先頭。達成率リング見出しと同文言がある。
  await tester.tap(find.text(current).first);
  await tester.pumpAndSettle();
  final menuOption = find.descendant(
    of: find.byType(FPopover),
    matching: find.text(label),
  );
  expect(menuOption, findsOneWidget);
  await tester.tap(menuOption);
  await tester.pumpAndSettle();
}
