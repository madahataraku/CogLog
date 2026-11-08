import 'package:riverpod/riverpod.dart';

import 'read_meter_panel_request.dart';
import 'read_meter_panel_result.dart';

/// メーターパネル写真から計測値を読み取る。
///
/// Example:
/// ```dart
/// usecase.execute(ReadMeterPanelRequest(photoBytes: Uint8List(0)));
/// ```
abstract interface class ReadMeterPanelUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<ReadMeterPanelUsecase>(
    (ref) => throw UnimplementedError('ReadMeterPanelUsecase.provider'),
  );

  /// [request] の写真をエンジン列で読み、マージ結果を返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(ReadMeterPanelRequest(photoBytes: Uint8List(0)));
  /// ```
  Future<ReadMeterPanelResult> execute(ReadMeterPanelRequest request);
}
