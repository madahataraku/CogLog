import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/top_screen_state.dart';

/// メイン段階を進め、結果を State に反映する。
///
/// Example:
/// ```dart
/// OnAdvanceTutorialMainDelegate(
///   state: state,
///   advanceUsecase: advanceUsecase,
///   navigation: navigation,
/// ).execute(const AdvanceTutorialMainRequest.next());
/// ```
final class OnAdvanceTutorialMainDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnAdvanceTutorialMainDelegate(
  ///   state: state,
  ///   advanceUsecase: advanceUsecase,
  ///   navigation: navigation,
  /// );
  /// ```
  const OnAdvanceTutorialMainDelegate({
    required this.state,
    required this.advanceUsecase,
    required this.navigation,
  });

  /// 画面状態。
  final MutableStateStream<TopScreenState> state;

  /// 段階進行。
  final AdvanceTutorialMainUsecase advanceUsecase;

  /// 目標タブ誘導用。
  final ScreenNavigation navigation;

  /// [request] を実行し、show なら pending、completed なら段階を消す。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute(const AdvanceTutorialMainRequest.next());
  /// ```
  Future<AdvanceTutorialMainResult> execute(
    AdvanceTutorialMainRequest request,
  ) async {
    final result = await advanceUsecase.execute(request);
    switch (result) {
      case AdvanceTutorialMainShowResult(:final step, :final navigateToGoalTab):
        if (navigateToGoalTab) {
          navigation.goToGoalSettingsTab();
        }
        await state.updateWithLock((current, emitter) async {
          await emitter.emit(
            current.copyWith(pendingTutorialMain: true, tutorialMainStep: step),
          );
        });
      case AdvanceTutorialMainCompletedResult():
        await state.updateWithLock((current, emitter) async {
          await emitter.emit(
            current.copyWith(
              pendingTutorialMain: false,
              clearTutorialMainStep: true,
            ),
          );
        });
      case AdvanceTutorialMainNoopResult():
        break;
    }
    return result;
  }
}
