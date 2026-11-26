import 'tutorial_kind.dart';
import 'tutorial_main_step.dart';

/// 表示中・メイン途中段階・同一プロセス再自動抑止。
///
/// 永続しない。プロセス再起動で消える。
///
/// Example:
/// ```dart
/// TutorialRuntimeSession();
/// ```
final class TutorialRuntimeSession {
  /// 未表示のセッションを作る。
  ///
  /// Example:
  /// ```dart
  /// TutorialRuntimeSession();
  /// ```
  TutorialRuntimeSession();

  /// 表示中の種類。未表示は null。
  TutorialKind? activeKind;

  /// メイン進行中の段階。メイン以外／未表示は null。
  TutorialMainStep? mainStep;

  /// インポート未完了化・完了書込失敗後。次プロセスまでメイン自動なし。
  bool suppressMainAutoStartThisProcess = false;

  /// 再表示タイル押下瞬間の二重起動防止。開始確定後に下ろす。
  bool manualStartGuard = false;

  /// 同一プロセスで文脈を出した種類（永続成功を待たず再出し防止）。
  final Set<TutorialKind> _presentedContextsThisProcess = {};

  /// 何か表示中なら true。
  ///
  /// Example:
  /// ```dart
  /// session.isShowing;
  /// ```
  bool get isShowing => activeKind != null;

  /// メイン表示中なら段階を捨てて閉じる（mainCompleted は触らない）。
  ///
  /// Example:
  /// ```dart
  /// session.interruptMain();
  /// ```
  void interruptMain() {
    if (activeKind != TutorialKind.main) {
      return;
    }
    activeKind = null;
    mainStep = null;
  }

  /// 表示中フラグとメイン段階を消す。
  ///
  /// Example:
  /// ```dart
  /// session.clearActive();
  /// ```
  void clearActive() {
    activeKind = null;
    mainStep = null;
  }

  /// 文脈 [kind] をこのプロセスで提示済みにする。
  ///
  /// Example:
  /// ```dart
  /// session.markContextPresented(TutorialKind.camera);
  /// ```
  void markContextPresented(TutorialKind kind) {
    if (kind == TutorialKind.main) {
      return;
    }
    _presentedContextsThisProcess.add(kind);
  }

  /// 文脈 [kind] のプロセス内提示済みだけを捨てる（表示失敗時の再試行用）。
  ///
  /// Example:
  /// ```dart
  /// session.clearContextPresented(TutorialKind.goalSettings);
  /// ```
  void clearContextPresented(TutorialKind kind) {
    _presentedContextsThisProcess.remove(kind);
  }

  /// このプロセスで [kind] を既に出したか。
  ///
  /// Example:
  /// ```dart
  /// session.hasContextPresentedThisProcess(TutorialKind.camera);
  /// ```
  bool hasContextPresentedThisProcess(TutorialKind kind) =>
      _presentedContextsThisProcess.contains(kind);

  /// 再表示用に文脈のプロセス内提示済みを捨てる。
  ///
  /// Example:
  /// ```dart
  /// session.clearPresentedContextsThisProcess();
  /// ```
  void clearPresentedContextsThisProcess() {
    _presentedContextsThisProcess.clear();
  }
}
