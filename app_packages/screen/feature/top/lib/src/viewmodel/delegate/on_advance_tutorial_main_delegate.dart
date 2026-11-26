import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/top_screen_state.dart';

/// メイン段階を進め、結果を State に反映する。
///
/// 目標タブへの遷移は View がコーチマーク破棄後に行う。
///
/// Example:
/// ```dart
/// OnAdvanceTutorialMainDelegate(
///   state: state,
///   advanceUsecase: advanceUsecase,
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
  /// );
  /// ```
  const OnAdvanceTutorialMainDelegate({
    required this.state,
    required this.advanceUsecase,
  });

  /// 画面状態。
  final MutableStateStream<TopScreenState> state;

  /// 段階進行。
  final AdvanceTutorialMainUsecase advanceUsecase;

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
          // 段階3の次へは目標文脈へ渡すだけ。ホームの pending は立てない。
          // タブ遷移は View がオーバーレイ破棄後に行う。
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(
              current.copyWith(
                pendingTutorialMain: false,
                clearTutorialMainStep: true,
              ),
            );
          });
          break;
        }
        // ホーム上の段階連鎖（1→2→3 など）は View 側ループが続ける。
        // pending を立て直すと effect 再入で二重 show になるため、段階だけ残す。
        await state.updateWithLock((current, emitter) async {
          await emitter.emit(
            current.copyWith(
              pendingTutorialMain: false,
              tutorialMainStep: step,
            ),
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
        await state.updateWithLock((current, emitter) async {
          await emitter.emit(
            current.copyWith(
              pendingTutorialMain: false,
              clearTutorialMainStep: true,
            ),
          );
        });
    }
    return result;
  }
}
