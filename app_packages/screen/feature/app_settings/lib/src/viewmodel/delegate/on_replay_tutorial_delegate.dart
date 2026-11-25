import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

/// チュートリアルを全リセットしホームへ戻す。
///
/// Example:
/// ```dart
/// OnReplayTutorialDelegate(
///   navigation: navigation,
///   resetUsecase: resetUsecase,
///   session: session,
/// ).execute();
/// ```
final class OnReplayTutorialDelegate {
  /// 遷移・リセット・session を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnReplayTutorialDelegate(
  ///   navigation: navigation,
  ///   resetUsecase: resetUsecase,
  ///   session: session,
  /// );
  /// ```
  const OnReplayTutorialDelegate({
    required this.navigation,
    required this.resetUsecase,
    required this.session,
  });

  /// 画面遷移。
  final ScreenNavigation navigation;

  /// 進捗リセット。
  final ResetTutorialProgressUsecase resetUsecase;

  /// プロセス内実行状態（ガード解除用）。
  final TutorialRuntimeSession session;

  /// 表示中コーチマークを捨て、進捗を初期化しホームへ戻す。
  ///
  /// Reset 直後の二重起動は [TutorialRuntimeSession.manualStartGuard] で防ぎ、
  /// ホーム到達後にガードを下ろして自動開始に任せる。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    CoachMarkLauncher.dismissActive();
    await resetUsecase.execute();
    navigation.goToHomeTab();
    // ホーム Ready×前面の Evaluate が走れるようガードを下ろす。
    session.manualStartGuard = false;
  }
}
