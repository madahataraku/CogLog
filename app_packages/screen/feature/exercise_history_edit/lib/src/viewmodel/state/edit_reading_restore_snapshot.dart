import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';

import 'exercise_history_edit_screen_state.dart';

/// 再アップロード開始前の復元用スナップショット。
///
/// Example:
/// ```dart
/// EditReadingRestoreSnapshot.from(state);
/// ```
@internal
final class EditReadingRestoreSnapshot {
  /// 復元に必要な項目をすべて持つ。
  ///
  /// Example:
  /// ```dart
  /// EditReadingRestoreSnapshot.from(state);
  /// ```
  const EditReadingRestoreSnapshot({
    required this.photoPath,
    required this.photoBytes,
    required this.capturedAt,
    required this.recordedAt,
    required this.recordedAtManuallySet,
    required this.distanceKm,
    required this.duration,
    required this.caloriesKcal,
    required this.averageSpeedKmh,
    required this.showHandEntryGuidance,
    required this.dirty,
    required this.distanceInvalid,
    required this.durationInvalid,
    required this.caloriesInvalid,
    required this.recordedAtInvalid,
    required this.permissionDeniedKind,
  });

  /// [state] の再アップロード前の値を写す。
  ///
  /// Example:
  /// ```dart
  /// EditReadingRestoreSnapshot.from(state);
  /// ```
  factory EditReadingRestoreSnapshot.from(
    ExerciseHistoryEditScreenState state,
  ) => EditReadingRestoreSnapshot(
    photoPath: state.photoPath,
    photoBytes: state.photoBytes,
    capturedAt: state.capturedAt,
    recordedAt: state.recordedAt,
    recordedAtManuallySet: state.recordedAtManuallySet,
    distanceKm: state.distanceKm,
    duration: state.duration,
    caloriesKcal: state.caloriesKcal,
    averageSpeedKmh: state.averageSpeedKmh,
    showHandEntryGuidance: state.showHandEntryGuidance,
    dirty: state.dirty,
    distanceInvalid: state.distanceInvalid,
    durationInvalid: state.durationInvalid,
    caloriesInvalid: state.caloriesInvalid,
    recordedAtInvalid: state.recordedAtInvalid,
    permissionDeniedKind: state.permissionDeniedKind,
  );

  /// 再アップロード前の既存写真パス。
  final String? photoPath;

  /// 再アップロード前の差し替え写真バイト。
  final Uint8List? photoBytes;

  /// 再アップロード前の撮影日時。
  final DateTime? capturedAt;

  /// 再アップロード前の運動した日時。
  final DateTime? recordedAt;

  /// 再アップロード前の運動した日時の手変更有無。
  final bool recordedAtManuallySet;

  /// 再アップロード前の走行距離。
  final double? distanceKm;

  /// 再アップロード前の運動時間。
  final Duration? duration;

  /// 再アップロード前の消費カロリー。
  final double? caloriesKcal;

  /// 再アップロード前の平均速度。
  final double? averageSpeedKmh;

  /// 再アップロード前の手打ち案内表示。
  final bool showHandEntryGuidance;

  /// 再アップロード前の未保存変更有無。
  final bool dirty;

  /// 再アップロード前の距離入力不正。
  final bool distanceInvalid;

  /// 再アップロード前の時間入力不正。
  final bool durationInvalid;

  /// 再アップロード前のカロリー入力不正。
  final bool caloriesInvalid;

  /// 再アップロード前の日時入力不正。
  final bool recordedAtInvalid;

  /// 再アップロード前の権限拒否種別。
  final MeterPhotoPermissionKind? permissionDeniedKind;
}
