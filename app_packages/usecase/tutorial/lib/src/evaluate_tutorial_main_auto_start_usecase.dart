import 'package:riverpod/riverpod.dart';

import 'evaluate_tutorial_main_auto_start_result.dart';

/// ホーム Ready・前面は呼び出し側前提。永続と session だけ見る。
///
/// Example:
/// ```dart
/// EvaluateTutorialMainAutoStartUsecase.provider;
/// ```
abstract interface class EvaluateTutorialMainAutoStartUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// EvaluateTutorialMainAutoStartUsecase.provider;
  /// ```
  static final provider = Provider<EvaluateTutorialMainAutoStartUsecase>(
    (ref) => throw UnimplementedError(
      'EvaluateTutorialMainAutoStartUsecase.provider',
    ),
  );

  /// 自動開始してよいなら [EvaluateTutorialMainAutoStartResult.shouldStart] true。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<EvaluateTutorialMainAutoStartResult> execute();
}
