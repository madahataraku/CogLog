import 'package:riverpod/riverpod.dart';

/// メーター読み取りエンジンのセッション内優先上書き。
///
/// 永続化しない。プロセス再起動で [preferLfmVlOverOsLlm] は false に戻る。
///
/// Example:
/// ```dart
/// MeterReadingEngineSessionPreference();
/// ```
final class MeterReadingEngineSessionPreference {
  /// 初期は OS LLM 優先（[preferLfmVlOverOsLlm] は false）。
  ///
  /// Example:
  /// ```dart
  /// MeterReadingEngineSessionPreference();
  /// ```
  MeterReadingEngineSessionPreference();

  /// true のとき ready+vision でも LFM VL が available なら LFM VL を選ぶ。
  bool preferLfmVlOverOsLlm = false;
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
