import 'dart:typed_data';

import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';

/// 運動履歴編集画面の作業中状態。
///
/// Example:
/// ```dart
/// ExerciseHistoryEditScreenState.initial(id: 'id');
/// ```
final class ExerciseHistoryEditScreenState {
  /// 編集中の値と読込／保存フラグを持つ。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryEditScreenState.initial(id: 'id');
  /// ```
  const ExerciseHistoryEditScreenState({
    required this.id,
    required this.loading,
    required this.missing,
    required this.loadError,
    required this.saving,
    required this.reading,
    required this.dirty,
    required this.saveError,
    required this.inputsInvalid,
    required this.showHandEntryGuidance,
    required this.photoPath,
    required this.photoBytes,
    required this.creationStartedAt,
    required this.capturedAt,
    required this.recordedAt,
    required this.distanceKm,
    required this.duration,
    required this.caloriesKcal,
    required this.averageSpeedKmh,
    required this.previousHealthWorkoutId,
    required this.permissionDeniedKind,
    required this.photoSessionGeneration,
  });

  /// まだ読んでいない状態。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryEditScreenState.initial(id: 'id');
  /// ```
  factory ExerciseHistoryEditScreenState.initial({required String id}) =>
      ExerciseHistoryEditScreenState(
        id: id,
        loading: false,
        missing: false,
        loadError: false,
        saving: false,
        reading: false,
        dirty: false,
        saveError: false,
        inputsInvalid: false,
        showHandEntryGuidance: false,
        photoPath: null,
        photoBytes: null,
        creationStartedAt: null,
        capturedAt: null,
        recordedAt: null,
        distanceKm: null,
        duration: null,
        caloriesKcal: null,
        averageSpeedKmh: null,
        previousHealthWorkoutId: null,
        permissionDeniedKind: null,
        photoSessionGeneration: 0,
      );

  /// 対象の運動履歴 ID。
  final String id;

  /// 初期読込中か。
  final bool loading;

  /// 対象が無いとき true。
  final bool missing;

  /// 初期読込失敗。
  final bool loadError;

  /// 保存処理中か。
  final bool saving;

  /// 写真読み取り中か。
  final bool reading;

  /// 未保存の変更があるか。
  final bool dirty;

  /// 保存失敗を示すか。
  final bool saveError;

  /// 入力が不正で保存できないか。
  final bool inputsInvalid;

  /// 手打ち案内を出すか。
  final bool showHandEntryGuidance;

  /// 既存写真の絶対パス。差し替え後も参照用に残してよい。
  final String? photoPath;

  /// 差し替えた写真バイト。null なら既存写真を維持する。
  final Uint8List? photoBytes;

  /// 作成開始日時（既存値を維持）。
  final DateTime? creationStartedAt;

  /// 撮影日時。
  final DateTime? capturedAt;

  /// 記録日時。
  final DateTime? recordedAt;

  /// 走行距離 km。
  final double? distanceKm;

  /// 運動時間。
  final Duration? duration;

  /// 消費カロリー kcal。
  final double? caloriesKcal;

  /// 表示用の平均速度（距離÷時間で再計算）。
  final double? averageSpeedKmh;

  /// 更新前のヘルスワークアウト ID。
  final String? previousHealthWorkoutId;

  /// 権限拒否の種別。無ければ null。
  final MeterPhotoPermissionKind? permissionDeniedKind;

  /// 写真取得セッション世代。古い非同期結果を捨てる。
  final int photoSessionGeneration;

  /// 一部だけ差し替えた新しい状態を返す。
  ///
  /// Example:
  /// ```dart
  /// state.copyWith(dirty: true);
  /// ```
  ExerciseHistoryEditScreenState copyWith({
    String? id,
    bool? loading,
    bool? missing,
    bool? loadError,
    bool? saving,
    bool? reading,
    bool? dirty,
    bool? saveError,
    bool? inputsInvalid,
    bool? showHandEntryGuidance,
    String? photoPath,
    bool clearPhotoPath = false,
    Uint8List? photoBytes,
    bool clearPhotoBytes = false,
    DateTime? creationStartedAt,
    bool clearCreationStartedAt = false,
    DateTime? capturedAt,
    bool clearCapturedAt = false,
    DateTime? recordedAt,
    bool clearRecordedAt = false,
    double? distanceKm,
    bool clearDistanceKm = false,
    Duration? duration,
    bool clearDuration = false,
    double? caloriesKcal,
    bool clearCaloriesKcal = false,
    double? averageSpeedKmh,
    bool clearAverageSpeedKmh = false,
    String? previousHealthWorkoutId,
    bool clearPreviousHealthWorkoutId = false,
    MeterPhotoPermissionKind? permissionDeniedKind,
    bool clearPermissionDeniedKind = false,
    int? photoSessionGeneration,
  }) => ExerciseHistoryEditScreenState(
    id: id ?? this.id,
    loading: loading ?? this.loading,
    missing: missing ?? this.missing,
    loadError: loadError ?? this.loadError,
    saving: saving ?? this.saving,
    reading: reading ?? this.reading,
    dirty: dirty ?? this.dirty,
    saveError: saveError ?? this.saveError,
    inputsInvalid: inputsInvalid ?? this.inputsInvalid,
    showHandEntryGuidance: showHandEntryGuidance ?? this.showHandEntryGuidance,
    photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
    photoBytes: clearPhotoBytes ? null : (photoBytes ?? this.photoBytes),
    creationStartedAt: clearCreationStartedAt
        ? null
        : (creationStartedAt ?? this.creationStartedAt),
    capturedAt: clearCapturedAt ? null : (capturedAt ?? this.capturedAt),
    recordedAt: clearRecordedAt ? null : (recordedAt ?? this.recordedAt),
    distanceKm: clearDistanceKm ? null : (distanceKm ?? this.distanceKm),
    duration: clearDuration ? null : (duration ?? this.duration),
    caloriesKcal: clearCaloriesKcal
        ? null
        : (caloriesKcal ?? this.caloriesKcal),
    averageSpeedKmh: clearAverageSpeedKmh
        ? null
        : (averageSpeedKmh ?? this.averageSpeedKmh),
    previousHealthWorkoutId: clearPreviousHealthWorkoutId
        ? null
        : (previousHealthWorkoutId ?? this.previousHealthWorkoutId),
    permissionDeniedKind: clearPermissionDeniedKind
        ? null
        : (permissionDeniedKind ?? this.permissionDeniedKind),
    photoSessionGeneration:
        photoSessionGeneration ?? this.photoSessionGeneration,
  );
}
