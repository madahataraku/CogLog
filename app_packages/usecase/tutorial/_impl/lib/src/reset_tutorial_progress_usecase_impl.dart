import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

/// 進捗を initial にし手動開始ガードを立てる。
///
/// Example:
/// ```dart
/// ResetTutorialProgressUsecaseImpl(
///   repository: repository,
///   session: session,
/// );
/// ```
final class ResetTutorialProgressUsecaseImpl
    implements ResetTutorialProgressUsecase {
  /// [repository] と [session] を使う。
  ///
  /// Example:
  /// ```dart
  /// ResetTutorialProgressUsecaseImpl(
  ///   repository: repository,
  ///   session: session,
  /// );
  /// ```
  ResetTutorialProgressUsecaseImpl({
    required this.repository,
    required this.session,
  });

  /// チュートリアル進捗。
  final TutorialRepository repository;

  /// プロセス内実行状態。
  final TutorialRuntimeSession session;

  /// 書込失敗時は suppress を立てる（画面はタイル無反応にしない）。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<void> execute() async {
    try {
      await repository.write(TutorialProgress.initial);
      session.clearActive();
      session.clearPresentedContextsThisProcess();
      session.suppressMainAutoStartThisProcess = false;
      session.manualStartGuard = true;
    } on Object {
      session.suppressMainAutoStartThisProcess = true;
      session.clearActive();
    }
  }
}
