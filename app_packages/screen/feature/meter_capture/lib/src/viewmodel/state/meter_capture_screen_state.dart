import 'dart:typed_data';

import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';

import 'meter_capture_camera_ui.dart';
import 'meter_capture_step.dart';

/// メーター記録画面の可変状態。
///
/// Example:
/// ```dart
/// MeterCaptureScreenState.initial;
/// ```
final class MeterCaptureScreenState {
  /// 全フィールドを指定して作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreenState(step: MeterCaptureStep.photo);
  /// ```
  const MeterCaptureScreenState({
    required this.step,
    this.photoBytes,
    this.creationStartedAt,
    this.capturedAt,
    this.reading = false,
    this.saving = false,
    this.permissionDeniedKind,
    this.distanceKm,
    this.duration,
    this.caloriesKcal,
    this.averageSpeedKmh,
    this.averageSpeedFromPanel = false,
    this.averageSpeedUserEdited = false,
    this.recordedAt,
    this.recordedAtManuallySet = false,
    this.saveError = false,
    this.inputsInvalid = false,
    this.cameraUi = MeterCaptureCameraUi.idle,
    this.previewAspectRatio = 0.75,
    this.captureError = false,
    this.cameraSessionGeneration = 0,
    this.pendingModelDownloadGuidance = false,
  });

  /// 初期状態（1 ステップ目）。
  static const initial = MeterCaptureScreenState(step: MeterCaptureStep.photo);

  /// 現在ステップ。
  final MeterCaptureStep step;

  /// 写真バイト。
  final Uint8List? photoBytes;

  /// 作成開始日時。
  final DateTime? creationStartedAt;

  /// 撮影日時。
  final DateTime? capturedAt;

  /// 読み取り中。
  final bool reading;

  /// 保存中。
  final bool saving;

  /// 権限拒否の種別。
  final MeterPhotoPermissionKind? permissionDeniedKind;

  /// 走行距離。
  final double? distanceKm;

  /// 運動時間。
  final Duration? duration;

  /// 消費カロリー。
  final double? caloriesKcal;

  /// 平均速度。
  final double? averageSpeedKmh;

  /// 平均速度がパネル由来か。
  final bool averageSpeedFromPanel;

  /// 平均速度を利用者が明示編集したか。
  final bool averageSpeedUserEdited;

  /// 記録日時。
  final DateTime? recordedAt;

  /// 記録日時の手変更。
  final bool recordedAtManuallySet;

  /// 保存失敗表示。
  final bool saveError;

  /// 入力欄に解析できない文字列があるとき true。登録不可。
  final bool inputsInvalid;

  /// アプリ内カメラ UI 状態。
  final MeterCaptureCameraUi cameraUi;

  /// プレビュー縦横比。
  final double previewAspectRatio;

  /// シャッター失敗表示。
  final bool captureError;

  /// タブ離脱などで増える世代。非同期完了の破棄判定に使う。
  final int cameraSessionGeneration;

  /// モデル未ダウンロード誘導を表示予約しているとき true。
  final bool pendingModelDownloadGuidance;

  /// 一部だけ差し替えた新しい状態を返す。
  ///
  /// Example:
  /// ```dart
  /// state.copyWith(reading: true, clearPermissionDeniedKind: true);
  /// ```
  MeterCaptureScreenState copyWith({
    MeterCaptureStep? step,
    Uint8List? photoBytes,
    bool clearPhotoBytes = false,
    DateTime? creationStartedAt,
    bool clearCreationStartedAt = false,
    DateTime? capturedAt,
    bool clearCapturedAt = false,
    bool? reading,
    bool? saving,
    MeterPhotoPermissionKind? permissionDeniedKind,
    bool clearPermissionDeniedKind = false,
    double? distanceKm,
    bool clearDistanceKm = false,
    Duration? duration,
    bool clearDuration = false,
    double? caloriesKcal,
    bool clearCaloriesKcal = false,
    double? averageSpeedKmh,
    bool clearAverageSpeedKmh = false,
    bool? averageSpeedFromPanel,
    bool? averageSpeedUserEdited,
    DateTime? recordedAt,
    bool clearRecordedAt = false,
    bool? recordedAtManuallySet,
    bool? saveError,
    bool? inputsInvalid,
    MeterCaptureCameraUi? cameraUi,
    double? previewAspectRatio,
    bool? captureError,
    int? cameraSessionGeneration,
    bool? pendingModelDownloadGuidance,
  }) => MeterCaptureScreenState(
    step: step ?? this.step,
    photoBytes: clearPhotoBytes ? null : (photoBytes ?? this.photoBytes),
    creationStartedAt: clearCreationStartedAt
        ? null
        : (creationStartedAt ?? this.creationStartedAt),
    capturedAt: clearCapturedAt ? null : (capturedAt ?? this.capturedAt),
    reading: reading ?? this.reading,
    saving: saving ?? this.saving,
    permissionDeniedKind: clearPermissionDeniedKind
        ? null
        : (permissionDeniedKind ?? this.permissionDeniedKind),
    distanceKm: clearDistanceKm ? null : (distanceKm ?? this.distanceKm),
    duration: clearDuration ? null : (duration ?? this.duration),
    caloriesKcal: clearCaloriesKcal
        ? null
        : (caloriesKcal ?? this.caloriesKcal),
    averageSpeedKmh: clearAverageSpeedKmh
        ? null
        : (averageSpeedKmh ?? this.averageSpeedKmh),
    averageSpeedFromPanel: averageSpeedFromPanel ?? this.averageSpeedFromPanel,
    averageSpeedUserEdited:
        averageSpeedUserEdited ?? this.averageSpeedUserEdited,
    recordedAt: clearRecordedAt ? null : (recordedAt ?? this.recordedAt),
    recordedAtManuallySet: recordedAtManuallySet ?? this.recordedAtManuallySet,
    saveError: saveError ?? this.saveError,
    inputsInvalid: inputsInvalid ?? this.inputsInvalid,
    cameraUi: cameraUi ?? this.cameraUi,
    previewAspectRatio: previewAspectRatio ?? this.previewAspectRatio,
    captureError: captureError ?? this.captureError,
    cameraSessionGeneration:
        cameraSessionGeneration ?? this.cameraSessionGeneration,
    pendingModelDownloadGuidance:
        pendingModelDownloadGuidance ?? this.pendingModelDownloadGuidance,
  );
}
