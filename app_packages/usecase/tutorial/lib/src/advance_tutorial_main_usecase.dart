import 'package:riverpod/riverpod.dart';

import 'advance_tutorial_main_request.dart';
import 'advance_tutorial_main_result.dart';

/// メイン導線の開始・次へ・目標保存後進行。
///
/// Example:
/// ```dart
/// AdvanceTutorialMainUsecase.provider;
/// ```
abstract interface class AdvanceTutorialMainUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// AdvanceTutorialMainUsecase.provider;
  /// ```
  static final provider = Provider<AdvanceTutorialMainUsecase>(
    (ref) => throw UnimplementedError('AdvanceTutorialMainUsecase.provider'),
  );

  /// [request] に応じて session を更新し、表示／完了を返す。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute(const AdvanceTutorialMainRequest.start());
  /// ```
  Future<AdvanceTutorialMainResult> execute(AdvanceTutorialMainRequest request);
}
