import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';

import 'map_plugin_readiness.dart';
import 'method_channel_on_device_llm_native_client.dart';
import 'on_device_llm_native_client.dart';

/// OS モデルだけを使う [OnDeviceLlm]（自前 Flutter plugin）。
///
/// Example:
/// ```dart
/// PluginOnDeviceLlm();
/// ```
final class PluginOnDeviceLlm implements OnDeviceLlm {
  /// [client] を省略すると MethodChannel 実装を使う。
  ///
  /// Example:
  /// ```dart
  /// PluginOnDeviceLlm();
  /// ```
  PluginOnDeviceLlm({OnDeviceLlmNativeClient? client})
    : _client = client ?? MethodChannelOnDeviceLlmNativeClient();

  /// ネイティブ問い合わせ先。
  final OnDeviceLlmNativeClient _client;

  /// ネイティブ可否を [mapPluginReadiness] で写す。失敗時は unavailable。
  ///
  /// Example:
  /// ```dart
  /// await PluginOnDeviceLlm().readiness;
  /// ```
  @override
  Future<OnDeviceLlmReadiness> get readiness async {
    try {
      return mapPluginReadiness(await _client.getAvailability());
    } on Object {
      // ネイティブ availability 例外は利用不可として扱う。
      return OnDeviceLlmReadiness.unavailable;
    }
  }

  /// [readiness] が ready のとき true。
  ///
  /// Example:
  /// ```dart
  /// await PluginOnDeviceLlm().isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async =>
      (await readiness) == OnDeviceLlmReadiness.ready;

  /// ネイティブ availability と platformInfo を診断スナップショットへ写す。
  ///
  /// Example:
  /// ```dart
  /// await PluginOnDeviceLlm().availabilitySnapshot;
  /// ```
  @override
  Future<OnDeviceLlmAvailabilitySnapshot> get availabilitySnapshot async {
    try {
      final availability = await _client.getAvailability();
      String? backend;
      String? platformNotes;
      try {
        final info = await _client.getPlatformInfo();
        backend = info.backend;
        platformNotes = info.diagnosticNotes;
      } on Object {
        // platformInfo 失敗は availability 本体の診断を優先する。
      }
      return OnDeviceLlmAvailabilitySnapshot(
        readiness: mapPluginReadiness(availability),
        status: availability.status,
        reason: availability.reason,
        message: availability.message,
        backend: backend,
        platformNotes: platformNotes,
      );
    } on Object catch (error) {
      return OnDeviceLlmAvailabilitySnapshot(
        readiness: OnDeviceLlmReadiness.unavailable,
        status: 'error',
        reason: 'exception',
        message: 'availability failed',
        error: formatExceptionDetail(error),
      );
    }
  }

  /// ネイティブ生成の本文を返す。ready でなければ失敗する。
  ///
  /// Example:
  /// ```dart
  /// await PluginOnDeviceLlm().generate('hello');
  /// ```
  @override
  Future<String> generate(String prompt) async {
    if (!await isAvailable) {
      throw StateError('OnDeviceLlm is not ready');
    }
    return _client.generate(prompt: prompt);
  }

  /// 準備状態を問わずネイティブ生成を試し、接続失敗の型名を拾う。
  ///
  /// Example:
  /// ```dart
  /// await PluginOnDeviceLlm().diagnoseGenerate('ping');
  /// ```
  @override
  Future<String> diagnoseGenerate(String prompt) =>
      _client.diagnoseGenerate(prompt: prompt);

  /// OS にモデル準備を依頼する。
  ///
  /// Example:
  /// ```dart
  /// await PluginOnDeviceLlm().prepareModel();
  /// ```
  @override
  Future<void> prepareModel() => _client.prepare();
}
