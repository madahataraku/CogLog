import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';

import 'meter_in_app_camera_status.dart';
import 'meter_photo_capture.dart';

/// カメラ／ライブラリからメーターパネル写真を取る。
///
/// Example:
/// ```dart
/// await source.captureWithCamera();
/// ```
abstract interface class MeterPhotoSource {
  /// アプリ内カメラ状態。start 前は idle。
  ///
  /// Example:
  /// ```dart
  /// source.watchInAppCamera();
  /// ```
  Stream<MeterInAppCameraStatus> watchInAppCamera();

  /// 権限要求＋プレビュー開始。拒否・失敗は status で示す。
  ///
  /// Example:
  /// ```dart
  /// await source.startInAppCamera();
  /// ```
  Future<void> startInAppCamera();

  /// プレビュー停止とカメラ資源解放。
  ///
  /// Example:
  /// ```dart
  /// await source.stopInAppCamera();
  /// ```
  Future<void> stopInAppCamera();

  /// ready のときプレビュー Widget。未 ready は空。
  ///
  /// Example:
  /// ```dart
  /// source.buildInAppPreview();
  /// ```
  Widget buildInAppPreview({Key? key});

  /// アプリ内カメラで撮影。キャンセル／未 ready は null。権限拒否は例外。
  ///
  /// Example:
  /// ```dart
  /// await source.captureWithCamera();
  /// ```
  Future<MeterPhotoCapture?> captureWithCamera();

  /// ライブラリ選択。キャンセルは null。権限拒否は例外。
  ///
  /// Example:
  /// ```dart
  /// await source.pickFromLibrary();
  /// ```
  Future<MeterPhotoCapture?> pickFromLibrary();
}

/// メーター写真取得の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// meterPhotoSourceProvider;
/// ```
final meterPhotoSourceProvider = Provider<MeterPhotoSource>(
  (ref) => throw UnimplementedError('meterPhotoSourceProvider'),
);
