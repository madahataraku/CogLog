import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';

import 'meter_in_app_camera_ui_status.dart';

/// アプリ内カメラの開始・停止・状態購読。
///
/// Example:
/// ```dart
/// ControlMeterInAppCameraUsecase.provider;
/// ```
abstract interface class ControlMeterInAppCameraUsecase {
  /// 注入点。未接続のときは失敗する。
  ///
  /// Example:
  /// ```dart
  /// ControlMeterInAppCameraUsecase.provider;
  /// ```
  static final provider = Provider<ControlMeterInAppCameraUsecase>(
    (ref) => throw UnimplementedError('ControlMeterInAppCameraUsecase.provider'),
  );

  /// 画面向けカメラ状態。
  ///
  /// Example:
  /// ```dart
  /// usecase.watch();
  /// ```
  Stream<MeterInAppCameraUiStatus> watch();

  /// プレビューを開始する。
  ///
  /// Example:
  /// ```dart
  /// await usecase.start();
  /// ```
  Future<void> start();

  /// プレビューを停止する。
  ///
  /// Example:
  /// ```dart
  /// await usecase.stop();
  /// ```
  Future<void> stop();

  /// ready 時のプレビュー Widget。
  ///
  /// Example:
  /// ```dart
  /// usecase.buildPreview();
  /// ```
  Widget buildPreview({Key? key});
}
