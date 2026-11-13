/// View が診断・プローブ・ログを描画するときに参照する不変スナップショット。
///
/// 文字列フィールドの空・未取得は State から Entity へ写すとき `'-'` に揃える。
///
/// Example:
/// ```dart
/// const DebugScreenEntity(
///   running: false,
///   readiness: '-',
///   status: '-',
///   reason: '-',
///   message: '-',
///   backend: '-',
///   platformNotes: '-',
///   availabilityError: '-',
///   canGenerate: null,
///   sampleOutput: '-',
///   generateError: '-',
///   prepareError: '-',
///   probeSkipped: '-',
///   logLines: [],
///   forceSpatialOcr: false,
/// );
/// ```
final class DebugScreenEntity {
  /// 診断ラベル用の文字列、`canGenerate`、ログ行、上書きスイッチをまとめて保持する。
  ///
  /// Example:
  /// ```dart
  /// const DebugScreenEntity(
  ///   running: true,
  ///   readiness: 'ready',
  ///   status: 'available',
  ///   reason: 'ready',
  ///   message: 'ok',
  ///   backend: 'androidMlKitGenAi',
  ///   platformNotes: 'notes',
  ///   availabilityError: '-',
  ///   canGenerate: true,
  ///   sampleOutput: 'hi',
  ///   generateError: '-',
  ///   prepareError: '-',
  ///   probeSkipped: '-',
  ///   logLines: ['line'],
  ///   forceSpatialOcr: true,
  /// );
  /// ```
  const DebugScreenEntity({
    required this.running,
    required this.readiness,
    required this.status,
    required this.reason,
    required this.message,
    required this.backend,
    required this.platformNotes,
    required this.availabilityError,
    required this.canGenerate,
    required this.sampleOutput,
    required this.generateError,
    required this.prepareError,
    required this.probeSkipped,
    required this.logLines,
    required this.forceSpatialOcr,
  });

  /// いま端末上 LLM 診断ユースケースが走っているとき true。
  final bool running;

  /// 利用可否スナップショットの readiness 名。スナップショット無しは `'-'`。
  final String readiness;

  /// 利用可否の status。空・未取得は `'-'`。
  final String status;

  /// 利用可否がその status になった理由。空・未取得は `'-'`。
  final String reason;

  /// 利用可否に付随する説明。空・未取得は `'-'`。
  final String message;

  /// 診断で選択された LLM バックエンド識別子。空・未取得は `'-'`。
  final String backend;

  /// プラットフォーム向けの補足メモ。空・未取得は `'-'`。
  final String platformNotes;

  /// 利用可否取得で捕捉した例外の文字列表現。無ければ `'-'`。
  final String availabilityError;

  /// プローブ生成の可否。診断未完了・結果無しは null。
  final bool? canGenerate;

  /// プローブで得たサンプル出力。空・未取得は `'-'`。
  final String sampleOutput;

  /// プローブ生成フェーズの例外。無ければ `'-'`。
  final String generateError;

  /// プローブ準備フェーズの例外。無ければ `'-'`。
  final String prepareError;

  /// プローブをスキップした理由。該当無しは `'-'`。
  final String probeSkipped;

  /// 古い行が先（上が古い）になるログ文字列。各要素は 1 エントリ分。
  final List<String> logLines;

  /// デバッグ用の空間 OCR 強制上書きが ON なら true。
  final bool forceSpatialOcr;
}
