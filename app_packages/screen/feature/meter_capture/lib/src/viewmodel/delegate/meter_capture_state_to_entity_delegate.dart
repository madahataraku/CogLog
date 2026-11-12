import '../entity/meter_capture_screen_entity.dart';
import '../state/meter_capture_screen_state.dart';

/// メーター記録の State を入力欄の表示文字列へ変える。
///
/// Example:
/// ```dart
/// const MeterCaptureStateToEntityDelegate().execute(
///   MeterCaptureScreenState.initial,
/// );
/// ```
final class MeterCaptureStateToEntityDelegate {
  /// 変換を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureStateToEntityDelegate();
  /// ```
  const MeterCaptureStateToEntityDelegate();

  /// [state] の計測値を、未設定は空・設定済みは数値文字にする。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureStateToEntityDelegate().execute(
  ///   MeterCaptureScreenState.initial,
  /// );
  /// ```
  MeterCaptureScreenEntity execute(MeterCaptureScreenState state) {
    final duration = state.duration;
    return MeterCaptureScreenEntity(
      distanceText: _optionalNumber(state.distanceKm),
      hoursText: duration == null ? '' : '${duration.inHours}',
      minutesText: duration == null
          ? ''
          : '${duration.inMinutes.remainder(60)}',
      secondsText: duration == null
          ? ''
          : '${duration.inSeconds.remainder(60)}',
      averageSpeedText: _optionalNumber(state.averageSpeedKmh),
      caloriesText: _optionalNumber(state.caloriesKcal),
      recordedAtText: state.recordedAt?.toLocal().toIso8601String() ?? '',
      pendingModelDownloadGuidance: state.pendingModelDownloadGuidance,
      showHandEntryGuidance: state.showHandEntryGuidance,
    );
  }

  /// 未設定は空、設定済みは [toString] の結果。
  ///
  /// Example:
  /// ```dart
  /// _optionalNumber(null);
  /// ```
  String _optionalNumber(double? value) => value == null ? '' : '$value';
}
