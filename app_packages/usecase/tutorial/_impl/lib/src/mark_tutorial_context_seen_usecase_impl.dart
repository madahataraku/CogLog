import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

/// 文脈閉じ時に *ContextSeen を書く。
///
/// Example:
/// ```dart
/// MarkTutorialContextSeenUsecaseImpl(
///   repository: repository,
///   session: session,
/// );
/// ```
final class MarkTutorialContextSeenUsecaseImpl
    implements MarkTutorialContextSeenUsecase {
  /// [repository] と [session] を使う。
  ///
  /// Example:
  /// ```dart
  /// MarkTutorialContextSeenUsecaseImpl(
  ///   repository: repository,
  ///   session: session,
  /// );
  /// ```
  MarkTutorialContextSeenUsecaseImpl({
    required this.repository,
    required this.session,
  });

  /// チュートリアル進捗。
  final TutorialRepository repository;

  /// プロセス内実行状態。
  final TutorialRuntimeSession session;

  /// 永続を更新し session の表示中を消す。書込失敗は握りつぶす。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute(
  ///   const MarkTutorialContextSeenRequest(kind: TutorialKind.camera),
  /// );
  /// ```
  @override
  Future<void> execute(MarkTutorialContextSeenRequest request) async {
    final kind = request.kind;
    if (kind == TutorialKind.main) {
      return;
    }
    session.clearActive();
    try {
      final current = await repository.read();
      final next = switch (kind) {
        TutorialKind.camera => current.copyWith(cameraContextSeen: true),
        TutorialKind.meterEdit => current.copyWith(meterEditContextSeen: true),
        TutorialKind.trends => current.copyWith(trendsContextSeen: true),
        TutorialKind.history => current.copyWith(historyContextSeen: true),
        TutorialKind.achievement => current.copyWith(
          achievementContextSeen: true,
        ),
        TutorialKind.main => current,
      };
      await repository.write(next);
    } on Object {
      // 文脈の再出しは session の presented と read 失敗契約に任せる。
    }
  }
}
