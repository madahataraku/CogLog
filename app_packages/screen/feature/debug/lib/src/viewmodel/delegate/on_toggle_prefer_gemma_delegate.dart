import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';

import '../state/debug_screen_state.dart';

/// Gemma 優先モードのオン／オフをセッション設定と State へ写す。
///
/// Example:
/// ```dart
/// OnTogglePreferGemmaDelegate(
///   state: state,
///   sessionPreference: preference,
/// ).execute(true);
/// ```
@internal
final class OnTogglePreferGemmaDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnTogglePreferGemmaDelegate(
  ///   state: state,
  ///   sessionPreference: preference,
  /// );
  /// ```
  const OnTogglePreferGemmaDelegate({
    required this.state,
    required this.sessionPreference,
  });

  /// 画面状態。
  final MutableStateStream<DebugScreenState> state;

  /// セッション内のエンジン優先設定。
  final MeterReadingEngineSessionPreference sessionPreference;

  /// [preferGemma] をセッションと State の両方へ反映する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute(true);
  /// ```
  Future<void> execute(bool preferGemma) async {
    sessionPreference.preferGemmaOverOsLlm = preferGemma;
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        DebugScreenState(
          running: current.running,
          result: current.result,
          gemmaResult: current.gemmaResult,
          logs: current.logs,
          preferGemmaOverOsLlm: preferGemma,
        ),
      );
    });
  }
}
