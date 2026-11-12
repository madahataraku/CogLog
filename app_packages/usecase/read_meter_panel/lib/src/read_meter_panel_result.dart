import 'package:domain_exercise_history/domain_exercise_history.dart';

/// 読み取り結果と、平均速度がパネル由来かどうか。
///
/// Example:
/// ```dart
/// const ReadMeterPanelResult(
///   values: MeterReadingValues(),
///   averageSpeedFromPanel: false,
/// );
/// ```
final class ReadMeterPanelResult {
  /// [values] と [averageSpeedFromPanel] を持つ結果を作る。
  ///
  /// Example:
  /// ```dart
  /// const ReadMeterPanelResult(
  ///   values: MeterReadingValues(),
  ///   averageSpeedFromPanel: false,
  /// );
  /// ```
  const ReadMeterPanelResult({
    required this.values,
    required this.averageSpeedFromPanel,
  });

  /// マージ後の計測値。
  final MeterReadingValues values;

  /// 平均速度がパネル由来か。常に距離÷時間のため常に false。
  final bool averageSpeedFromPanel;
}
