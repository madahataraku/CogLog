import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:view_confirm_dialog/view_confirm_dialog.dart';

void main() {
  Future<void> pumpHost(
    WidgetTester tester, {
    required void Function(BuildContext context) onReady,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FTheme(
          data: FThemeData(touch: true, colors: FColors.neutralLight),
          child: Builder(
            builder: (context) {
              return ColoredBox(
                color: FColors.neutralLight.background,
                child: Center(
                  child: FButton(
                    onPress: () => onReady(context),
                    child: const Text('open'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('確認で true を返す', (tester) async {
    late Future<bool> future;
    await pumpHost(
      tester,
      onReady: (context) {
        future = showConfirmDialog(
          context,
          title: '削除しますか？',
          body: '取り消せません。',
          confirmLabel: '削除',
          cancelLabel: 'キャンセル',
        );
      },
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('削除しますか？'), findsOneWidget);

    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();
    expect(await future, isTrue);
  });

  testWidgets('キャンセルで false を返す', (tester) async {
    late Future<bool> future;
    await pumpHost(
      tester,
      onReady: (context) {
        future = showConfirmDialog(
          context,
          title: '破棄しますか？',
          body: '変更は失われます。',
          confirmLabel: '破棄',
          cancelLabel: '戻る',
        );
      },
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('戻る'));
    await tester.pumpAndSettle();
    expect(await future, isFalse);
  });
}
