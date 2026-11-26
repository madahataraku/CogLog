import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';

import '../state/debug_screen_state.dart';

/// LFM VL 優先モードのオン／オフをセッション設定と State へ写す。
///
/// Example:
/// ```dart
/// OnTogglePreferLfmVlDelegate(
///   state: state,
///   sessionPreference: preference,
/// ).execute(true);
/// ```
@internal
final class OnTogglePreferLfmVlDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnTogglePreferLfmVlDelegate(
  ///   state: state,
  ///   sessionPreference: preference,
  /// );
  /// ```
  const OnTogglePreferLfmVlDelegate({
    required this.state,
    required this.sessionPreference,
  });

  /// 画面状態。
  final MutableStateStream<DebugScreenState> state;

  /// セッション内のエンジン優先設定。
  final MeterReadingEngineSessionPreference sessionPreference;

  /// [preferLfmVl] をセッションと State の両方へ反映する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute(true);
  /// ```
  Future<void> execute(bool preferLfmVl) async {
    sessionPreference.preferLfmVlOverOsLlm = preferLfmVl;
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        DebugScreenState(
          running: current.running,
          result: current.result,
          meterVlResult: current.meterVlResult,
          logs: current.logs,
          preferLfmVlOverOsLlm: preferLfmVl,
        ),
      );
    });
  }
}
