import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

import '../state/exercise_history_edit_screen_state.dart';
import 'obtain_and_read_edit_photo.dart';

/// カメラで写真を撮り直し、読み取り結果をフィールドへ載せる。
///
/// Example:
/// ```dart
/// OnRetakePhotoDelegate(
///   state: state,
///   obtainMeterPhotoUsecase: obtain,
///   readMeterPanelUsecase: read,
/// ).execute();
/// ```
@internal
final class OnRetakePhotoDelegate {
  /// 写真取得と読み取りの依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnRetakePhotoDelegate(
  ///   state: state,
  ///   obtainMeterPhotoUsecase: obtain,
  ///   readMeterPanelUsecase: read,
  /// );
  /// ```
  const OnRetakePhotoDelegate({
    required this.state,
    required this.obtainMeterPhotoUsecase,
    required this.readMeterPanelUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryEditScreenState> state;

  /// 写真取得。
  final ObtainMeterPhotoUsecase obtainMeterPhotoUsecase;

  /// パネル読み取り。
  final ReadMeterPanelUsecase readMeterPanelUsecase;

  /// カメラから写真を取り、成功時は読み取りへ進む。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() => obtainAndReadEditPhoto(
    state: state,
    obtainMeterPhotoUsecase: obtainMeterPhotoUsecase,
    readMeterPanelUsecase: readMeterPanelUsecase,
    source: ObtainMeterPhotoSource.camera,
  );
}
