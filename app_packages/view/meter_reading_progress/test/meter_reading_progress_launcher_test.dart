import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:view_meter_reading_progress/view_meter_reading_progress.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('ja'),
    home: FTheme(
      data: FThemeData(touch: true, colors: FColors.neutralLight),
      child: child,
    ),
  );
}

/// 不定スピナーがあるため [pumpAndSettle] は使わない。
Future<void> _pumpFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// DialogRoute の退場アニメを進める。
Future<void> _pumpDismissed(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDown(LocalizeStringDelegate.resetDelegateForTest);

  testWidgets('外側タップでは閉じない', (tester) async {
    final dismiss = Completer<void>();
    addTearDown(() {
      if (!dismiss.isCompleted) {
        dismiss.complete();
      }
    });
    var canceled = false;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return FButton(
              onPress: () {
                unawaited(
                  MeterReadingProgressLauncher.show(
                    context,
                    onCancel: () async {
                      canceled = true;
                    },
                    untilDismiss: dismiss.future,
                  ),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await _pumpFrames(tester);
    expect(find.text('読み取り中…'), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await _pumpFrames(tester);
    expect(find.text('読み取り中…'), findsOneWidget);
    expect(canceled, isFalse);

    dismiss.complete();
    await _pumpDismissed(tester);
    expect(find.text('読み取り中…'), findsNothing);
  });

  testWidgets('中止ボタンで onCancel して閉じる', (tester) async {
    final dismiss = Completer<void>();
    addTearDown(() {
      if (!dismiss.isCompleted) {
        dismiss.complete();
      }
    });
    var canceled = false;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return FButton(
              onPress: () {
                unawaited(
                  MeterReadingProgressLauncher.show(
                    context,
                    onCancel: () async {
                      canceled = true;
                    },
                    untilDismiss: dismiss.future,
                  ),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await _pumpFrames(tester);
    await tester.tap(find.text('読み取りを中止'));
    await _pumpDismissed(tester);
    expect(canceled, isTrue);
    expect(find.text('読み取り中…'), findsNothing);
  });

  testWidgets('システム戻るで onCancel して閉じる', (tester) async {
    final dismiss = Completer<void>();
    addTearDown(() {
      if (!dismiss.isCompleted) {
        dismiss.complete();
      }
    });
    var canceled = false;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return FButton(
              onPress: () {
                unawaited(
                  MeterReadingProgressLauncher.show(
                    context,
                    onCancel: () async {
                      canceled = true;
                    },
                    untilDismiss: dismiss.future,
                  ),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await _pumpFrames(tester);

    await tester.binding.handlePopRoute();
    await _pumpDismissed(tester);
    expect(canceled, isTrue);
    expect(find.text('読み取り中…'), findsNothing);
  });

  testWidgets('untilDismiss 完了で閉じ二重 pop しない', (tester) async {
    final dismiss = Completer<void>();
    var cancelCount = 0;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return FButton(
              onPress: () {
                unawaited(
                  MeterReadingProgressLauncher.show(
                    context,
                    onCancel: () async {
                      cancelCount++;
                    },
                    untilDismiss: dismiss.future,
                  ),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await _pumpFrames(tester);
    dismiss.complete();
    await _pumpDismissed(tester);
    expect(find.text('読み取り中…'), findsNothing);
    expect(cancelCount, 0);
  });

  testWidgets('中止後の遅延完了でも背面画面を残す', (tester) async {
    final dismiss = Completer<void>();
    var cancelCount = 0;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return FButton(
              onPress: () {
                unawaited(
                  MeterReadingProgressLauncher.show(
                    context,
                    onCancel: () async {
                      cancelCount++;
                    },
                    untilDismiss: dismiss.future,
                  ),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await _pumpFrames(tester);
    await tester.tap(find.text('読み取りを中止'));
    await _pumpDismissed(tester);
    expect(find.text('読み取り中…'), findsNothing);
    expect(cancelCount, 1);

    dismiss.complete();
    await _pumpDismissed(tester);
    expect(cancelCount, 1);
    expect(find.text('open'), findsOneWidget);
  });
}
