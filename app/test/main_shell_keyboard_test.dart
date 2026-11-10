import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_feature_main/screen_feature_main.dart';

import 'package:app/theme/theme.dart';

void main() {
  testWidgets('キーボード表示中はボトムナビが無く子の bottom inset は 0', (
    tester,
  ) async {
    late double childBottomInset;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 300)),
        child: MaterialApp(
          home: FTheme(
            data: lightTheme,
            child: MainShellScreen(
              currentIndex: 0,
              onIndexChange: (_) {},
              child: Builder(
                builder: (context) {
                  childBottomInset = MediaQuery.viewInsetsOf(context).bottom;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FBottomNavigationBar), findsNothing);
    expect(childBottomInset, 0);
  });

  testWidgets('キーボード非表示時はボトムナビがある', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
          home: FTheme(
            data: lightTheme,
            child: MainShellScreen(
              currentIndex: 0,
              onIndexChange: (_) {},
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FBottomNavigationBar), findsOneWidget);
  });
}
