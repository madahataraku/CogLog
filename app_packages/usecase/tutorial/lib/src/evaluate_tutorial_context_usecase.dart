import 'package:riverpod/riverpod.dart';

import 'evaluate_tutorial_context_request.dart';
import 'evaluate_tutorial_context_result.dart';

/// 文脈チュートリアルの表示要否。メイン表示中なら中断する。
///
/// Example:
/// ```dart
/// EvaluateTutorialContextUsecase.provider;
/// ```
abstract interface class EvaluateTutorialContextUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// EvaluateTutorialContextUsecase.provider;
  /// ```
  static final provider = Provider<EvaluateTutorialContextUsecase>(
    (ref) =>
        throw UnimplementedError('EvaluateTutorialContextUsecase.provider'),
  );

  /// [request] の文脈を出してよいか返す。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute(
  ///   const EvaluateTutorialContextRequest(kind: TutorialKind.trends),
  /// );
  /// ```
  Future<EvaluateTutorialContextResult> execute(
    EvaluateTutorialContextRequest request,
  );
}
