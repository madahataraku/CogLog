import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';

import '../state/meter_capture_screen_state.dart';

/// 読み取り中止。世代を進め下書きを破棄し、遅延結果を捨てる。
///
/// Example:
/// ```dart
/// OnCancelMeterReadingDelegate(state: state).execute();
/// ```
@internal
final class OnCancelMeterReadingDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnCancelMeterReadingDelegate(state: state);
  /// ```
  const OnCancelMeterReadingDelegate({required this.state});

  /// 更新する画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// 世代を進め [MeterCaptureScreenState.initial] へ戻す。
  ///
  /// `pendingModelDownloadGuidance` も含め初期化し、遅延読み取り・誘導評価を捨てる。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((current, emitter) async {
      final nextGen = current.cameraSessionGeneration + 1;
      await emitter.emit(
        MeterCaptureScreenState.initial.copyWith(
          cameraSessionGeneration: nextGen,
        ),
      );
    });
  }
}
