/// 入力欄へ出す表示用文字列と誘導予約。
///
/// Example:
/// ```dart
/// const MeterCaptureScreenEntity(
///   distanceText: '1.0',
///   hoursText: '0',
///   minutesText: '30',
///   secondsText: '0',
///   averageSpeedText: '2.0',
///   caloriesText: '100',
///   recordedAtText: '2026-11-08T12:00:00.000',
///   pendingModelDownloadGuidance: false,
///   showHandEntryGuidance: false,
/// );
/// ```
final class MeterCaptureScreenEntity {
  /// 表示用文字列と誘導予約をすべて指定して作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreenEntity(
  ///   distanceText: '1.0',
  ///   hoursText: '0',
  ///   minutesText: '30',
  ///   secondsText: '0',
  ///   averageSpeedText: '2.0',
  ///   caloriesText: '100',
  ///   recordedAtText: '2026-11-08T12:00:00.000',
  ///   pendingModelDownloadGuidance: false,
  ///   showHandEntryGuidance: false,
  /// );
  /// ```
  const MeterCaptureScreenEntity({
    required this.distanceText,
    required this.hoursText,
    required this.minutesText,
    required this.secondsText,
    required this.averageSpeedText,
    required this.caloriesText,
    required this.recordedAtText,
    required this.pendingModelDownloadGuidance,
    required this.showHandEntryGuidance,
  });

  /// 走行距離の表示文字列。
  final String distanceText;

  /// 運動時間・時の表示文字列。
  final String hoursText;

  /// 運動時間・分の表示文字列。
  final String minutesText;

  /// 運動時間・秒の表示文字列。
  final String secondsText;

  /// 平均速度の表示文字列。
  final String averageSpeedText;

  /// 消費カロリーの表示文字列。
  final String caloriesText;

  /// 記録日時の表示文字列。
  final String recordedAtText;

  /// モデル未ダウンロード誘導を表示予約しているとき true。
  final bool pendingModelDownloadGuidance;

  /// 手打ち案内を編集画面に出すとき true。
  final bool showHandEntryGuidance;
}
