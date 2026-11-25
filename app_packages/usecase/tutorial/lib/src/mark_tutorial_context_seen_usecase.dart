import 'package:riverpod/riverpod.dart';

import 'mark_tutorial_context_seen_request.dart';

/// 文脈を閉じたときに永続の *ContextSeen を立てる。
///
/// Example:
/// ```dart
/// MarkTutorialContextSeenUsecase.provider;
/// ```
abstract interface class MarkTutorialContextSeenUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// MarkTutorialContextSeenUsecase.provider;
  /// ```
  static final provider = Provider<MarkTutorialContextSeenUsecase>(
    (ref) =>
        throw UnimplementedError('MarkTutorialContextSeenUsecase.provider'),
  );

  /// [request.kind] の表示済みを書く。失敗しても throw しない契約は実装側。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute(
  ///   const MarkTutorialContextSeenRequest(kind: TutorialKind.camera),
  /// );
  /// ```
  Future<void> execute(MarkTutorialContextSeenRequest request);
}
