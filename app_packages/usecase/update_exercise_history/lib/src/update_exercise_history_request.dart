import 'dart:typed_data';

/// 運動履歴 1 件を更新する入力。
///
/// Example:
/// ```dart
/// UpdateExerciseHistoryRequest(
///   id: '11111111-1111-4111-8111-111111111111',
///   creationStartedAt: DateTime.timestamp(),
///   capturedAt: DateTime.timestamp(),
///   recordedAt: DateTime.timestamp(),
///   distanceKm: 1,
///   duration: const Duration(minutes: 1),
///   caloriesKcal: 1,
///   previousHealthWorkoutId: null,
/// );
/// ```
final class UpdateExerciseHistoryRequest {
  /// 更新に必要な項目を指定する。[photoBytes] が null なら写真は維持する。
  ///
  /// Example:
  /// ```dart
  /// UpdateExerciseHistoryRequest(
  ///   id: '11111111-1111-4111-8111-111111111111',
  ///   creationStartedAt: DateTime.timestamp(),
  ///   capturedAt: DateTime.timestamp(),
  ///   recordedAt: DateTime.timestamp(),
  ///   distanceKm: 1,
  ///   duration: const Duration(minutes: 1),
  ///   caloriesKcal: 1,
  ///   previousHealthWorkoutId: null,
  /// );
  /// ```
  const UpdateExerciseHistoryRequest({
    required this.id,
    required this.creationStartedAt,
    required this.capturedAt,
    required this.recordedAt,
    required this.distanceKm,
    required this.duration,
    required this.caloriesKcal,
    required this.previousHealthWorkoutId,
    this.photoBytes,
  });

  /// 更新対象の運動履歴 ID。
  final String id;

  /// 作成開始日時（既存値を維持して渡す）。
  final DateTime creationStartedAt;

  /// 撮影日時（写真差し替え時は新値、それ以外は既存値）。
  final DateTime capturedAt;

  /// 記録日時。
  final DateTime recordedAt;

  /// 走行距離 km。
  final double distanceKm;

  /// 運動時間。
  final Duration duration;

  /// 消費カロリー kcal。
  final double caloriesKcal;

  /// 更新前に履歴が持つヘルスワークアウト ID。null ならヘルス更新しない。
  final String? previousHealthWorkoutId;

  /// 差し替える写真。null なら既存写真を維持する。
  final Uint8List? photoBytes;
}
