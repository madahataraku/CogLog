import 'package:meta/meta.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

/// メーター VL モデル準備 Usecase を呼ぶ。
///
/// Example:
/// ```dart
/// OnPrepareMeterVlGuidanceDelegate(
///   prepareMeterVlModelUsecase: prepare,
/// ).execute();
/// ```
@internal
final class OnPrepareMeterVlGuidanceDelegate {
  /// [prepareMeterVlModelUsecase] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnPrepareMeterVlGuidanceDelegate(
  ///   prepareMeterVlModelUsecase: prepare,
  /// );
  /// ```
  const OnPrepareMeterVlGuidanceDelegate({
    required this.prepareMeterVlModelUsecase,
  });

  /// メーター VL モデル準備。
  final PrepareMeterVlModelUsecase prepareMeterVlModelUsecase;

  /// 準備進捗を流す。例外は呼び出し側（Dialog）が掴む。
  ///
  /// Example:
  /// ```dart
  /// await for (final progress in delegate.execute()) {
  ///   progress;
  /// }
  /// ```
  Stream<double> execute() => prepareMeterVlModelUsecase.execute();
}
