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
///   meterVlReadiness: '-',
///   meterVlStatus: '-',
///   meterVlReason: '-',
///   meterVlMessage: '-',
///   meterVlBackend: '-',
///   meterVlVisionBackend: '-',
///   meterVlAvailabilityError: '-',
///   meterVlCanGenerate: null,
///   meterVlProbeOutputLength: '-',
///   meterVlGenerateError: '-',
///   meterVlPrepareError: '-',
///   meterVlProbeSkipped: '-',
///   preferLfmVlOverOsLlm: false,
///   logLines: [],
/// );
/// ```
final class DebugScreenEntity {
  /// 診断ラベル用の文字列、`canGenerate`、ログ行をまとめて保持する。
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
  ///   meterVlReadiness: 'ready',
  ///   meterVlStatus: 'available',
  ///   meterVlReason: 'ready',
  ///   meterVlMessage: 'ok',
  ///   meterVlBackend: 'gpu',
  ///   meterVlVisionBackend: 'cpu',
  ///   meterVlAvailabilityError: '-',
  ///   meterVlCanGenerate: true,
  ///   meterVlProbeOutputLength: '2',
  ///   meterVlGenerateError: '-',
  ///   meterVlPrepareError: '-',
  ///   meterVlProbeSkipped: '-',
  ///   preferLfmVlOverOsLlm: true,
  ///   logLines: ['line'],
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
    required this.meterVlReadiness,
    required this.meterVlStatus,
    required this.meterVlReason,
    required this.meterVlMessage,
    required this.meterVlBackend,
    required this.meterVlVisionBackend,
    required this.meterVlAvailabilityError,
    required this.meterVlCanGenerate,
    required this.meterVlProbeOutputLength,
    required this.meterVlGenerateError,
    required this.meterVlPrepareError,
    required this.meterVlProbeSkipped,
    required this.preferLfmVlOverOsLlm,
    required this.logLines,
  });

  /// いま診断ユースケースが走っているとき true。
  final bool running;

  /// 端末上 LLM の readiness 名。スナップショット無しは `'-'`。
  final String readiness;

  /// 端末上 LLM の status。空・未取得は `'-'`。
  final String status;

  /// 端末上 LLM がその status になった理由。空・未取得は `'-'`。
  final String reason;

  /// 端末上 LLM の説明。空・未取得は `'-'`。
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

  /// メーター VL の readiness 名。未取得は `'-'`。
  final String meterVlReadiness;

  /// メーター VL の status。空・未取得は `'-'`。
  final String meterVlStatus;

  /// メーター VL の reason。空・未取得は `'-'`。
  final String meterVlReason;

  /// メーター VL の message。空・未取得は `'-'`。
  final String meterVlMessage;

  /// メーター VL の LiteRT-LM main backend（例: `gpu` / `cpu`）。空・未取得は `'-'`。
  final String meterVlBackend;

  /// メーター VL の LiteRT-LM visionBackend（例: `gpu` / `cpu`）。空・未取得は `'-'`。
  final String meterVlVisionBackend;

  /// メーター VL 利用可否例外。無ければ `'-'`。
  final String meterVlAvailabilityError;

  /// メーター VL 画像プローブの可否。未診断は null。
  final bool? meterVlCanGenerate;

  /// メーター VL プローブ本文の長さ（文字列）。未取得は `'-'`。
  final String meterVlProbeOutputLength;

  /// メーター VL 生成例外。無ければ `'-'`。
  final String meterVlGenerateError;

  /// メーター VL 準備例外。無ければ `'-'`。
  final String meterVlPrepareError;

  /// メーター VL プローブ省略理由。該当無しは `'-'`。
  final String meterVlProbeSkipped;

  /// 同一プロセス内で メーター VL をメーター読み取りで優先するとき true。
  final bool preferLfmVlOverOsLlm;

  /// 古い行が先（上が古い）になるログ文字列。各要素は 1 エントリ分。
  final List<String> logLines;
}
