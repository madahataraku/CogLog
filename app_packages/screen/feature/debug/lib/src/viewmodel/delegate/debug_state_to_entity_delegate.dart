import '../entity/debug_screen_entity.dart';
import '../state/debug_screen_state.dart';

/// State を表示用 Entity へ写す。
///
/// Example:
/// ```dart
/// const DebugStateToEntityDelegate();
/// ```
final class DebugStateToEntityDelegate {
  /// 状態を持たず、どの [DebugScreenState] にも使い回せる。
  ///
  /// Example:
  /// ```dart
  /// const DebugStateToEntityDelegate();
  /// ```
  const DebugStateToEntityDelegate();

  /// [state] を表示用 [DebugScreenEntity] に写す。
  ///
  /// null・空文字の診断文字列は `'-'` に置き換える。
  /// ログ行は時刻・レベル・タグ付きの 1 行文字列へ整形し、[DebugScreenState.logs] の順を保つ。
  ///
  /// Example:
  /// ```dart
  /// const DebugStateToEntityDelegate().execute(DebugScreenState.initial);
  /// ```
  DebugScreenEntity execute(DebugScreenState state) {
    final result = state.result;
    final snapshot = result?.snapshot;
    // ラベル行の未取得表示を画面全体で揃える。
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
