import 'package:state_stream/state_stream.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../state/meter_capture_screen_state.dart';
import 'obtain_and_read_meter_photo.dart';

/// カメラ撮影から読み取りまでを進める。
///
/// Example:
/// ```dart
/// OnCapturePhotoDelegate(
///   state: state,
///   obtainMeterPhotoUsecase: obtainMeterPhotoUsecase,
///   readMeterPanelUsecase: readMeterPanelUsecase,
///   evaluateOnDeviceLlmGuidanceUsecase: evaluate,
///   guidanceSession: session,
/// ).execute();
/// ```
final class OnCapturePhotoDelegate {
  /// 写真取得・読み取り・誘導判定の依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnCapturePhotoDelegate(
  ///   state: state,
  ///   obtainMeterPhotoUsecase: obtainMeterPhotoUsecase,
  ///   readMeterPanelUsecase: readMeterPanelUsecase,
  ///   evaluateOnDeviceLlmGuidanceUsecase: evaluate,
  ///   guidanceSession: session,
  /// );
  /// ```
  const OnCapturePhotoDelegate({
    required this.state,
    required this.obtainMeterPhotoUsecase,
    required this.readMeterPanelUsecase,
    required this.evaluateOnDeviceLlmGuidanceUsecase,
    required this.guidanceSession,
  });

  /// 更新する画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// 写真取得。
  final ObtainMeterPhotoUsecase obtainMeterPhotoUsecase;

  /// パネル読み取り。
  final ReadMeterPanelUsecase readMeterPanelUsecase;

  /// モデル未ダウンロード誘導の要否。
  final EvaluateOnDeviceLlmGuidanceUsecase evaluateOnDeviceLlmGuidanceUsecase;

  /// プロセス内の誘導再表示抑制。
  final OnDeviceLlmGuidanceSession guidanceSession;

  /// カメラから写真を取り、成功時は読み取りへ進む。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() => obtainAndReadMeterPhoto(
    state: state,
    obtainMeterPhotoUsecase: obtainMeterPhotoUsecase,
    readMeterPanelUsecase: readMeterPanelUsecase,
    evaluateOnDeviceLlmGuidanceUsecase: evaluateOnDeviceLlmGuidanceUsecase,
    guidanceSession: guidanceSession,
    source: ObtainMeterPhotoSource.camera,
  );
}
