import 'package:riverpod/riverpod.dart';

/// メーター読み取りエンジンのセッション内優先上書き。
///
/// 永続化しない。プロセス再起動で [preferGemmaOverOsLlm] は false に戻る。
///
/// Example:
/// ```dart
/// MeterReadingEngineSessionPreference();
/// ```
final class MeterReadingEngineSessionPreference {
  /// 初期は OS LLM 優先（[preferGemmaOverOsLlm] は false）。
  ///
  /// Example:
  /// ```dart
  /// MeterReadingEngineSessionPreference();
  /// ```
  MeterReadingEngineSessionPreference();

  /// true のとき ready+vision でも Gemma が available なら Gemma を選ぶ。
  bool preferGemmaOverOsLlm = false;
}

/// 同一プロセスで共有する [MeterReadingEngineSessionPreference]。
///
/// Example:
/// ```dart
/// ref.watch(meterReadingEngineSessionPreferenceProvider);
/// ```
final meterReadingEngineSessionPreferenceProvider =
    Provider<MeterReadingEngineSessionPreference>(
      (ref) => MeterReadingEngineSessionPreference(),
    );
