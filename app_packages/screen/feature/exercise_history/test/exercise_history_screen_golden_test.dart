import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history/screen_feature_exercise_history.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';
import 'package:usecase_load_exercise_history_page_impl/usecase_load_exercise_history_page_impl.dart';

final class _Nav implements ScreenNavigation {
  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  void pop() {}

  @override
  void goToHomeTab() {}
}

void main() {
  testWidgets('運動履歴の空リスト / ja / Android / light', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
    addTearDown(LocalizeStringDelegate.resetDelegateForTest);

    final histories = MemoryExerciseHistoryRepository();

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            LoadExerciseHistoryPageUsecase.provider.overrideWith(
              (ref) => LoadExerciseHistoryPageUsecaseImpl(histories: histories),
            ),
            screenNavigationProvider.overrideWithValue(_Nav()),
          ],
          child: MaterialApp(
            locale: const Locale('ja'),
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: const ExerciseHistoryScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ExerciseHistoryScreen),
        matchesGoldenFile('goldens/exercise_history_empty.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
