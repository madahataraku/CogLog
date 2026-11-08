import 'dart:typed_data';

/// 運動履歴として保存するメーター記録。
///
/// Example:
/// ```dart
/// SaveMeterCaptureRequest(
///   creationStartedAt: DateTime.timestamp(),
///   capturedAt: DateTime.timestamp(),
///   recordedAt: DateTime.timestamp(),
///   recordedAtManuallySet: false,
///   distanceKm: 1,
///   duration: const Duration(minutes: 1),
///   caloriesKcal: 1,
///   averageSpeedKmh: 1,
///   photoBytes: Uint8List(0),
/// );
/// ```
final class SaveMeterCaptureRequest {
  /// 永続化に必要な項目をすべて指定する。
  ///
  /// Example:
  /// ```dart
  /// SaveMeterCaptureRequest(
  ///   creationStartedAt: DateTime.timestamp(),
  ///   capturedAt: DateTime.timestamp(),
  ///   recordedAt: DateTime.timestamp(),
  ///   recordedAtManuallySet: false,
  ///   distanceKm: 1,
  ///   duration: const Duration(minutes: 1),
  ///   caloriesKcal: 1,
  ///   averageSpeedKmh: 1,
  ///   photoBytes: Uint8List(0),
  /// );
  /// ```
  const SaveMeterCaptureRequest({
    required this.creationStartedAt,
    required this.capturedAt,
    required this.recordedAt,
    required this.recordedAtManuallySet,
    required this.distanceKm,
    required this.duration,
    required this.caloriesKcal,
    required this.averageSpeedKmh,
    required this.photoBytes,
  });

  /// 作成開始日時。
  final DateTime creationStartedAt;

  /// 撮影日時。
  final DateTime capturedAt;

  /// 記録日時。
  final DateTime recordedAt;

  /// 記録日時を利用者が手で変えたか。
  final bool recordedAtManuallySet;

  /// 走行距離 km。
  final double distanceKm;

  /// 運動時間。
  final Duration duration;

  /// 消費カロリー kcal。
  final double caloriesKcal;

  /// 平均速度 km/h。
  final double averageSpeedKmh;

  /// メーターパネル写真。
  final Uint8List photoBytes;
}
