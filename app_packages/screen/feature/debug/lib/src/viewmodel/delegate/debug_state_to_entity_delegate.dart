import '../entity/debug_screen_entity.dart';
import '../state/debug_screen_state.dart';

/// State を表示用 Entity へ写す。
///
/// Example:
/// ```dart
/// const DebugStateToEntityDelegate();
/// ```
final class DebugStateToEntityDelegate {
  /// 変換委譲を作る。
  ///
  /// Example:
  /// ```dart
  /// const DebugStateToEntityDelegate();
  /// ```
  const DebugStateToEntityDelegate();

  /// [state] を Entity にする。
  ///
  /// Example:
  /// ```dart
  /// const DebugStateToEntityDelegate().execute(DebugScreenState.initial);
  /// ```
  DebugScreenEntity execute(DebugScreenState state) {
    final result = state.result;
    final snapshot = result?.snapshot;
    String dash(String? value) {
      if (value == null || value.isEmpty) {
        return '-';
      }
      return value;
    }

    final logLines = state.logs
        .map((entry) {
          final time =
              '${entry.at.hour.toString().padLeft(2, '0')}:'
              '${entry.at.minute.toString().padLeft(2, '0')}:'
              '${entry.at.second.toString().padLeft(2, '0')}';
          return '[$time] ${entry.level.name}/${entry.tag}: ${entry.message}';
        })
        .toList(growable: false);

    return DebugScreenEntity(
      running: state.running,
      readiness: snapshot?.readiness.name ?? '-',
      status: dash(snapshot?.status),
      reason: dash(snapshot?.reason),
      message: dash(snapshot?.message),
      backend: dash(snapshot?.backend),
      platformNotes: dash(snapshot?.platformNotes),
      availabilityError: dash(snapshot?.error),
      canGenerate: result?.canGenerate,
      sampleOutput: dash(result?.sampleOutput),
      generateError: dash(result?.generateError),
      prepareError: dash(result?.prepareError),
      probeSkipped: dash(result?.probeSkippedReason),
      logLines: logLines,
      forceSpatialOcr: state.forceSpatialOcr,
    );
  }
}
