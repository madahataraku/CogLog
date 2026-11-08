import 'package:state_stream/state_stream.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

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
/// ).execute();
/// ```
final class OnCapturePhotoDelegate {
  /// 写真取得と読み取りの依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnCapturePhotoDelegate(
  ///   state: state,
  ///   obtainMeterPhotoUsecase: obtainMeterPhotoUsecase,
  ///   readMeterPanelUsecase: readMeterPanelUsecase,
  /// );
  /// ```
  const OnCapturePhotoDelegate({
    required this.state,
    required this.obtainMeterPhotoUsecase,
    required this.readMeterPanelUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// 写真取得。
  final ObtainMeterPhotoUsecase obtainMeterPhotoUsecase;

  /// パネル読み取り。
  final ReadMeterPanelUsecase readMeterPanelUsecase;

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
    source: ObtainMeterPhotoSource.camera,
  );
}
